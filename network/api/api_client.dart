// Flutter IDE Mobile - Network Layer - API Client

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/exceptions.dart';

/// API Configuration
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';
  static const Duration timeout = Duration(seconds: 30);
}

/// API Response wrapper
class ApiResponse<T> {
  final T? data;
  final String? error;
  final int statusCode;
  final bool isSuccess;

  const ApiResponse({
    this.data,
    this.error,
    required this.statusCode,
  }) : isSuccess = statusCode >= 200 && statusCode < 300;

  factory ApiResponse.success(T data, int statusCode) => ApiResponse(
        data: data,
        statusCode: statusCode,
      );

  factory ApiResponse.error(String error, int statusCode) => ApiResponse(
        error: error,
        statusCode: statusCode,
      );
}

/// HTTP Methods
enum HttpMethod { get, post, put, delete, patch }

/// Network API Client
class ApiClient {
  final String baseUrl;
  final http.Client _client;
  final Map<String, String> _defaultHeaders;

  ApiClient({
    String? baseUrl,
    http.Client? client,
    Map<String, String>? headers,
  })  : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _client = client ?? http.Client(),
        _defaultHeaders = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        };

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? queryParams,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      method: HttpMethod.get,
      path: path,
      queryParams: queryParams,
      parser: parser,
    );
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      method: HttpMethod.post,
      path: path,
      body: body,
      parser: parser,
    );
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      method: HttpMethod.put,
      path: path,
      body: body,
      parser: parser,
    );
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      method: HttpMethod.delete,
      path: path,
      parser: parser,
    );
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic body,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      method: HttpMethod.patch,
      path: path,
      body: body,
      parser: parser,
    );
  }

  /// Internal request handler
  Future<ApiResponse<T>> _request<T>({
    required HttpMethod method,
    required String path,
    Map<String, String>? queryParams,
    dynamic body,
    T Function(dynamic)? parser,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$path');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = Map<String, String>.from(_defaultHeaders);
      String? bodyStr;
      
      if (body != null) {
        if (body is String) {
          bodyStr = body;
        } else {
          bodyStr = jsonEncode(body);
        }
      }

      http.Response response;
      switch (method) {
        case HttpMethod.get:
          response = await _client
              .get(uri, headers: headers)
              .timeout(ApiConfig.timeout);
          break;
        case HttpMethod.post:
          response = await _client
              .post(uri, headers: headers, body: bodyStr)
              .timeout(ApiConfig.timeout);
          break;
        case HttpMethod.put:
          response = await _client
              .put(uri, headers: headers, body: bodyStr)
              .timeout(ApiConfig.timeout);
          break;
        case HttpMethod.delete:
          response = await _client
              .delete(uri, headers: headers)
              .timeout(ApiConfig.timeout);
          break;
        case HttpMethod.patch:
          response = await _client
              .patch(uri, headers: headers, body: bodyStr)
              .timeout(ApiConfig.timeout);
          break;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (parser != null && response.body.isNotEmpty) {
          final parsed = jsonDecode(response.body);
          return ApiResponse.success(parser(parsed), response.statusCode);
        }
        return ApiResponse.success(
          null as T,
          response.statusCode,
        );
      } else {
        String errorMsg = 'Request failed';
        try {
          final errorJson = jsonDecode(response.body);
          errorMsg = errorJson['message'] ?? errorJson['error'] ?? errorMsg;
        } catch (_) {}
        return ApiResponse.error(errorMsg, response.statusCode);
      }
    } on http.ClientException catch (e) {
      return ApiResponse.error('Network error: ${e.message}', 0);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e', 0);
    }
  }

  /// Close the client
  void close() {
    _client.close();
  }
}

/// Compilation API Endpoints
class CompilerApi {
  final ApiClient _client;

  CompilerApi({ApiClient? client}) : _client = client ?? ApiClient();

  /// Compile Dart code
  Future<ApiResponse<CompilationResult>> compile({
    required String code,
    String? mainFile,
    Map<String, String>? files,
  }) async {
    final response = await _client.post<CompilationResult>(
      '/compile',
      body: {
        'code': code,
        if (mainFile != null) 'mainFile': mainFile,
        if (files != null) 'files': files,
      },
      parser: (json) => CompilationResult.fromJson(json),
    );

    return response;
  }

  /// Get compilation status
  Future<ApiResponse<CompilationStatus>> getStatus(String sessionId) async {
    return _client.get<CompilationStatus>(
      '/status/$sessionId',
      parser: (json) => CompilationStatus.fromJson(json),
    );
  }

  /// Cancel compilation
  Future<ApiResponse<void>> cancelCompilation(String sessionId) async {
    return _client.delete<void>('/compile/$sessionId');
  }

  /// Run the compiled app
  Future<ApiResponse<RunResult>> run({
    required String sessionId,
    String? deviceId,
  }) async {
    return _client.post<RunResult>(
      '/run',
      body: {
        'sessionId': sessionId,
        if (deviceId != null) 'deviceId': deviceId,
      },
      parser: (json) => RunResult.fromJson(json),
    );
  }
}

/// Compilation result model
class CompilationResult {
  final bool success;
  final String? sessionId;
  final String? output;
  final String? error;
  final List<CompilationError> errors;
  final List<CompilationWarning> warnings;
  final String? webUrl;

  const CompilationResult({
    required this.success,
    this.sessionId,
    this.output,
    this.error,
    this.errors = const [],
    this.warnings = const [],
    this.webUrl,
  });

  factory CompilationResult.fromJson(Map<String, dynamic> json) {
    return CompilationResult(
      success: json['success'] as bool? ?? false,
      sessionId: json['sessionId'] as String?,
      output: json['output'] as String?,
      error: json['error'] as String?,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => CompilationError.fromJson(e))
              .toList() ??
          [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((w) => CompilationWarning.fromJson(w))
              .toList() ??
          [],
      webUrl: json['webUrl'] as String?,
    );
  }
}

/// Compilation status model
class CompilationStatus {
  final String sessionId;
  final String status; // pending, compiling, success, error
  final double? progress;
  final String? message;
  final String? output;
  final String? error;

  const CompilationStatus({
    required this.sessionId,
    required this.status,
    this.progress,
    this.message,
    this.output,
    this.error,
  });

  factory CompilationStatus.fromJson(Map<String, dynamic> json) {
    return CompilationStatus(
      sessionId: json['sessionId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      progress: (json['progress'] as num?)?.toDouble(),
      message: json['message'] as String?,
      output: json['output'] as String?,
      error: json['error'] as String?,
    );
  }
}

/// Run result model
class RunResult {
  final bool success;
  final String? url;
  final String? error;

  const RunResult({
    required this.success,
    this.url,
    this.error,
  });

  factory RunResult.fromJson(Map<String, dynamic> json) {
    return RunResult(
      success: json['success'] as bool? ?? false,
      url: json['url'] as String?,
      error: json['error'] as String?,
    );
  }
}

/// Compilation error model (for API)
class CompilationError {
  final int line;
  final int column;
  final String message;
  final String severity;
  final String? source;

  const CompilationError({
    required this.line,
    required this.column,
    required this.message,
    required this.severity,
    this.source,
  });

  factory CompilationError.fromJson(Map<String, dynamic> json) {
    return CompilationError(
      line: json['line'] as int? ?? 0,
      column: json['column'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      severity: json['severity'] as String? ?? 'error',
      source: json['source'] as String?,
    );
  }
}

/// Compilation warning model (for API)
class CompilationWarning {
  final int line;
  final int column;
  final String message;
  final String? source;

  const CompilationWarning({
    required this.line,
    required this.column,
    required this.message,
    this.source,
  });

  factory CompilationWarning.fromJson(Map<String, dynamic> json) {
    return CompilationWarning(
      line: json['line'] as int? ?? 0,
      column: json['column'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      source: json['source'] as String?,
    );
  }
}