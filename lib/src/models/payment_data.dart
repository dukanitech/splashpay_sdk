import 'payment_status.dart';

/// Payment details returned in SplashPay API responses.
class PaymentData {
  /// Creates [PaymentData].
  const PaymentData({
    this.reference,
    this.providerReference,
    this.amount,
    this.fee,
    this.netAmount,
    this.currency,
    this.paymentStatus = PaymentStatus.unknown,
    this.paymentMethod,
    this.provider,
    this.channel,
    this.network,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.metadata,
    this.createdAt,
    this.processingAt,
    this.completedAt,
    this.cancelledAt,
    this.raw,
  });

  /// Merchant payment reference.
  final String? reference;

  /// Provider transaction reference.
  final String? providerReference;

  /// Payment amount (API may return string or number).
  final String? amount;

  /// Processing fee.
  final num? fee;

  /// Amount after fees.
  final num? netAmount;

  /// Currency code (typically `TZS`).
  final String? currency;

  /// Parsed payment transaction status.
  final PaymentStatus paymentStatus;

  /// Payment method (e.g. `mobile_money`).
  final String? paymentMethod;

  /// Payment provider (e.g. `selcom`).
  final String? provider;

  /// Provider channel or network.
  final String? channel;

  /// Provider network identifier.
  final String? network;

  /// Customer full name.
  final String? customerName;

  /// Customer email address.
  final String? customerEmail;

  /// Customer phone number.
  final String? customerPhone;

  /// Merchant-defined metadata.
  final Map<String, dynamic>? metadata;

  /// Transaction creation timestamp (ISO-8601).
  final String? createdAt;

  /// Processing start timestamp (ISO-8601).
  final String? processingAt;

  /// Completion timestamp (ISO-8601).
  final String? completedAt;

  /// Cancellation timestamp.
  final String? cancelledAt;

  /// Original `data` object from the API response.
  final Map<String, dynamic>? raw;

  /// Parses the `data` field from a SplashPay API response.
  factory PaymentData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PaymentData();
    }

    return PaymentData(
      reference: json['reference'] as String?,
      providerReference: json['provider_reference'] as String?,
      amount: _stringifyAmount(json['amount']),
      fee: _parseNum(json['fee']),
      netAmount: _parseNum(json['net_amount']),
      currency: json['currency'] as String?,
      paymentStatus: PaymentStatus.fromString(json['status'] as String?),
      paymentMethod: json['payment_method'] as String?,
      provider: json['provider'] as String?,
      channel: json['channel'] as String?,
      network: json['network'] as String?,
      customerName: json['customer_name'] as String?,
      customerEmail: json['customer_email'] as String?,
      customerPhone: json['customer_phone'] as String?,
      metadata: _parseMetadata(json['metadata']),
      createdAt: json['created_at'] as String?,
      processingAt: json['processing_at'] as String?,
      completedAt: json['completed_at'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
      raw: Map<String, dynamic>.from(json),
    );
  }

  static String? _stringifyAmount(dynamic value) {
    if (value == null) {
      return null;
    }
    return value.toString();
  }

  static num? _parseNum(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value;
    }
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }

  static Map<String, dynamic>? _parseMetadata(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}
