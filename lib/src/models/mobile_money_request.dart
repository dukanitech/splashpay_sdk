/// Request payload for Mobile Money payment initiation.
///
/// Field names match the official SplashPay API (`customer_name`, etc.).
class MobileMoneyRequest {
  /// Creates a [MobileMoneyRequest].
  const MobileMoneyRequest({
    required this.amount,
    required this.reference,
    required this.phone,
    required this.customerName,
    required this.customerEmail,
    this.currency = 'TZS',
    this.metadata,
    this.idempotencyKey,
  });

  /// Payment amount.
  final num amount;

  /// Currency code. Must be `TZS` per SplashPay documentation.
  final String currency;

  /// Unique merchant reference for this payment.
  final String reference;

  /// Customer phone number in international format (e.g. `255712345678`).
  final String phone;

  /// Customer full name.
  final String customerName;

  /// Customer email address.
  final String customerEmail;

  /// Optional merchant metadata.
  final Map<String, dynamic>? metadata;

  /// Optional idempotency key for safe retries.
  final String? idempotencyKey;

  /// Serializes the request to the documented JSON body shape.
  Map<String, dynamic> toJson() {
    final body = <String, dynamic>{
      'amount': amount,
      'currency': currency,
      'reference': reference,
      'phone': phone,
      'customer_name': customerName,
      'customer_email': customerEmail,
    };

    if (metadata != null) {
      body['metadata'] = metadata;
    }

    return body;
  }

  /// Validates required fields before sending to the API.
  void validate() {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Amount must be greater than 0');
    }

    if (reference.trim().isEmpty) {
      throw ArgumentError.value(reference, 'reference', 'Reference is required');
    }

    if (phone.trim().isEmpty) {
      throw ArgumentError.value(phone, 'phone', 'Phone is required');
    }

    if (customerName.trim().isEmpty) {
      throw ArgumentError.value(
        customerName,
        'customerName',
        'Customer name is required',
      );
    }

    if (customerEmail.trim().isEmpty) {
      throw ArgumentError.value(
        customerEmail,
        'customerEmail',
        'Customer email is required',
      );
    }

    if (currency != 'TZS') {
      throw ArgumentError.value(
        currency,
        'currency',
        'Currency must be TZS per SplashPay documentation',
      );
    }
  }
}
