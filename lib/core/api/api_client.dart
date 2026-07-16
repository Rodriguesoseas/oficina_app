import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({Dio? dio})
      : _dio = (dio ??
                Dio(
                  BaseOptions(
                    baseUrl: ApiConfig.baseUrl,
                    connectTimeout: const Duration(seconds: 60),
                    receiveTimeout: const Duration(seconds: 60),
                    headers: {
                      'Authorization': 'Bearer ${ApiConfig.apiToken}',
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                    },
                  ),
                ))
          ..interceptors.add(_RetryInterceptor());

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

    return ApiException(
      message: error.message ?? 'Falha de conexão com a API',
      statusCode: response?.statusCode,
    );
  }
}

class _RetryInterceptor extends QueuedInterceptor {
  static const _maxRetries = 3;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_deveRetentar(err)) {
      return handler.next(err);
    }

    final options = err.requestOptions;
    final attempt = (options.extra['_retryCount'] as int?) ?? 0;

    if (attempt >= _maxRetries) {
      return handler.next(err);
    }

    final delay = Duration(seconds: 2 * (1 << attempt));

    await Future.delayed(delay);

    options.extra['_retryCount'] = attempt + 1;

    try {
      final response = await Dio().fetch(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _deveRetentar(DioException err) {
    return err.type == DioExceptionType.connectionError;
  }
}
