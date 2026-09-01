/// Payment transaction status as returned by SplashPay.
enum PaymentStatus {
  /// Waiting for customer confirmation.
  pending,

  /// Payment is being processed.
  processing,

  /// Payment completed successfully.
  success,

  /// Payment failed.
  failed,

  /// Customer or provider cancelled the payment.
  cancelled,

  /// Payment request expired before completion.
  expired,

  /// Unknown or undocumented status value.
  unknown;

  /// Maps a SplashPay status string to [PaymentStatus].
  static PaymentStatus fromString(String? value) {
    if (value == null || value.isEmpty) {
      return PaymentStatus.unknown;
    }

    switch (value.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'processing':
        return PaymentStatus.processing;
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      case 'cancelled':
        return PaymentStatus.cancelled;
      case 'expired':
        return PaymentStatus.expired;
      default:
        return PaymentStatus.unknown;
    }
  }

  /// Canonical string value used by SplashPay.
  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.processing:
        return 'processing';
      case PaymentStatus.success:
        return 'success';
      case PaymentStatus.failed:
        return 'failed';
      case PaymentStatus.cancelled:
        return 'cancelled';
      case PaymentStatus.expired:
        return 'expired';
      case PaymentStatus.unknown:
        return 'unknown';
    }
  }
}
