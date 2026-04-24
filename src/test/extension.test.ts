import * as assert from 'assert';
import * as vscode from 'vscode';
import * as path from 'path';

suite('Extension Test Suite', () => {
	vscode.window.showInformationMessage('Start all tests.');

	test('Extension should be present', () => {
		assert.ok(vscode.extensions.getExtension('your-publisher.flutter-multi-emulator'));
	});

	test('Should activate extension', async () => {
		const ext = vscode.extensions.getExtension('your-publisher.flutter-multi-emulator');
		if (ext) {
			await ext.activate();
			assert.ok(ext.isActive);
		}
	});
});