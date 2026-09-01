/// Base exception for all SplashPay SDK errors.
class SplashPayException implements Exception {
  /// Creates a [SplashPayException].
  const SplashPayException({
    required this.message,
    this.code,
    this.statusCode,
    this.data,
  });

  /// Human-readable error message.
  final String message;

  /// Machine-readable SplashPay error code when available.
  final String? code;

  /// HTTP status code when available.
  final int? statusCode;

  /// Raw error payload for debugging.
  final dynamic data;

  @override
  String toString() {
    final parts = <String>['SplashPayException: $message'];
    if (code != null) {
      parts.add('code=$code');
    }
    if (statusCode != null) {
      parts.add('statusCode=$statusCode');
    }
    return parts.join(', ');
  }
}

/// Network connectivity or transport failure.
class SplashPayNetworkException extends SplashPayException {
  /// Creates a [SplashPayNetworkException].
  const SplashPayNetworkException({
    required super.message,
    super.code,
    super.statusCode,
    super.data,
  });
}

/// Authentication failure (invalid API credentials).
class SplashPayAuthenticationException extends SplashPayException {
  /// Creates a [SplashPayAuthenticationException].
  const SplashPayAuthenticationException({
    required super.message,
    super.code,
    super.statusCode,
    super.data,
  });
}

/// Request validation failure.
class SplashPayValidationException extends SplashPayException {
  /// Creates a [SplashPayValidationException].
  const SplashPayValidationException({
    required super.message,
    super.code,
    super.statusCode,
    super.data,
  });
}

/// SplashPay API returned an error response.
class SplashPayApiException extends SplashPayException {
  /// Creates a [SplashPayApiException].
  const SplashPayApiException({
    required super.message,
    super.code,
    super.statusCode,
    super.data,
  });
}

/// Request timed out.
class SplashPayTimeoutException extends SplashPayException {
  /// Creates a [SplashPayTimeoutException].
  const SplashPayTimeoutException({
    required super.message,
    super.code,
    super.statusCode,
    super.data,
  });
}

/// Response body could not be parsed or was invalid.
class SplashPayInvalidResponseException extends SplashPayException {
  /// Creates a [SplashPayInvalidResponseException].
  const SplashPayInvalidResponseException({
    required super.message,
    super.code,
    super.statusCode,
    super.data,
  });
}
