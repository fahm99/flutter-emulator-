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
exports.FlutterMultiEmulatorPanel = void 0;
const vscode = __importStar(require("vscode"));
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
class FlutterMultiEmulatorPanel {
    static createOrShow(extensionUri, processManager) {
        console.log('Creating or showing FlutterMultiEmulatorPanel');
        const column = vscode.ViewColumn.Two;
        if (FlutterMultiEmulatorPanel.currentPanel) {
            console.log('Revealing existing panel');
            FlutterMultiEmulatorPanel.currentPanel._panel.reveal(column);
            return FlutterMultiEmulatorPanel.currentPanel._panel;
        }
        console.log('Creating new webview panel');
        const panel = vscode.window.createWebviewPanel(FlutterMultiEmulatorPanel.viewType, 'Flutter Multi-Emulator', column, {
            enableScripts: true,
            localResourceRoots: [extensionUri],
            retainContextWhenHidden: true
        });
        FlutterMultiEmulatorPanel.currentPanel = new FlutterMultiEmulatorPanel(panel, extensionUri, processManager);
        return panel;
    }
    static reload() {
        if (FlutterMultiEmulatorPanel.currentPanel) {
            FlutterMultiEmulatorPanel.currentPanel._reload();
        }
    }
    static rotate() {
        if (FlutterMultiEmulatorPanel.currentPanel) {
            FlutterMultiEmulatorPanel.currentPanel._rotate();
        }
    }
    static takeScreenshot() {
        if (FlutterMultiEmulatorPanel.currentPanel) {
            FlutterMultiEmulatorPanel.currentPanel._takeScreenshot();
        }
    }
    static showAllDevices() {
        if (FlutterMultiEmulatorPanel.currentPanel) {
            FlutterMultiEmulatorPanel.currentPanel._showAllDevices();
        }
    }
    static dispose() {
        var _a;
        (_a = FlutterMultiEmulatorPanel.currentPanel) === null || _a === void 0 ? void 0 : _a.dispose();
        FlutterMultiEmulatorPanel.currentPanel = undefined;
    }
    constructor(panel, extensionUri, processManager) {
        this._disposables = [];
        this._isPortrait = true;
        this._currentDevice = 'iPhone 14 Pro';
        this._panel = panel;
        this._extensionUri = extensionUri;
        this._processManager = processManager;
        this._update();
        this._panel.onDidDispose(() => this.dispose(), null, this._disposables);
        this._panel.onDidChangeViewState(e => {
            if (this._panel.visible) {
                this._update();
            }
        }, null, this._disposables);
        this._panel.webview.onDidReceiveMessage(message => {
            console.log('Received message from webview:', JSON.stringify(message));
            switch (message.command) {
                case 'webviewReady':
                    console.log('Webview is ready, starting Flutter process');
                    this._startFlutterProcess();
                    return;
                case 'reload':
                    this._reload();
                    return;
                case 'rotate':
                    this._rotate();
                    return;
                case 'screenshot':
                    this._takeScreenshot();
                    return;
                case 'deviceChanged':
                    this._currentDevice = message.device;
                    vscode.window.showInformationMessage(`Device changed to ${message.device}`);
                    return;
                case 'showAllDevices':
                    this._showAllDevices();
                    return;
                case 'captureScreenshot':
                    this._handleScreenshotCapture(message.data);
                    return;
                default:
                    console.log('Unhandled message command:', message.command);
            }
        }, null, this._disposables);
    }
    _startFlutterProcess() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const config = vscode.workspace.getConfiguration('flutterMultiEmulator');
                const customFlags = config.get('customFlags', []);
                vscode.window.showInformationMessage('Starting Flutter web server...');
                const url = yield this._processManager.startFlutterWebServer(false, customFlags);
                console.log('Received server URL:', url);
                vscode.window.showInformationMessage(`Flutter web server started at ${url}`);
                if (this._panel) {
                    console.log('Posting setAppUrl message to webview:', url);
                    this._panel.webview.postMessage({ command: 'setAppUrl', url });
                }
                else {
                    console.error('Webview panel not initialized');
                }
            }
            catch (error) {
                console.error('Failed to start Flutter web server:', error);
                const errorMessage = error instanceof Error ? error.message : String(error);
                vscode.window.showErrorMessage(`Failed to start Flutter web server: ${errorMessage}`);
            }
        });
    }
    _reload() {
        console.log('Sending reload message to webview');
        this._panel.webview.postMessage({ command: 'reload' });
    }
    _rotate() {
        this._isPortrait = !this._isPortrait;
        console.log('Sending rotate message to webview, isPortrait:', this._isPortrait);
        this._panel.webview.postMessage({ command: 'rotate', isPortrait: this._isPortrait });
    }
    _takeScreenshot() {
        console.log('Taking screenshot request');
        this._panel.webview.postMessage({ command: 'requestScreenshot' });
    }
    _showAllDevices() {
        console.log('Showing all devices');
        this._panel.webview.postMessage({ command: 'showAllDevices' });
    }
    _handleScreenshotCapture(imageData) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const config = vscode.workspace.getConfiguration('flutterMultiEmulator');
                const screenshotFolder = config.get('screenshotFolder', '${workspaceFolder}/screenshots');
                // Get workspace folder
                const workspaceFolder = (_a = vscode.workspace.workspaceFolders) === null || _a === void 0 ? void 0 : _a[0];
                if (!workspaceFolder) {
                    vscode.window.showErrorMessage('No workspace folder found');
                    return;
                }
                // Resolve screenshot folder path
                let resolvedFolder = screenshotFolder.replace('${workspaceFolder}', workspaceFolder.uri.fsPath);
                // Create screenshots directory if it doesn't exist
                if (!fs.existsSync(resolvedFolder)) {
                    fs.mkdirSync(resolvedFolder, { recursive: true });
                }
                // Generate filename with timestamp
                const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
                const filename = `screenshot-${this._currentDevice.replace(/\s+/g, '-')}-${timestamp}.png`;
                const filepath = path.join(resolvedFolder, filename);
                // Remove data URL prefix and save
                const base64Data = imageData.replace(/^data:image\/png;base64,/, '');
                fs.writeFileSync(filepath, base64Data, 'base64');
                vscode.window.showInformationMessage(`Screenshot saved: ${filename}`);
                console.log('Screenshot saved to:', filepath);
            }
            catch (error) {
                console.error('Failed to save screenshot:', error);
                vscode.window.showErrorMessage('Failed to save screenshot');
            }
        });
    }
    _update() {
        const webview = this._panel.webview;
        this._panel.title = 'Flutter Multi-Emulator';
        const html = this._getHtmlForWebview(webview);
        console.log('Updating webview HTML');
        webview.html = html;
    }
    _getHtmlForWebview(webview) {
        const config = vscode.workspace.getConfiguration('flutterMultiEmulator');
        const defaultDeviceName = config.get('defaultDevice', 'iPhone 14 Pro');
        const devicePresets = config.get('devicePresets', {});
        const defaultDevice = devicePresets[defaultDeviceName] || { width: 393, height: 852, devicePixelRatio: 3, type: 'phone' };
        const enableScreenshot = config.get('enableScreenshot', true);
        const scriptPathOnDisk = path.join(this._extensionUri.fsPath, 'media', 'main.js');
        const scriptUri = webview.asWebviewUri(vscode.Uri.file(scriptPathOnDisk));
        const touchEventsPathOnDisk = path.join(this._extensionUri.fsPath, 'media', 'touch-events.js');
        const touchEventsUri = webview.asWebviewUri(vscode.Uri.file(touchEventsPathOnDisk));
        const deviceAnimationsPathOnDisk = path.join(this._extensionUri.fsPath, 'media', 'device-animations.js');
        const deviceAnimationsUri = webview.asWebviewUri(vscode.Uri.file(deviceAnimationsPathOnDisk));
        const hotReloadPathOnDisk = path.join(this._extensionUri.fsPath, 'media', 'hot-reload.js');
        const hotReloadUri = webview.asWebviewUri(vscode.Uri.file(hotReloadPathOnDisk));
        const stylePathOnDisk = path.join(this._extensionUri.fsPath, 'media', 'style.css');
        const styleUri = webview.asWebviewUri(vscode.Uri.file(stylePathOnDisk));
        const deviceEffectsPathOnDisk = path.join(this._extensionUri.fsPath, 'media', 'device-effects.css');
        const deviceEffectsUri = webview.asWebviewUri(vscode.Uri.file(deviceEffectsPathOnDisk));
        const nonce = getNonce();
        // Build device options HTML
        const deviceOptionsHtml = Object.keys(devicePresets).map(device => {
            const preset = devicePresets[device];
            const typeLabel = preset.type === 'tablet' ? '📱' : '📱';
            return `<option value="${device}" ${device === defaultDeviceName ? 'selected' : ''}>${typeLabel} ${device}</option>`;
        }).join('');
        // Group devices by type
        const phoneDevices = Object.keys(devicePresets).filter(d => devicePresets[d].type === 'phone');
        const tabletDevices = Object.keys(devicePresets).filter(d => devicePresets[d].type === 'tablet');
        const html = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src ${webview.cspSource} 'unsafe-inline'; script-src 'nonce-${nonce}'; frame-src http://localhost:* http://127.0.0.1:*; img-src 'self' data: blob:;">
    <link href="${styleUri}" rel="stylesheet">
    <link href="${deviceEffectsUri}" rel="stylesheet">
    <title>Flutter Multi-Emulator</title>
</head>
<body>
    <div class="emulator-container">
        <!-- Multi-device selector toolbar -->
        <div class="device-toolbar">
            <div class="toolbar-section">
                <label class="toolbar-label">📱 Device:</label>
                <select id="device-select" class="device-dropdown">
                    <optgroup label="📱 Phones">
                        ${phoneDevices.map(device => `<option value="${device}" ${device === defaultDeviceName ? 'selected' : ''}>${device}</option>`).join('')}
                    </optgroup>
                    <optgroup label="📲 Tablets">
                        ${tabletDevices.map(device => `<option value="${device}" ${device === defaultDeviceName ? 'selected' : ''}>${device}</option>`).join('')}
                    </optgroup>
                </select>
            </div>
            <div class="toolbar-section">
                <button id="rotate-btn" class="toolbar-btn" title="Rotate (Ctrl+Shift+R)">↻ Rotate</button>
                ${enableScreenshot ? `<button id="screenshot-btn" class="toolbar-btn" title="Take Screenshot (Ctrl+Shift+S)">📷 Screenshot</button>` : ''}
                <button id="reload-btn" class="toolbar-btn" title="Reload (Ctrl+R)">⟳ Reload</button>
            </div>
            <div class="toolbar-section">
                <button id="all-devices-btn" class="toolbar-btn" title="View All Devices">📱 All Devices</button>
            </div>
        </div>

        <!-- All devices view (hidden by default) -->
        <div id="all-devices-view" class="all-devices-view" style="display: none;">
            <h2>Select a Device</h2>
            <div class="devices-grid">
                ${Object.keys(devicePresets).map(device => {
            const preset = devicePresets[device];
            return `<div class="device-card" data-device="${device}">
                        <div class="device-card-name">${device}</div>
                        <div class="device-card-size">${preset.width}x${preset.height}</div>
                        <div class="device-card-type">${preset.type}</div>
                    </div>`;
        }).join('')}
            </div>
        </div>

        <!-- Main emulator view -->
        <div id="emulator-view" class="emulator-view">
            <!-- Authentic mobile device frame -->
            <div class="device-wrapper ${this._isPortrait ? 'portrait' : 'landscape'}">
                <div class="device-frame authentic-frame">
                    <!-- Device bezels and physical details -->
                    <div class="device-bezel top-bezel">
                        <div class="speaker-grille"></div>
                        <div class="front-camera"></div>
                        <div class="proximity-sensor"></div>
                    </div>
                    
                    <!-- Main screen area -->
                    <div class="device-screen authentic-screen">
                        <!-- Realistic status bar -->
                        <div class="status-bar authentic-status">
                            <div class="status-left">
                                <div class="carrier">Flutter</div>
                                <div class="signal-strength">
                                    <span class="signal-bar"></span>
                                    <span class="signal-bar"></span>
                                    <span class="signal-bar"></span>
                                    <span class="signal-bar active"></span>
                                </div>
                                <div class="wifi-icon">📶</div>
                            </div>
                            <div class="status-center">
                                <div class="status-time">12:00</div>
                            </div>
                            <div class="status-right">
                                <div class="battery-percentage">100%</div>
                                <div class="battery-icon">
                                    <div class="battery-body">
                                        <div class="battery-level"></div>
                                    </div>
                                    <div class="battery-tip"></div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- App content area -->
                        <div class="app-viewport">
                            <iframe id="flutter-app" src="about:blank" frameborder="0"></iframe>
                        </div>
                        
                        <!-- Home indicator (for modern devices) -->
                        <div class="home-indicator"></div>
                    </div>
                    
                    <!-- Bottom bezel -->
                    <div class="device-bezel bottom-bezel"></div>
                </div>
                
                <!-- Physical device buttons -->
                <div class="device-buttons">
                    <div class="power-button" title="Power Button"></div>
                    <div class="volume-buttons">
                        <div class="volume-up" title="Volume Up"></div>
                        <div class="volume-down" title="Volume Down"></div>
                    </div>
                </div>
            </div>
            
            <!-- Keyboard shortcuts overlay -->
            <div class="shortcuts-overlay">
                <div class="shortcut-hint">Ctrl+R: Reload • Ctrl+Shift+R: Rotate • Ctrl+Shift+S: Screenshot</div>
            </div>
        </div>
    </div>
    
    <script nonce="${nonce}">
        const devicePresets = ${JSON.stringify(devicePresets)};
        const isPortrait = ${this._isPortrait};
        let currentDevice = devicePresets['${defaultDeviceName}'];
        let flutterAppUrl = '';
        const vscode = acquireVsCodeApi();
        const enableScreenshot = ${enableScreenshot};
        
        // Enhanced emulator configuration
        const emulatorConfig = {
            authenticLook: true,
            showPhysicalButtons: true,
            realisticStatusBar: true,
            smoothAnimations: true,
            touchFeedback: true
        };
    </script>
    <script nonce="${nonce}" src="${scriptUri}"></script>
    <script nonce="${nonce}" src="${touchEventsUri}"></script>
    <script nonce="${nonce}" src="${deviceAnimationsUri}"></script>
    <script nonce="${nonce}" src="${hotReloadUri}"></script>
</body>
</html>`;
        console.log('Generated enhanced webview HTML');
        return html;
    }
    dispose() {
        console.log('Disposing FlutterMultiEmulatorPanel');
        this._processManager.stopFlutterWebServer();
        FlutterMultiEmulatorPanel.currentPanel = undefined;
        this._panel.dispose();
        while (this._disposables.length) {
            const x = this._disposables.pop();
            if (x) {
                x.dispose();
            }
        }
    }
}
exports.FlutterMultiEmulatorPanel = FlutterMultiEmulatorPanel;
FlutterMultiEmulatorPanel.viewType = 'flutterMultiEmulator';
function getNonce() {
    let text = '';
    const possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    for (let i = 0; i < 32; i++) {
        text += possible.charAt(Math.floor(Math.random() * possible.length));
    }
    return text;
}
//# sourceMappingURL=FlutterMultiEmulatorPanel.js.map