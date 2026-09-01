import 'package:flutter_test/flutter_test.dart';
import 'package:splashpay_sdk/splashpay_sdk.dart';
import 'package:splashpay_sdk/src/utils/idempotency.dart';

void main() {
  group('PaymentResponse', () {
    test('parses successful mobile money response', () {
      final response = PaymentResponse.fromJson({
        'status': 'success',
        'code': 'PAYMENT_INITIATED',
        'message': 'Payment initiated',
        'data': {
          'customer_name': 'John Doe',
          'customer_email': 'john.doe@example.com',
          'customer_phone': '255712345678',
          'reference': 'INV-1234',
          'amount': '1000.00',
          'fee': 15.00,
          'net_amount': 985.00,
          'currency': 'TZS',
          'payment_method': 'mobile_money',
          'provider': 'selcom',
          'provider_reference': 'S20618089300',
          'status': 'pending',
          'metadata': null,
          'created_at': '2026-07-03T10:28:57Z',
          'processing_at': '2026-07-03T13:28:57Z',
        },
        'meta': [],
        'request_id': '85323840-963b-4464-897f-12613975b8e3',
      });

      expect(response.success, isTrue);
      expect(response.code, 'PAYMENT_INITIATED');
      expect(response.message, 'Payment initiated');
      expect(response.requestId, '85323840-963b-4464-897f-12613975b8e3');
      expect(response.data?.customerName, 'John Doe');
      expect(response.data?.amount, '1000.00');
      expect(response.data?.fee, 15.00);
      expect(response.data?.netAmount, 985.00);
      expect(response.paymentStatus, PaymentStatus.pending);
      expect(response.transactionId, 'S20618089300');
    });

    test('parses payment status check response', () {
      final response = PaymentResponse.fromJson({
        'status': 'success',
        'code': 'PAYMENT_STATUS_CHECKED',
        'message': 'Payment status checked',
        'data': {
          'reference': 'CIR-6723e6ss6',
          'provider_reference': '1782388280',
          'amount': '1000.00',
          'currency': 'TZS',
          'status': 'success',
          'provider': 'selcom',
          'channel': 'tanqr',
          'network': 'SELCOMTANQR',
          'created_at': '2026-07-03T14:42:13.000000Z',
          'processing_at': '2026-07-03T14:42:13Z',
          'completed_at': null,
        },
        'meta': [],
        'request_id': 'f0ee4a32-bc56-49f7-92a5-82f965e8c555',
      });

      expect(response.success, isTrue);
      expect(response.paymentStatus, PaymentStatus.success);
      expect(response.data?.channel, 'tanqr');
      expect(response.data?.network, 'SELCOMTANQR');
    });

    test('parses error response with legacy success field', () {
      final response = PaymentResponse.fromJson({
        'success': false,
        'code': 'INVALID_REQUEST',
        'message': 'The request payload is invalid.',
      });

      expect(response.success, isFalse);
      expect(response.code, 'INVALID_REQUEST');
    });

    test('maps unknown payment status safely', () {
      final response = PaymentResponse.fromJson({
        'status': 'success',
        'data': {'status': 'some_future_status'},
      });

      expect(response.paymentStatus, PaymentStatus.unknown);
    });

    test('PaymentStatus.fromString handles all documented values', () {
      expect(PaymentStatus.fromString('pending'), PaymentStatus.pending);
      expect(PaymentStatus.fromString('processing'), PaymentStatus.processing);
      expect(PaymentStatus.fromString('success'), PaymentStatus.success);
      expect(PaymentStatus.fromString('failed'), PaymentStatus.failed);
      expect(PaymentStatus.fromString('cancelled'), PaymentStatus.cancelled);
      expect(PaymentStatus.fromString('expired'), PaymentStatus.expired);
      expect(PaymentStatus.fromString('unknown_value'), PaymentStatus.unknown);
      expect(PaymentStatus.fromString(null), PaymentStatus.unknown);
    });
  });

  group('SplashPayWebhookEvent', () {
    test('parses webhook payload', () {
      final event = SplashPayWebhookEvent.fromJson({
        'event': 'payment.success',
        'created_at': '2026-06-24T09:59:24.430757Z',
        'data': {
          'reference': 'INV-1234',
          'amount': '1000.00',
          'currency': 'TZS',
          'status': 'success',
          'customer_name': 'John Doe',
          'customer_email': 'john.doe@example.com',
          'customer_phone': '255712345678',
          'channel': 'TIGOPESATZ',
          'provider_reference': '1769142083',
          'metadata': null,
        },
      });

      expect(event.eventType, SplashPayWebhookEventType.paymentSuccess);
      expect(event.data?.reference, 'INV-1234');
      expect(event.data?.paymentStatus, PaymentStatus.success);
    });
  });

  group('SplashPayWebhookVerifier', () {
    test('verifies documented HMAC signature', () {
      const payload = '{"event":"payment.success"}';
      const timestamp = '1234567890';
      const secret = 'webhook_secret';

      final signature = SplashPayWebhookVerifier.computeSignature(
        payload: payload,
        timestamp: timestamp,
        webhookSecret: secret,
      );

      expect(
        SplashPayWebhookVerifier.verify(
          payload: payload,
          timestamp: timestamp,
          signature: signature,
          webhookSecret: secret,
        ),
        isTrue,
      );

      expect(
        SplashPayWebhookVerifier.verify(
          payload: payload,
          timestamp: timestamp,
          signature: 'invalid',
          webhookSecret: secret,
        ),
        isFalse,
      );
    });
  });

  group('Idempotency', () {
    test('deterministic key is stable for same body', () {
      final body = {
        'amount': 1000,
        'currency': 'TZS',
        'reference': 'TEST-001',
        'phone': '255712345678',
        'customer_name': 'John Doe',
        'customer_email': 'john@example.com',
      };

      final key1 = Idempotency.deterministicKey(body);
      final key2 = Idempotency.deterministicKey(body);

      expect(key1, key2);
    });

    test('explicit key overrides deterministic generation', () {
      final body = {'reference': 'TEST-001'};
      final key = Idempotency.resolveKey(
        requestBody: body,
        explicitKey: 'my-explicit-key',
      );

      expect(key, 'my-explicit-key');
    });
  });
}
