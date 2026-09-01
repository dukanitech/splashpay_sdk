import '../client/splashpay_client.dart';
import '../models/mobile_money_request.dart';
import '../models/payment_response.dart';
import '../utils/idempotency.dart';

/// Service for Mobile Money payment operations.
class MobileMoneyService {
  /// Creates a [MobileMoneyService].
  const MobileMoneyService(this._client);

  final SplashPayClient _client;

  static const String _endpoint = '/payments/mobile-money';

  /// Initiates a Mobile Money payment.
  Future<PaymentResponse> initiate(MobileMoneyRequest request) async {
    request.validate();

    final body = request.toJson();
    final idempotencyKey = Idempotency.resolveKey(
      requestBody: body,
      explicitKey: request.idempotencyKey,
    );

    return _client.post(
      _endpoint,
      body: body,
      idempotencyKey: idempotencyKey,
    );
  }
}
