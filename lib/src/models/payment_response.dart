import 'payment_data.dart';
import 'payment_status.dart';

/// SplashPay API response wrapper for payment operations.
class PaymentResponse {
  /// Creates [PaymentResponse].
  const PaymentResponse({
    required this.success,
    this.apiStatus,
    this.code,
    this.message,
    this.data,
    this.meta = const [],
    this.requestId,
    this.raw,
  });

  /// Whether the API request succeeded (`status == success`).
  final bool success;

  /// Top-level API status (`success` or `error`).
  final String? apiStatus;

  /// Machine-readable response code (e.g. `PAYMENT_INITIATED`).
  final String? code;

  /// Human-readable response message.
  final String? message;

  /// Typed payment data when present.
  final PaymentData? data;

  /// Additional response metadata.
  final List<dynamic> meta;

  /// Unique request identifier for support.
  final String? requestId;

  /// Full raw JSON response for debugging.
  final Map<String, dynamic>? raw;

  /// Payment reference from [data] when available.
  String? get reference => data?.reference;

  /// Provider reference from [data] when available.
  String? get providerReference => data?.providerReference;

  /// Parsed payment transaction status from [data].
  PaymentStatus get paymentStatus =>
      data?.paymentStatus ?? PaymentStatus.unknown;

  /// Transaction ID alias for [providerReference].
  String? get transactionId => providerReference;

  /// Parses a SplashPay JSON response body.
  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    final apiStatus = json['status'] as String?;
    final legacySuccess = json['success'] as bool?;
    final isSuccess = apiStatus == 'success' || legacySuccess == true;

    final dataJson = json['data'];
    PaymentData? data;
    if (dataJson is Map<String, dynamic>) {
      data = PaymentData.fromJson(dataJson);
    } else if (dataJson is Map) {
      data = PaymentData.fromJson(Map<String, dynamic>.from(dataJson));
    }

    final meta = json['meta'];
    final parsedMeta = meta is List ? List<dynamic>.from(meta) : <dynamic>[];

    return PaymentResponse(
      success: isSuccess,
      apiStatus: apiStatus,
      code: json['code'] as String?,
      message: json['message'] as String?,
      data: data,
      meta: parsedMeta,
      requestId: json['request_id'] as String?,
      raw: Map<String, dynamic>.from(json),
    );
  }
}
