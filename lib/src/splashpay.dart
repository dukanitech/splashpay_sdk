import 'config/splashpay_config.dart';
import 'client/splashpay_client.dart';
import 'models/mobile_money_request.dart';
import 'models/payment_response.dart';
import 'services/mobile_money_service.dart';
import 'services/payment_service.dart';

/// Main entry point for the SplashPay merchant REST client.
///
/// **Security:** Only construct this on a trusted backend (or a private
/// server-side Dart service) that holds `X-API-KEY` / `X-API-SECRET`.
/// Do **not** embed API secrets in distributed Flutter apps.
///
/// Flutter apps should call *your* backend and reuse [PaymentStatus] /
/// response models from this package — see the README “Backend proxy” section.
class SplashPay {
  /// Creates a merchant client that talks to SplashPay with API credentials.
  ///
  /// Prefer [SplashPay.forMerchant] in new code for clarity.
  SplashPay({
    required String apiKey,
    required String apiSecret,
    SplashPayEnvironment environment = SplashPayEnvironment.production,
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    void Function(String message)? logger,
    SplashPayClient? client,
  }) : this.forMerchant(
          apiKey: apiKey,
          apiSecret: apiSecret,
          environment: environment,
          baseUrl: baseUrl,
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          sendTimeout: sendTimeout,
          logger: logger,
          client: client,
        );

  /// Merchant client for server-side use only (holds API key + secret).
  SplashPay.forMerchant({
    required String apiKey,
    required String apiSecret,
    SplashPayEnvironment environment = SplashPayEnvironment.production,
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    void Function(String message)? logger,
    SplashPayClient? client,
  }) {
    final config = SplashPayConfig(
      apiKey: apiKey,
      apiSecret: apiSecret,
      environment: environment,
      baseUrl: baseUrl ?? SplashPayConfig.productionBaseUrl,
      connectTimeout: connectTimeout ?? const Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
      sendTimeout: sendTimeout ?? const Duration(seconds: 30),
      logger: logger,
    );

    _client = client ?? SplashPayClient(config);
    _mobileMoneyService = MobileMoneyService(_client);
    _paymentService = PaymentService(_client);
  }

  late final SplashPayClient _client;
  late final MobileMoneyService _mobileMoneyService;
  late final PaymentService _paymentService;

  /// Initiates a Mobile Money payment.
  ///
  /// Required fields match the official SplashPay API documentation.
  Future<PaymentResponse> mobileMoney({
    required num amount,
    required String phone,
    required String reference,
    required String customerName,
    required String customerEmail,
    String currency = 'TZS',
    Map<String, dynamic>? metadata,
    String? idempotencyKey,
  }) {
    final request = MobileMoneyRequest(
      amount: amount,
      phone: phone,
      reference: reference,
      customerName: customerName,
      customerEmail: customerEmail,
      currency: currency,
      metadata: metadata,
      idempotencyKey: idempotencyKey,
    );

    return _mobileMoneyService.initiate(request);
  }

  /// Checks the latest status of a payment by merchant reference.
  Future<PaymentResponse> paymentStatus({required String reference}) {
    return _paymentService.checkStatus(reference: reference);
  }

  /// Cancels a pending payment by merchant reference.
  Future<PaymentResponse> cancelPayment({required String reference}) {
    return _paymentService.cancel(reference: reference);
  }
}
