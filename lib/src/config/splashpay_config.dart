/// SplashPay API environment.
///
/// Both environments use the documented production base URL. Sandbox vs live
/// is determined by your API credentials (`pk_test_` / `sk_test_` vs
/// `pk_live_` / `sk_live_`) as described in the official authentication docs.
enum SplashPayEnvironment {
  /// Sandbox / test credentials.
  sandbox,

  /// Production / live credentials.
  production,
}

/// Configuration for the SplashPay HTTP client.
class SplashPayConfig {
  /// Documented SplashPay API base URL.
  static const String productionBaseUrl =
      'https://api.splashpay.co.tz/api/v1';

  /// Creates SplashPay client configuration.
  const SplashPayConfig({
    required this.apiKey,
    required this.apiSecret,
    this.environment = SplashPayEnvironment.production,
    this.baseUrl = productionBaseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.logger,
  });

  /// Merchant API key (`X-API-KEY`).
  final String apiKey;

  /// Merchant API secret (`X-API-SECRET`).
  final String apiSecret;

  /// Target environment (credential type).
  final SplashPayEnvironment environment;

  /// API base URL. Defaults to the documented production URL.
  final String baseUrl;

  /// Connection timeout.
  final Duration connectTimeout;

  /// Receive timeout.
  final Duration receiveTimeout;

  /// Send timeout.
  final Duration sendTimeout;

  /// Optional logging callback. Never log secrets or sensitive customer data.
  final void Function(String message)? logger;

  /// Standard authentication and content headers for SplashPay requests.
  Map<String, String> authHeaders({String? idempotencyKey}) {
    final headers = <String, String>{
      'X-API-KEY': apiKey,
      'X-API-SECRET': apiSecret,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (idempotencyKey != null) {
      headers['Idempotency-Key'] = idempotencyKey;
    }

    return headers;
  }
}
