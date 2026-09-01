import '../client/splashpay_client.dart';
import '../models/payment_response.dart';

/// Service for payment status and cancellation operations.
class PaymentService {
  /// Creates a [PaymentService].
  const PaymentService(this._client);

  final SplashPayClient _client;

  static const String _statusEndpoint = '/payments/check-status';
  static const String _cancelEndpoint = '/payments/cancel';

  /// Checks the current status of a payment by merchant reference.
  Future<PaymentResponse> checkStatus({required String reference}) async {
    if (reference.trim().isEmpty) {
      throw ArgumentError.value(reference, 'reference', 'Reference is required');
    }

    return _client.post(
      _statusEndpoint,
      body: {'reference': reference},
    );
  }

  /// Cancels a pending payment by merchant reference.
  Future<PaymentResponse> cancel({required String reference}) async {
    if (reference.trim().isEmpty) {
      throw ArgumentError.value(reference, 'reference', 'Reference is required');
    }

    return _client.post(
      _cancelEndpoint,
      body: {'reference': reference},
    );
  }
}
