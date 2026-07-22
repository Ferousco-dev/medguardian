import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.title,
    this.statusCode,
    this.kind = ApiErrorKind.unknown,
  });

  final String message;
  final String? title;
  final int? statusCode;
  final ApiErrorKind kind;

  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ApiException(
          kind: ApiErrorKind.timeout,
          title: 'This is taking too long',
          message:
              'The server did not answer in time. It may be busy, or your '
              'connection may be slow.',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          kind: ApiErrorKind.network,
          title: 'No connection',
          message:
              'MedGuardian cannot reach the server. Check your internet and '
              'try again.',
        );
      case DioExceptionType.cancel:
        return const ApiException(
          kind: ApiErrorKind.cancelled,
          title: 'Cancelled',
          message: 'That request was cancelled.',
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          kind: ApiErrorKind.network,
          title: 'Connection is not secure',
          message:
              'The server certificate could not be verified, so MedGuardian '
              'stopped the request. Health data is never sent over an '
              'untrusted connection.',
        );
      case DioExceptionType.badResponse:
        return _fromStatus(error.response);
      case DioExceptionType.unknown:
        return const ApiException(
          kind: ApiErrorKind.unknown,
          title: 'Something went wrong',
          message: 'That did not work. Please try again.',
        );
    }
  }

  static ApiException _fromStatus(Response<dynamic>? response) {
    final int? status = response?.statusCode;
    final String? serverMessage = _messageFromResponse(response);

    return switch (status) {
      400 || 422 => ApiException(
        kind: ApiErrorKind.validation,
        statusCode: status,
        title: 'Check what you entered',
        message: serverMessage ?? 'Some of that information was not accepted.',
      ),
      401 => ApiException(
        kind: ApiErrorKind.unauthorised,
        statusCode: status,
        title: 'Please sign in again',
        message:
            serverMessage ??
            'Your session has expired. Signing in again keeps your record '
                'secure.',
      ),
      403 => ApiException(
        kind: ApiErrorKind.forbidden,
        statusCode: status,
        title: 'Not allowed',
        message: serverMessage ?? 'You do not have access to that.',
      ),
      404 => ApiException(
        kind: ApiErrorKind.notFound,
        statusCode: status,
        title: 'Not found',
        message: serverMessage ?? 'That record no longer exists.',
      ),
      429 => ApiException(
        kind: ApiErrorKind.rateLimited,
        statusCode: status,
        title: 'Slow down a moment',
        message:
            serverMessage ??
            'Too many requests in a short time. Wait a few seconds and try '
                'again.',
      ),
      _ => ApiException(
        kind: ApiErrorKind.server,
        statusCode: status,
        title: 'The server had a problem',
        message:
            serverMessage ??
            'This is not something you did. Try again shortly.',
      ),
    };
  }

  static String? _messageFromResponse(Response<dynamic>? response) {
    final dynamic data = response?.data;
    if (data is Map<String, dynamic>) {
      for (final String key in <String>['detail', 'message', 'error']) {
        final dynamic value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

enum ApiErrorKind {
  network,
  timeout,
  unauthorised,
  forbidden,
  notFound,
  validation,
  rateLimited,
  server,
  cancelled,
  unknown,
}
