// Flutter IDE Mobile - Compilation Controller
// Handles Flutter code compilation

const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const shell = require('shelljs');
const { v4: uuidv4 } = require('uuid');

class CompilationController {
  constructor(sessions, wsConnections) {
    this.sessions = sessions;
    this.wsConnections = wsConnections;
    this.tempDir = path.join(__dirname, '../../temp');
    
    // Ensure temp directory exists
    if (!fs.existsSync(this.tempDir)) {
      fs.mkdirSync(this.tempDir, { recursive: true });
    }
  }

  /**
   * Create a new compilation session
   */
  async createSession(options) {
    const { sessionId, code, mainFile, files, device, ws } = options;
    
    const sessionDir = path.join(this.tempDir, sessionId);
    fs.mkdirSync(sessionDir, { recursive: true });
    
    // Write main file
    const mainFilePath = path.join(sessionDir, mainFile || 'main.dart');
    fs.writeFileSync(mainFilePath, code);
    
    // Write additional files
    if (files) {
      for (const [filename, content] of Object.entries(files)) {
        const filePath = path.join(sessionDir, filename);
        const dir = path.dirname(filePath);
        if (!fs.existsSync(dir)) {
          fs.mkdirSync(dir, { recursive: true });
        }
        fs.writeFileSync(filePath, content);
      }
    }
    
    return {
      id: sessionId,
      dir: sessionDir,
      mainFile: mainFilePath,
      status: 'pending',
      progress: 0,
      output: '',
      error: null,
      webUrl: null,
      process: null,
      ws: ws,
      createdAt: new Date()
    };
  }

  /**
   * Compile Flutter code
   */
  async compile(sessionId, code, files = {}) {
    const session = this.sessions.get(sessionId);
    if (!session) {
      throw new Error('Session not found');
    }

    // Update session status
    session.status = 'compiling';
    session.progress = 10;

    // Check if Flutter is installed
    const flutterCheck = shell.which('flutter');
    if (!flutterCheck) {
      // Fallback: Simulate compilation for demo purposes
      return this._simulateCompilation(session, code);
    }

    try {
      // Create project structure
      const projectName = `flutter_app_${sessionId.slice(0, 8)}`;
      const projectDir = path.join(this.tempDir, projectName);
      
      // Create pubspec.yaml
      const pubspecContent = this._generatePubspec(projectName);
      fs.writeFileSync(path.join(projectDir, 'pubspec.yaml'), pubspecContent);
      
      // Write main.dart
      fs.writeFileSync(path.join(projectDir, 'lib', 'main.dart'), code);
      
      // Write additional files
      for (const [filename, content] of Object.entries(files)) {
        const filePath = path.join(projectDir, 'lib', filename);
        const dir = path.dirname(filePath);
        if (!fs.existsSync(dir)) {
          fs.mkdirSync(dir, { recursive: true });
        }
        fs.writeFileSync(filePath, content);
      }

      session.progress = 30;

      // Run flutter pub get
      const pubGetResult = await this._runCommand(
        'flutter',
        ['pub', 'get'],
        { cwd: projectDir }
      );

      if (!pubGetResult.success) {
        throw new Error(`pub get failed: ${pubGetResult.output}`);
      }

      session.progress = 60;

      // Run flutter build web
      const buildResult = await this._runCommand(
        'flutter',
        ['build', 'web', '--release', '--no-pub'],
        { cwd: projectDir }
      );

      session.progress = 90;

      if (buildResult.success) {
        const buildDir = path.join(projectDir, 'build', 'web');
        session.status = 'success';
        session.output = buildResult.output;
        session.webUrl = `http://localhost:3001/${projectName}/`;
        
        // Copy to serve from
        const serveDir = path.join(__dirname, '../public', projectName);
        shell.cp('-r', buildDir, serveDir);
      } else {
        throw new Error(`Build failed: ${buildResult.output}`);
      }

      session.progress = 100;

      return {
        success: true,
        output: session.output,
        webUrl: session.webUrl,
        errors: this._parseErrors(buildResult.output),
        warnings: this._parseWarnings(buildResult.output)
      };

    } catch (error) {
      session.status = 'error';
      session.error = error.message;
      
      return {
        success: false,
        error: error.message,
        errors: [{ line: 0, column: 0, message: error.message, severity: 'error' }],
        warnings: []
      };
    }
  }

  /**
   * Simulate compilation (for demo when Flutter is not installed)
   */
  async _simulateCompilation(session, code) {
    console.log(`[Simulate] Compiling session: ${session.id}`);
    
    // Simulate compilation steps
    session.progress = 10;
    await this._delay(500);
    
    session.progress = 30;
    await this._delay(500);
    
    session.progress = 60;
    await this._delay(500);
    
    // Check for syntax errors in code
    const errors = this._parseSyntaxErrors(code);
    
    session.progress = 90;
    await this._delay(300);
    
    if (errors.length > 0) {
      session.status = 'error';
      session.error = errors.map(e => e.message).join('\n');
      
      return {
        success: false,
        error: session.error,
        errors: errors,
        warnings: []
      };
    }
    
    session.status = 'success';
    session.output = 'Build completed successfully (simulated)';
    session.webUrl = `http://localhost:3001/simulated/`;
    session.progress = 100;
    
    return {
      success: true,
      output: session.output,
      webUrl: session.webUrl,
      errors: [],
      warnings: []
    };
  }

  /**
   * Run a shell command
   */
  _runCommand(command, args, options = {}) {
    return new Promise((resolve) => {
      const proc = spawn(command, args, {
        ...options,
        env: { ...process.env, FLUTTER_WEB_PORT: '3001' }
      });

      let output = '';
      let errorOutput = '';

      proc.stdout.on('data', (data) => {
        output += data.toString();
      });

      proc.stderr.on('data', (data) => {
        errorOutput += data.toString();
      });

      proc.on('close', (code) => {
        resolve({
          success: code === 0,
          output: output || errorOutput,
          code
        });
      });

      proc.on('error', (error) => {
        resolve({
          success: false,
          output: error.message,
          code: -1
        });
      });
      
      // Store process reference
      if (session = this.sessions.get(sessionId)) {
        session.process = proc;
      }
    });
  }

  /**
   * Parse errors from output
   */
  _parseErrors(output) {
    const errors = [];
    const lines = output.split('\n');
    
    for (const line of lines) {
      // Match common error patterns
      const match = line.match(/Error:\s*(.+)/i) ||
                    line.match(/error.*?(\d+):(\d+):\s*(.+)/i);
      
      if (match) {
        errors.push({
          line: parseInt(match[1]) || 0,
          column: parseInt(match[2]) || 0,
          message: match[3] || match[1],
          severity: 'error'
        });
      }
    }
    
    return errors;
  }

  /**
   * Parse warnings from output
   */
  _parseWarnings(output) {
    const warnings = [];
    const lines = output.split('\n');
    
    for (const line of lines) {
      const match = line.match(/Warning:\s*(.+)/i) ||
                    line.match(/warning.*?(\d+):(\d+):\s*(.+)/i);
      
      if (match) {
        warnings.push({
          line: parseInt(match[1]) || 0,
          column: parseInt(match[2]) || 0,
          message: match[3] || match[1]
        });
      }
    }
    
    return warnings;
  }

  /**
   * Parse syntax errors from code
   */
  _parseSyntaxErrors(code) {
    const errors = [];
    const lines = code.split('\n');
    
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      const lineNum = i + 1;
      
      // Check for unclosed strings
      const stringMatches = line.match(/["']/g);
      if (stringMatches && stringMatches.length % 2 !== 0) {
        errors.push({
          line: lineNum,
          column: line.indexOf(stringMatches[stringMatches.length - 1]) + 1,
          message: 'Unclosed string literal',
          severity: 'error'
        });
      }
      
      // Check for unmatched brackets
      const brackets = { '(': ')', '[': ']', '{': '}' };
      const stack = [];
      for (let j = 0; j < line.length; j++) {
        const char = line[j];
        if (brackets[char]) {
          stack.push({ char, col: j + 1 });
        } else if (Object.values(brackets).includes(char)) {
          if (stack.length === 0) {
            errors.push({
              line: lineNum,
              column: j + 1,
              message: `Unmatched closing bracket '${char}'`,
              severity: 'error'
            });
          } else {
            const last = stack.pop();
            if (brackets[last.char] !== char) {
              errors.push({
                line: lineNum,
                column: j + 1,
                message: `Mismatched bracket: expected '${brackets[last.char]}' but found '${char}'`,
                severity: 'error'
              });
            }
          }
        }
      }
    }
    
    return errors;
  }

  /**
   * Generate pubspec.yaml
   */
  _generatePubspec(name) {
    return `
name: ${name}
description: "Flutter app compiled by Flutter IDE Mobile"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
`;
  }

  /**
   * Delay helper
   */
  _delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Clean up session
   */
  cleanup(sessionId) {
    const session = this.sessions.get(sessionId);
    if (session) {
      if (session.process) {
        session.process.kill();
      }
      if (session.dir && fs.existsSync(session.dir)) {
        shell.rm('-rf', session.dir);
      }
      this.sessions.delete(sessionId);
    }
  }
}

module.exports = { CompilationController };