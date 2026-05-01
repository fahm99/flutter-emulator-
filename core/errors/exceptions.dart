// Flutter IDE Mobile - Error Handling System

/// Base class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Network related exceptions
class NetworkException extends AppException {
  final int? statusCode;

  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.statusCode,
  });

  @override
  String toString() =>
      'NetworkException: $message (status: $statusCode, code: $code)';
}

/// Compilation related exceptions
class CompilationException extends AppException {
  final List<CompilationError> errors;
  final String? output;

  const CompilationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.errors = const [],
    this.output,
  });

  @override
  String toString() =>
      'CompilationException: $message (errors: ${errors.length})';
}

/// Individual compilation error
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

  Map<String, dynamic> toJson() => {
        'line': line,
        'column': column,
        'message': message,
        'severity': severity,
        if (source != null) 'source': source,
      };
}

/// File system related exceptions
class FileSystemException extends AppException {
  final String? path;

  const FileSystemException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.path,
  });

  @override
  String toString() => 'FileSystemException: $message (path: $path)';
}

/// Editor related exceptions
class EditorException extends AppException {
  const EditorException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'EditorException: $message';
}

/// Emulator related exceptions
class EmulatorException extends AppException {
  const EmulatorException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'EmulatorException: $message';
}

/// Validation exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'ValidationException: $message (fields: $fieldErrors)';
}

/// Result type for operations that can fail
class Result<T> {
  final T? data;
  final AppException? error;
  final bool isSuccess;

  const Result._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory Result.success(T data) => Result._(
        data: data,
        isSuccess: true,
      );

  factory Result.failure(AppException error) => Result._(
        error: error,
        isSuccess: false,
      );

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    if (isSuccess && data != null) {
      return success(data as T);
    }
    return failure(error!);
  }

  R? whenOrNull<R>({
    R Function(T data)? success,
    R Function(AppException error)? failure,
  }) {
    if (isSuccess && data != null) {
      return success?.call(data as T);
    }
    return failure?.call(error!);
  }
}

/// Extension for handling async operations with Result
extension ResultAsyncExtension<T> on Future<Result<T>> {
  Future<R> map<R>(R Function(T data) mapper) async {
    final result = await this;
    return result.when(
      success: (data) => mapper(data),
      failure: (error) => throw error,
    );
  }
}