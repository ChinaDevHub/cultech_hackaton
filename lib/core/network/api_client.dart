import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../error/exceptions.dart';

typedef JsonMap = Map<String, dynamic>;

/// Thin, typed HTTP client shared by every remote data source.
///
/// CORS readiness (Flutter Web):
/// * Only CORS-safelisted headers are sent by default (`Accept`); the
///   `Content-Type: application/json` and `Authorization` headers are added
///   per request only when needed, keeping preflight requests minimal.
/// * `withCredentials` is explicitly `false`, so the backend may answer with
///   `Access-Control-Allow-Origin: *` without cookies being involved.
/// * No `sendTimeout` on the web — browsers cannot enforce it on body-less
///   requests and Dio would otherwise reject them.
/// * Opaque XHR failures (how browsers surface blocked CORS) are mapped to a
///   [NetworkException] flagged with [NetworkException.isLikelyCors].
///
/// The backend is expected to respond to `OPTIONS` with:
/// `Access-Control-Allow-Origin`, `Access-Control-Allow-Methods: GET, POST`
/// and `Access-Control-Allow-Headers: Authorization, Content-Type`.
final class ApiClient {
  ApiClient({required AppConfig config, Dio? dio})
    : _dio = dio ?? Dio(_baseOptions(config)) {
    if (config.apiKey.isNotEmpty) {
      _dio.interceptors.add(_BearerAuthInterceptor(config.apiKey));
    }
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          logPrint: (Object line) => debugPrint('[CultGuard API] $line'),
        ),
      );
    }
  }

  final Dio _dio;

  static BaseOptions _baseOptions(AppConfig config) {
    return BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      sendTimeout: kIsWeb ? null : AppConfig.connectTimeout,
      headers: const <String, Object>{Headers.acceptHeader: 'application/json'},
      extra: const <String, Object>{'withCredentials': false},
    );
  }

  Future<JsonMap> getJson(String path, {JsonMap? query}) async {
    final Object? data = await _send(
      () => _dio.get<Object?>(path, queryParameters: query),
    );
    return _asMap(data);
  }

  Future<List<JsonMap>> getJsonList(String path, {JsonMap? query}) async {
    final Object? data = await _send(
      () => _dio.get<Object?>(path, queryParameters: query),
    );
    if (data is! List<Object?>) {
      throw const ServerException('Serverdən gözlənilməz cavab formatı.');
    }
    return data.map(_asMap).toList(growable: false);
  }

  Future<JsonMap> postJson(String path, {Object? body}) async {
    final Object? data = await _send(
      () => _dio.post<Object?>(
        path,
        data: body,
        options: Options(contentType: Headers.jsonContentType),
      ),
    );
    return _asMap(data);
  }

  Future<Object?> _send(Future<Response<Object?>> Function() request) async {
    try {
      final Response<Object?> response = await request();
      return response.data;
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  static JsonMap _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    throw const ServerException('Serverdən gözlənilməz cavab formatı.');
  }

  static AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const NetworkException('Server vaxtında cavab vermədi.');
      case DioExceptionType.badResponse:
        final int? status = error.response?.statusCode;
        return ServerException(
          _messageFromBody(error.response?.data) ??
              'Server xətası (${status ?? 'naməlum'}).',
          statusCode: status,
        );
      case DioExceptionType.cancel:
        return const NetworkException('Sorğu ləğv edildi.');
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return NetworkException(
          kIsWeb
              ? 'Serverə qoşulmaq mümkün olmadı (şəbəkə və ya CORS siyasəti).'
              : 'Serverə qoşulmaq mümkün olmadı.',
          isLikelyCors: kIsWeb && error.response == null,
        );
    }
  }

  static String? _messageFromBody(Object? body) {
    if (body is Map<String, dynamic>) {
      final Object? message = body['message'] ?? body['error'];
      if (message is String && message.isNotEmpty) return message;
    }
    return null;
  }
}

final class _BearerAuthInterceptor extends Interceptor {
  _BearerAuthInterceptor(this._apiKey);

  final String _apiKey;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer $_apiKey';
    handler.next(options);
  }
}
