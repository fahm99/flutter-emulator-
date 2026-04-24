export declare class FlutterProcessManager {
    private flutterProcess;
    private serverUrl;
    private isRunning;
    constructor();
    startFlutterWebServer(isRelease?: boolean, customFlags?: string[]): Promise<string>;
    private checkFlutterInstallation;
    stopFlutterWebServer(): void;
    isFlutterRunning(): boolean;
    getServerUrl(): string;
}
