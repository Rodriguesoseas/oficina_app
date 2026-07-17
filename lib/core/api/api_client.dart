import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({Dio? dio})
      : _dio = (dio ??
                Dio(
                  BaseOptions(
                    baseUrl: ApiConfig.baseUrl,
                    connectTimeout: const Duration(seconds: 120),
                    receiveTimeout: const Duration(seconds: 120),
                    headers: {
                      'Authorization': 'Bearer ${ApiConfig.apiToken}',
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                    },
                  ),
                ))
          ..interceptors.add(_LogInterceptor());

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      () => _dio.get<dynamic>(path, queryParameters: queryParameters),
      parser: parser,
    );
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      () => _dio.post<dynamic>(path, data: data),
      parser: parser,
    );
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic data)? parser,
  }) async {
    return _request(
      () => _dio.patch<dynamic>(path, data: data),
      parser: parser,
    );
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete<dynamic>(path);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<T> _request<T>(
    Future<Response<dynamic>> Function() call, {
    T Function(dynamic data)? parser,
  }) async {
    try {
      final response = await call();
      final body = response.data;

      if (parser != null) {
        return parser(body);
      }

      return body as T;
    } on DioException catch (error) {
      developer.log(
        '[API] ${error.type.name}: ${error.message}',
        name: 'ApiClient',
      );
      throw _mapError(error);
    }
  }

  ApiException _mapError(DioException error) {
    final response = error.response;
    final data = response?.data;

    if (data is Map<String, dynamic> && data['error'] is Map) {
      final apiError = data['error'] as Map<String, dynamic>;
      return ApiException(
        message: apiError['message']?.toString() ?? 'Erro na API',
        code: apiError['code']?.toString(),
        statusCode: response?.statusCode,
        details: apiError['details'],
      );
    }

    final tipo = error.type;
    final mensagem = error.message ?? 'Falha de conexão com a API';

    return ApiException(
      message: tipo == DioExceptionType.connectionTimeout
          ? 'O servidor demorou muito para responder. Verifique sua internet e tente novamente.'
          : tipo == DioExceptionType.receiveTimeout
              ? 'O servidor demorou muito para enviar os dados.'
              : tipo == DioExceptionType.connectionError
                  ? 'Não foi possível conectar ao servidor.'
                  : mensagem,
      statusCode: response?.statusCode,
    );
  }
}

class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '[API] ${options.method} ${options.baseUrl}${options.path}',
      name: 'ApiClient',
    );
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '[API] Erro ${err.type.name}: ${err.message}',
      name: 'ApiClient',
    );
    handler.next(err);
  }
}
