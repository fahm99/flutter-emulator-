import * as vscode from 'vscode';
export declare class FlutterMultiEmulatorPanel {
    static currentPanel: FlutterMultiEmulatorPanel | undefined;
    private static readonly viewType;
    private readonly _panel;
    private readonly _extensionUri;
    private readonly _processManager;
    private _disposables;
    private _isPortrait;
    private _currentDevice;
    static createOrShow(extensionUri: vscode.Uri, processManager: any): vscode.WebviewPanel | undefined;
    static reload(): void;
    static rotate(): void;
    static takeScreenshot(): void;
    static showAllDevices(): void;
    static dispose(): void;
    private constructor();
    private _startFlutterProcess;
    private _reload;
    private _rotate;
    private _takeScreenshot;
    private _showAllDevices;
    private _handleScreenshotCapture;
    private _update;
    private _getHtmlForWebview;
    dispose(): void;
}
