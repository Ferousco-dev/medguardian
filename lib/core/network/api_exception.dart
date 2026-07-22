import 'package:dio/dio.dart';

/// A failure the UI can render directly.
///
/// Dio errors are translated into one of these at the client boundary so no
/// widget or repository ever has to know about `DioException`.
class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.kind = ApiErrorKind.unknown,
  });

  final String message;
  final int? statusCode;
  final ApiErrorKind kind;

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          message: 'The request took too long. Check your connection and try '
              'again.',
          kind: ApiErrorKind.timeout,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'Cannot reach the server. Check your connection.',
          kind: ApiErrorKind.network,
        );
      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request cancelled.',
          kind: ApiErrorKind.cancelled,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          message: _messageFromResponse(error.response),
          statusCode: error.response?.statusCode,
          kind: error.response?.statusCode == 401
              ? ApiErrorKind.unauthorised
              : ApiErrorKind.server,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const ApiException(
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  /// Prefers the API's own error text so backend validation messages reach the
  /// user unchanged.
  static String _messageFromResponse(Response<dynamic>? response) {
    final dynamic data = response?.data;
    if (data is Map<String, dynamic>) {
      for (final String key in <String>['detail', 'message', 'error']) {
        final dynamic value = data[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }
    return 'Request failed with status ${response?.statusCode ?? 'unknown'}.';
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

enum ApiErrorKind {
  network,
  timeout,
  unauthorised,
  server,
  cancelled,
  unknown,
}
