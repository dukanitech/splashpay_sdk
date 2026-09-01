import 'config/splashpay_config.dart';
import 'client/splashpay_client.dart';
import 'models/mobile_money_request.dart';
import 'models/payment_response.dart';
import 'services/mobile_money_service.dart';
import 'services/payment_service.dart';

/// Main entry point for the SplashPay SDK.
class SplashPay {
  /// Creates a [SplashPay] client instance.
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
