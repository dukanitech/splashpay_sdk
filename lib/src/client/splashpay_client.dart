import 'package:dio/dio.dart';

import '../config/splashpay_config.dart';
import '../exceptions/splashpay_exception.dart';
import '../models/payment_response.dart';
import '../utils/idempotency.dart';

/// Low-level HTTP client for SplashPay API requests.
class SplashPayClient {
  /// Creates a [SplashPayClient] with the given configuration.
  SplashPayClient(this._config, {Dio? dio}) {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: _config.baseUrl,
            connectTimeout: _config.connectTimeout,
            receiveTimeout: _config.receiveTimeout,
            sendTimeout: _config.sendTimeout,
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
            validateStatus: (_) => true,
          ),
        );
  }

  final SplashPayConfig _config;
  late final Dio _dio;

  /// Exposes the underlying Dio instance for testing.
  Dio get dio => _dio;

  /// Performs a POST request to a SplashPay endpoint.
  Future<PaymentResponse> post(
    String path, {
    required Map<String, dynamic> body,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey != null
        ? Idempotency.resolveKey(requestBody: body, explicitKey: idempotencyKey)
        : null;

    final headers = _config.authHeaders(idempotencyKey: key);

    _log('POST $path');

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
        options: Options(headers: headers),
      );

      return _handleResponse(response);
    } on SplashPayException {
      rethrow;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw SplashPayException(
        message: 'Unexpected error: $e',
        data: e,
      );
    }
  }

  PaymentResponse _handleResponse(Response<Map<String, dynamic>> response) {
    final statusCode = response.statusCode;
    final data = response.data;

    if (data == null) {
      throw SplashPayInvalidResponseException(
        message: 'Empty response body',
        statusCode: statusCode,
      );
    }

    if (statusCode == 401 || data['code'] == 'UNAUTHORIZED') {
      throw SplashPayAuthenticationException(
        message: data['message'] as String? ?? 'Invalid API credentials.',
        code: data['code'] as String?,
        statusCode: statusCode,
        data: data,
      );
    }

    if (statusCode != null && statusCode >= 400) {
      final code = data['code'] as String?;
      final message = data['message'] as String? ?? 'API request failed';

      if (code == 'INVALID_REQUEST') {
        throw SplashPayValidationException(
          message: message,
          code: code,
          statusCode: statusCode,
          data: data,
        );
      }

      throw SplashPayApiException(
        message: message,
        code: code,
        statusCode: statusCode,
        data: data,
      );
    }

    try {
      final paymentResponse = PaymentResponse.fromJson(data);

      if (!paymentResponse.success) {
        throw SplashPayApiException(
          message: paymentResponse.message ?? 'API request failed',
          code: paymentResponse.code,
          statusCode: statusCode,
          data: data,
        );
      }

      return paymentResponse;
    } on SplashPayException {
      rethrow;
    } catch (e) {
      throw SplashPayInvalidResponseException(
        message: 'Failed to parse response: $e',
        statusCode: statusCode,
        data: data,
      );
    }
  }

  SplashPayException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return SplashPayTimeoutException(
          message: 'Request timed out',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return SplashPayNetworkException(
          message: e.message ?? 'Network error',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          try {
            _handleResponse(
              Response<Map<String, dynamic>>(
                requestOptions: e.requestOptions,
                data: data,
                statusCode: e.response?.statusCode,
              ),
            );
            return SplashPayApiException(
              message: e.message ?? 'Bad response',
              statusCode: e.response?.statusCode,
              data: data,
            );
          } on SplashPayException catch (exception) {
            return exception;
          }
        }
        return SplashPayApiException(
          message: e.message ?? 'Bad response',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );
      case DioExceptionType.cancel:
        return SplashPayNetworkException(
          message: 'Request cancelled',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );
      case DioExceptionType.badCertificate:
        return SplashPayNetworkException(
          message: 'Bad certificate',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );
      case DioExceptionType.transformTimeout:
        return SplashPayTimeoutException(
          message: 'Transform timeout',
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );
    }
  }

  void _log(String message) {
    _config.logger?.call(message);
  }
}
