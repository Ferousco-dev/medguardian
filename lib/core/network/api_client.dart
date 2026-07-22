import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_store.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

class ApiClient {
  ApiClient({required TokenStore tokenStore, Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );
    _dio.interceptors.add(AuthInterceptor(tokenStore));
  }

  final Dio _dio;

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) {
    return _send<T>(() => _dio.get<T>(path, queryParameters: query));
  }

  Future<T> post<T>(String path, {Object? body, Map<String, dynamic>? query}) {
    return _send<T>(
      () => _dio.post<T>(path, data: body, queryParameters: query),
    );
  }

  Future<T> patch<T>(String path, {Object? body}) {
    return _send<T>(() => _dio.patch<T>(path, data: body));
  }

  Future<T> put<T>(String path, {Object? body}) {
    return _send<T>(() => _dio.put<T>(path, data: body));
  }

  Future<T> delete<T>(String path, {Object? body}) {
    return _send<T>(() => _dio.delete<T>(path, data: body));
  }

  Future<T> _send<T>(Future<Response<T>> Function() request) async {
    try {
      final Response<T> response = await request();
      final T? data = response.data;
      if (data == null) {
        throw const ApiException(message: 'The server returned no content.');
      }
      return data;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
