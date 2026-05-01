// Flutter IDE Mobile - WebSocket Service for Live Run

import 'dart:async';
import 'dart:convert';

/// WebSocket message types
enum WebSocketMessageType {
  connection,
  status,
  output,
  error,
  log,
  hotReload,
  deviceInfo,
}

/// WebSocket message
class WebSocketMessage {
  final WebSocketMessageType type;
  final dynamic payload;
  final DateTime timestamp;

  WebSocketMessage({
    required this.type,
    this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: WebSocketMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WebSocketMessageType.output,
      ),
      payload: json['payload'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// WebSocket connection state
enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// WebSocket Service
/// Handles real-time communication with the compilation server
class WebSocketService {
  WebSocket? _socket;
  final String _url;
  final _messageController = StreamController<WebSocketMessage>.broadcast();
  final _connectionStateController =
      StreamController<WebSocketConnectionState>.broadcast();

  WebSocketConnectionState _connectionState = WebSocketConnectionState.disconnected;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 2);

  WebSocketService({String? url})
      : _url = url ?? 'ws://localhost:3000/ws';

  /// Stream of incoming messages
  Stream<WebSocketMessage> get messages => _messageController.stream;

  /// Stream of connection state changes
  Stream<WebSocketConnectionState> get connectionState =>
      _connectionStateController.stream;

  /// Current connection state
  WebSocketConnectionState get connectionState_ => _connectionState;

  /// Whether connected
  bool get isConnected => _connectionState == WebSocketConnectionState.connected;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_connectionState == WebSocketConnectionState.connected ||
        _connectionState == WebSocketConnectionState.connecting) {
      return;
    }

    _updateConnectionState(WebSocketConnectionState.connecting);

    try {
      _socket = WebSocket(_url);

      _socket!.onOpen = () {
        _updateConnectionState(WebSocketConnectionState.connected);
        _reconnectAttempts = 0;
        _startPingTimer();
      };

      _socket!.onMessage = (data) {
        try {
          final json = jsonDecode(data as String);
          final message = WebSocketMessage.fromJson(json);
          _messageController.add(message);
        } catch (e) {
          // Handle non-JSON messages
          _messageController.add(WebSocketMessage(
            type: WebSocketMessageType.output,
            payload: data,
          ));
        }
      };

      _socket!.onClose = (code, reason) {
        _updateConnectionState(WebSocketConnectionState.disconnected);
        _stopPingTimer();
        _attemptReconnect();
      };

      _socket!.onError = (error) {
        _updateConnectionState(WebSocketConnectionState.error);
        _attemptReconnect();
      };
    } catch (e) {
      _updateConnectionState(WebSocketConnectionState.error);
      _attemptReconnect();
    }
  }

  /// Disconnect from WebSocket server
  void disconnect() {
    _stopReconnectTimer();
    _stopPingTimer();
    _socket?.close();
    _socket = null;
    _updateConnectionState(WebSocketConnectionState.disconnected);
  }

  /// Send a message
  void send(WebSocketMessage message) {
    if (!isConnected) return;
    _socket?.add(jsonEncode(message.toJson()));
  }

  /// Send raw text
  void sendRaw(String text) {
    if (!isConnected) return;
    _socket?.add(text);
  }

  /// Send compilation request
  void sendCompilationRequest({
    required String sessionId,
    required String code,
    Map<String, String>? files,
  }) {
    send(WebSocketMessage(
      type: WebSocketMessageType.status,
      payload: {
        'action': 'compile',
        'sessionId': sessionId,
        'code': code,
        if (files != null) 'files': files,
      },
    ));
  }

  /// Request hot reload
  void requestHotReload(String sessionId) {
    send(WebSocketMessage(
      type: WebSocketMessageType.hotReload,
      payload: {'sessionId': sessionId},
    ));
  }

  /// Request device info
  void requestDeviceInfo(String sessionId) {
    send(WebSocketMessage(
      type: WebSocketMessageType.deviceInfo,
      payload: {'sessionId': sessionId},
    ));
  }

  /// Update connection state
  void _updateConnectionState(WebSocketConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  /// Attempt to reconnect
  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _updateConnectionState(WebSocketConnectionState.error);
      return;
    }

    _updateConnectionState(WebSocketConnectionState.reconnecting);
    _reconnectAttempts++;

    _reconnectTimer = Timer(_reconnectDelay, () {
      connect();
    });
  }

  /// Start ping timer to keep connection alive
  void _startPingTimer() {
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      send(WebSocketMessage(
        type: WebSocketMessageType.connection,
        payload: {'action': 'ping'},
      ));
    });
  }

  /// Stop ping timer
  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// Stop reconnect timer
  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Dispose
  void dispose() {
    disconnect();
    _messageController.close();
    _connectionStateController.close();
  }
}

/// WebSocket wrapper for Flutter (using dart:io)
class WebSocket {
  final dynamic _inner;
  final _messageController = StreamController<dynamic>.broadcast();

  Function()? onOpen;
  Function(dynamic)? onMessage;
  Function(dynamic)? onClose;
  Function(dynamic)? onError;

  WebSocket._(this._inner) {
    // In a real implementation, this would wrap dart:io WebSocket
    // For now, this is a placeholder that demonstrates the interface
  }

  static Future<WebSocket> connect(String url) async {
    // In production, this would use dart:io WebSocket
    // import 'dart:io';
    // return WebSocket._(await WebSocket.connect(url));
    throw UnimplementedError('WebSocket.connect requires dart:io');
  }

  void add(dynamic data) {
    // _inner.add(data);
  }

  void close([int? code, String? reason]) {
    // _inner.close(code, reason);
  }

  Stream<dynamic> get messages => _messageController.stream;
}

/// Extension for easy message handling
extension WebSocketMessageExtensions on Stream<WebSocketMessage> {
  /// Filter for output messages
  Stream<WebSocketMessage> get output =>
      where((m) => m.type == WebSocketMessageType.output);

  /// Filter for error messages
  Stream<WebSocketMessage> get errors =>
      where((m) => m.type == WebSocketMessageType.error);

  /// Filter for log messages
  Stream<WebSocketMessage> get logs =>
      where((m) => m.type == WebSocketMessageType.log);

  /// Filter for hot reload messages
  Stream<WebSocketMessage> get hotReloads =>
      where((m) => m.type == WebSocketMessageType.hotReload);

  /// Filter for status messages
  Stream<WebSocketMessage> get status =>
      where((m) => m.type == WebSocketMessageType.status);
}