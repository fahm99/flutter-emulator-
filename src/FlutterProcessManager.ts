import * as vscode from 'vscode';
import * as cp from 'child_process';
import * as path from 'path';

export class FlutterProcessManager {
  private flutterProcess: cp.ChildProcess | null = null;
  private serverUrl: string = '';
  private isRunning: boolean = false;

  constructor() {
    console.log('FlutterProcessManager initialized');
  }

  public async startFlutterWebServer(isRelease: boolean = false, customFlags: string[] = []): Promise<string> {
    return new Promise((resolve, reject) => {
      // Check if Flutter is installed
      this.checkFlutterInstallation()
        .then(() => {
          // Find the workspace folder
          const workspaceFolder = vscode.workspace.workspaceFolders?.[0];
          if (!workspaceFolder) {
            reject(new Error('No workspace folder found'));
            return;
          }

          // Build Flutter command
          const args = ['run', '-d', 'chrome', '--no-pub'];
          
          if (isRelease) {
            args.push('--release');
          }
          
          // Add custom flags
          if (customFlags && customFlags.length > 0) {
            args.push(...customFlags);
          }

          // Set the web port
          process.env.FLUTTER_WEB_PORT = '8080';

          console.log('Starting Flutter web server with args:', args);

          // Start Flutter process
          this.flutterProcess = cp.spawn('flutter', args, {
            cwd: workspaceFolder.uri.fsPath,
            shell: true,
            env: { ...process.env, FLUTTER_WEB_PORT: '8080' }
          });

          let output = '';
          let urlFound = false;

          this.flutterProcess.stdout?.on('data', (data) => {
            const outputStr = data.toString();
            output += outputStr;
            console.log('Flutter stdout:', outputStr);

            // Extract URL from output
            if (!urlFound) {
              const urlMatch = outputStr.match(/http:\/\/localhost:(\d+)/);
              if (urlMatch) {
                this.serverUrl = urlMatch[0];
                urlFound = true;
                this.isRunning = true;
                resolve(this.serverUrl);
              }
            }
          });

          this.flutterProcess.stderr?.on('data', (data) => {
            console.log('Flutter stderr:', data.toString());
          });

          this.flutterProcess.on('error', (error) => {
            console.error('Flutter process error:', error);
            this.isRunning = false;
            reject(error);
          });

          this.flutterProcess.on('close', (code) => {
            console.log('Flutter process closed with code:', code);
            this.isRunning = false;
          });

          // Timeout after 60 seconds
          setTimeout(() => {
            if (!urlFound) {
              // Use default URL if not found
              this.serverUrl = 'http://localhost:8080';
              this.isRunning = true;
              resolve(this.serverUrl);
            }
          }, 60000);
        })
        .catch((error) => {
          reject(error);
        });
    });
  }

  private async checkFlutterInstallation(): Promise<void> {
    return new Promise((resolve, reject) => {
      const process = cp.spawn('flutter', ['--version'], { shell: true });
      
      process.on('error', (error) => {
        reject(new Error('Flutter is not installed or not in PATH'));
      });

      process.on('close', (code) => {
        if (code === 0) {
          resolve();
        } else {
          reject(new Error('Flutter is not installed or not in PATH'));
        }
      });
    });
  }

  public stopFlutterWebServer(): void {
    if (this.flutterProcess) {
      console.log('Stopping Flutter web server');
      this.flutterProcess.kill();
      this.flutterProcess = null;
      this.isRunning = false;
    }
  }

  public isFlutterRunning(): boolean {
    return this.isRunning;
  }

  public getServerUrl(): string {
    return this.serverUrl;
  }
}