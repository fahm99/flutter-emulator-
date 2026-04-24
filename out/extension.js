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
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = activate;
exports.deactivate = deactivate;
const vscode = __importStar(require("vscode"));
const FlutterMultiEmulatorPanel_1 = require("./FlutterMultiEmulatorPanel");
const FlutterProcessManager_1 = require("./FlutterProcessManager");
function activate(context) {
    console.log('Flutter Multi-Emulator extension is now activating');
    const processManager = new FlutterProcessManager_1.FlutterProcessManager();
    // Register commands
    const startCommand = vscode.commands.registerCommand('flutterMultiEmulator.start', () => {
        console.log('Starting Flutter Multi-Emulator');
        FlutterMultiEmulatorPanel_1.FlutterMultiEmulatorPanel.createOrShow(context.extensionUri, processManager);
    });
    const reloadCommand = vscode.commands.registerCommand('flutterMultiEmulator.reload', () => {
        console.log('Reloading Flutter Multi-Emulator');
        FlutterMultiEmulatorPanel_1.FlutterMultiEmulatorPanel.reload();
    });
    const rotateCommand = vscode.commands.registerCommand('flutterMultiEmulator.rotate', () => {
        console.log('Rotating Flutter Multi-Emulator');
        FlutterMultiEmulatorPanel_1.FlutterMultiEmulatorPanel.rotate();
    });
    const screenshotCommand = vscode.commands.registerCommand('flutterMultiEmulator.screenshot', () => {
        console.log('Taking screenshot from Flutter Multi-Emulator');
        FlutterMultiEmulatorPanel_1.FlutterMultiEmulatorPanel.takeScreenshot();
    });
    const showAllDevicesCommand = vscode.commands.registerCommand('flutterMultiEmulator.showAllDevices', () => {
        console.log('Showing all devices in Flutter Multi-Emulator');
        FlutterMultiEmulatorPanel_1.FlutterMultiEmulatorPanel.showAllDevices();
    });
    const openWebsiteCommand = vscode.commands.registerCommand('flutterMultiEmulator.openWebsite', () => {
        vscode.env.openExternal(vscode.Uri.parse('https://flutter.dev'));
    });
    // Watch for Dart file changes to trigger auto-reload
    const fileWatcher = vscode.workspace.createFileSystemWatcher('**/*.dart');
    fileWatcher.onDidChange((uri) => {
        const config = vscode.workspace.getConfiguration('flutterMultiEmulator');
        const autoReload = config.get('autoReload', true);
        if (autoReload && FlutterMultiEmulatorPanel_1.FlutterMultiEmulatorPanel.currentPanel) {
            console.log('Dart file changed, triggering reload:', uri.fsPath);
            setTimeout(() => {
                FlutterMultiEmulatorPanel_1.FlutterMultiEmulatorPanel.reload();
            }, 500);
        }
    });
    context.subscriptions.push(startCommand, reloadCommand, rotateCommand, screenshotCommand, showAllDevicesCommand, openWebsiteCommand, fileWatcher);
    console.log('Flutter Multi-Emulator extension activated successfully');
}
function deactivate() {
    console.log('Flutter Multi-Emulator extension is now deactivating');
    FlutterMultiEmulatorPanel_1.FlutterMultiEmulatorPanel.dispose();
}
//# sourceMappingURL=extension.js.map