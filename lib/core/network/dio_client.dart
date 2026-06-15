import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import 'token_storage.dart';

class DioClient {
  final TokenStorage _tokenStorage;
  late final Dio _dio;

  // Prevents concurrent refresh attempts
  bool _isRefreshing = false;
  final List<Completer<void>> _refreshQueue = [];

  // Stream for signalling logout to the app
  final StreamController<void> _unauthorizedController =
      StreamController<void>.broadcast();
  Stream<void> get onUnauthorized => _unauthorizedController.stream;

  DioClient(this._tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (o) => dev.log(o.toString(), name: 'DIO'),
      ),
    );
  }

  Dio get dio => _dio;

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      // Avoid intercepting the refresh call itself
      if (error.requestOptions.path == ApiConstants.tokenRefresh) {
        await _tokenStorage.clearTokens();
        _unauthorizedController.add(null);
        handler.next(error);
        return;
      }

      if (_isRefreshing) {
        // Queue this request until refresh completes
        final completer = Completer<void>();
        _refreshQueue.add(completer);
        await completer.future;
        // Retry with new token
        final retried = await _retry(error.requestOptions);
        handler.resolve(retried);
        return;
      }

      _isRefreshing = true;
      try {
        final refreshToken = await _tokenStorage.getRefreshToken();
        if (refreshToken == null) throw const UnauthorizedException();

        final response = await _dio.post(
          ApiConstants.tokenRefresh,
          data: {'refresh': refreshToken},
          options: Options(headers: {'Authorization': null}),
        );

        final newAccess = response.data['access'] as String;
        final newRefresh = response.data['refresh'] as String? ?? refreshToken;
        await _tokenStorage.saveTokens(access: newAccess, refresh: newRefresh);

        // Complete all queued requests
        for (final c in _refreshQueue) {
          c.complete();
        }
        _refreshQueue.clear();

        final retried = await _retry(error.requestOptions);
        handler.resolve(retried);
      } catch (_) {
        for (final c in _refreshQueue) {
          c.completeError(error);
        }
        _refreshQueue.clear();
        await _tokenStorage.clearTokens();
        _unauthorizedController.add(null);
        handler.next(error);
      } finally {
        _isRefreshing = false;
      }
      return;
    }

    handler.reject(_mapError(error));
  }

  Future<Response> _retry(RequestOptions options) {
    final token = _tokenStorage.getAccessToken();
    return token.then((t) {
      return _dio.request(
        options.path,
        data: options.data,
        queryParameters: options.queryParameters,
        options: Options(
          method: options.method,
          headers: {
            ...options.headers,
            if (t != null) 'Authorization': 'Bearer $t',
          },
        ),
      );
    });
  }

  DioException _mapError(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;

    dev.log(
      'HTTP $status ${error.requestOptions.method} ${error.requestOptions.path}\n'
      'body: $data\ntype: ${error.type}',
      name: 'DIO_ERROR',
    );

    String message = 'حدث خطأ غير متوقع';
    if (data is Map) {
      // Try standard single-message keys first
      final single = data['detail'] ?? data['message'] ?? data['error'];
      if (single != null) {
        message = single.toString();
      } else {
        // DRF field-level errors: {field: ["msg", ...], ...}
        final parts = <String>[];
        for (final value in data.values) {
          if (value is List) {
            parts.addAll(value.map((e) => e.toString()));
          } else if (value != null) {
            parts.add(value.toString());
          }
        }
        if (parts.isNotEmpty) message = parts.join('\n');
      }
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    ApiException apiException;

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.unknown) {
      apiException = const NetworkException();
    } else {
      switch (status) {
        case 400:
          apiException = ValidationException(
            message,
            errors: data is Map ? Map<String, dynamic>.from(data) : {},
          );
        case 401:
          apiException = UnauthorizedException(message);
        case 403:
          apiException = ForbiddenException(message);
        case 404:
          apiException = NotFoundException(message);
        default:
          apiException = ServerException(message);
      }
    }

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: apiException,
      message: apiException.message,
    );
  }

  // ── Convenience wrappers ────────────────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get(path,
          queryParameters: queryParameters, options: options);

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post(path,
          data: data, queryParameters: queryParameters, options: options);

  Future<Response> patch(
    String path, {
    dynamic data,
    Options? options,
  }) =>
      _dio.patch(path, data: data, options: options);

  Future<Response> delete(String path, {Options? options}) =>
      _dio.delete(path, options: options);

  // Decodes a JWT payload without verifying signature (client-side only)
  static Map<String, dynamic> decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(payload));
    return Map<String, dynamic>.from(jsonDecode(decoded));
  }
}
