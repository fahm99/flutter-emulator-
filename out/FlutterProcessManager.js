"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FlutterProcessManager = void 0;
const vscode = __importStar(require("vscode"));
const cp = __importStar(require("child_process"));
class FlutterProcessManager {
    constructor() {
        this.flutterProcess = null;
        this.serverUrl = '';
        this.isRunning = false;
        console.log('FlutterProcessManager initialized');
    }
    startFlutterWebServer() {
        return __awaiter(this, arguments, void 0, function* (isRelease = false, customFlags = []) {
            return new Promise((resolve, reject) => {
                // Check if Flutter is installed
                this.checkFlutterInstallation()
                    .then(() => {
                    var _a, _b, _c;
                    // Find the workspace folder
                    const workspaceFolder = (_a = vscode.workspace.workspaceFolders) === null || _a === void 0 ? void 0 : _a[0];
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
                        env: Object.assign(Object.assign({}, process.env), { FLUTTER_WEB_PORT: '8080' })
                    });
                    let output = '';
                    let urlFound = false;
                    (_b = this.flutterProcess.stdout) === null || _b === void 0 ? void 0 : _b.on('data', (data) => {
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
                    (_c = this.flutterProcess.stderr) === null || _c === void 0 ? void 0 : _c.on('data', (data) => {
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
        });
    }
    checkFlutterInstallation() {
        return __awaiter(this, void 0, void 0, function* () {
            return new Promise((resolve, reject) => {
                const process = cp.spawn('flutter', ['--version'], { shell: true });
                process.on('error', (error) => {
                    reject(new Error('Flutter is not installed or not in PATH'));
                });
                process.on('close', (code) => {
                    if (code === 0) {
                        resolve();
                    }
                    else {
                        reject(new Error('Flutter is not installed or not in PATH'));
                    }
                });
            });
        });
    }
    stopFlutterWebServer() {
        if (this.flutterProcess) {
            console.log('Stopping Flutter web server');
            this.flutterProcess.kill();
            this.flutterProcess = null;
            this.isRunning = false;
        }
    }
    isFlutterRunning() {
        return this.isRunning;
    }
    getServerUrl() {
        return this.serverUrl;
    }
}
exports.FlutterProcessManager = FlutterProcessManager;
//# sourceMappingURL=FlutterProcessManager.js.map