import * as vscode from 'vscode';
import { FlutterMultiEmulatorPanel } from './FlutterMultiEmulatorPanel';
import { FlutterProcessManager } from './FlutterProcessManager';

export function activate(context: vscode.ExtensionContext) {
	console.log('Flutter Multi-Emulator extension is now activating');

	const processManager = new FlutterProcessManager();

	// Register commands
	const startCommand = vscode.commands.registerCommand('flutterMultiEmulator.start', () => {
		console.log('Starting Flutter Multi-Emulator');
		FlutterMultiEmulatorPanel.createOrShow(context.extensionUri, processManager);
	});

	const reloadCommand = vscode.commands.registerCommand('flutterMultiEmulator.reload', () => {
		console.log('Reloading Flutter Multi-Emulator');
		FlutterMultiEmulatorPanel.reload();
	});

	const rotateCommand = vscode.commands.registerCommand('flutterMultiEmulator.rotate', () => {
		console.log('Rotating Flutter Multi-Emulator');
		FlutterMultiEmulatorPanel.rotate();
	});

	const screenshotCommand = vscode.commands.registerCommand('flutterMultiEmulator.screenshot', () => {
		console.log('Taking screenshot from Flutter Multi-Emulator');
		FlutterMultiEmulatorPanel.takeScreenshot();
	});

	const showAllDevicesCommand = vscode.commands.registerCommand('flutterMultiEmulator.showAllDevices', () => {
		console.log('Showing all devices in Flutter Multi-Emulator');
		FlutterMultiEmulatorPanel.showAllDevices();
	});

	const openWebsiteCommand = vscode.commands.registerCommand('flutterMultiEmulator.openWebsite', () => {
		vscode.env.openExternal(vscode.Uri.parse('https://flutter.dev'));
	});

	// Watch for Dart file changes to trigger auto-reload
	const fileWatcher = vscode.workspace.createFileSystemWatcher('**/*.dart');
	fileWatcher.onDidChange((uri) => {
		const config = vscode.workspace.getConfiguration('flutterMultiEmulator');
		const autoReload = config.get<boolean>('autoReload', true);
		
		if (autoReload && FlutterMultiEmulatorPanel.currentPanel) {
			console.log('Dart file changed, triggering reload:', uri.fsPath);
			setTimeout(() => {
				FlutterMultiEmulatorPanel.reload();
			}, 500);
		}
	});

	context.subscriptions.push(
		startCommand,
		reloadCommand,
		rotateCommand,
		screenshotCommand,
		showAllDevicesCommand,
		openWebsiteCommand,
		fileWatcher
	);

	console.log('Flutter Multi-Emulator extension activated successfully');
}

export function deactivate() {
	console.log('Flutter Multi-Emulator extension is now deactivating');
	FlutterMultiEmulatorPanel.dispose();
}