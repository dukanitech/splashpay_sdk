import 'package:flutter_test/flutter_test.dart';
import 'package:splashpay_sdk/splashpay_sdk.dart';

void main() {
  group('PaymentStatus.fromString', () {
    test('maps SplashPay statuses', () {
      expect(PaymentStatus.fromString('pending'), PaymentStatus.pending);
      expect(PaymentStatus.fromString('success'), PaymentStatus.success);
      expect(PaymentStatus.fromString('failed'), PaymentStatus.failed);
      expect(PaymentStatus.fromString('cancelled'), PaymentStatus.cancelled);
      expect(PaymentStatus.fromString('expired'), PaymentStatus.expired);
    });

    test('maps backend aliases used by proxy APIs', () {
      expect(PaymentStatus.fromString('paid'), PaymentStatus.success);
      expect(PaymentStatus.fromString('reject'), PaymentStatus.failed);
      expect(PaymentStatus.fromString('rejected'), PaymentStatus.failed);
      expect(PaymentStatus.fromString('canceled'), PaymentStatus.cancelled);
    });
  });

  group('PaymentStatus helpers', () {
    test('isSuccess / isFailure / isTerminal', () {
      expect(PaymentStatus.success.isSuccess, isTrue);
      expect(PaymentStatus.success.isTerminal, isTrue);
      expect(PaymentStatus.failed.isFailure, isTrue);
      expect(PaymentStatus.cancelled.isTerminal, isTrue);
      expect(PaymentStatus.pending.isTerminal, isFalse);
      expect(PaymentStatus.processing.isFailure, isFalse);
    });
  });
}
