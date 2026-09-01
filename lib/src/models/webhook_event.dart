import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

import '../models/payment_data.dart';

/// Documented SplashPay webhook event types.
enum SplashPayWebhookEventType {
  paymentSuccess('payment.success'),
  paymentFailed('payment.failed'),
  paymentCancelled('payment.cancelled'),
  paymentExpired('payment.expired'),
  paymentUserCancelled('payment.user_cancelled'),
  paymentInProgress('payment.in_progress'),
  paymentPending('payment.pending'),
  paymentRejected('payment.rejected'),
  unknown('unknown');

  const SplashPayWebhookEventType(this.value);

  /// Event string sent by SplashPay.
  final String value;

  /// Maps an event string to [SplashPayWebhookEventType].
  static SplashPayWebhookEventType fromString(String? value) {
    if (value == null || value.isEmpty) {
      return SplashPayWebhookEventType.unknown;
    }

    for (final event in SplashPayWebhookEventType.values) {
      if (event.value == value) {
        return event;
      }
    }

    return SplashPayWebhookEventType.unknown;
  }
}

/// Parsed SplashPay webhook payload.
///
/// Webhook receiving and verification should be implemented on your backend,
/// not inside a Flutter client application.
class SplashPayWebhookEvent {
  /// Creates [SplashPayWebhookEvent].
  const SplashPayWebhookEvent({
    required this.eventType,
    this.createdAt,
    this.data,
    this.raw,
  });

  /// Parsed event type.
  final SplashPayWebhookEventType eventType;

  /// ISO-8601 timestamp when the webhook was generated.
  final String? createdAt;

  /// Parsed payment data from the webhook payload.
  final PaymentData? data;

  /// Original webhook JSON.
  final Map<String, dynamic>? raw;

  /// Parses a webhook JSON payload.
  factory SplashPayWebhookEvent.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    PaymentData? data;
    if (dataJson is Map<String, dynamic>) {
      data = PaymentData.fromJson(dataJson);
    } else if (dataJson is Map) {
      data = PaymentData.fromJson(Map<String, dynamic>.from(dataJson));
    }

    return SplashPayWebhookEvent(
      eventType: SplashPayWebhookEventType.fromString(json['event'] as String?),
      createdAt: json['created_at'] as String?,
      data: data,
      raw: Map<String, dynamic>.from(json),
    );
  }

  /// Parses a webhook from a JSON string.
  factory SplashPayWebhookEvent.fromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Webhook payload must be a JSON object');
    }
    return SplashPayWebhookEvent.fromJson(decoded);
  }
}

/// Helper for verifying SplashPay webhook signatures on a backend server.
///
/// Algorithm documented by SplashPay:
/// `HMAC_SHA256(timestamp + "." + request_body, WEBHOOK_SECRET)`
class SplashPayWebhookVerifier {
  /// Signature header name.
  static const String signatureHeader = 'X-SPLASHPAY-SIGNATURE';

  /// Timestamp header name.
  static const String timestampHeader = 'X-SPLASHPAY-TIMESTAMP';

  /// Verifies a webhook signature.
  static bool verify({
    required String payload,
    required String timestamp,
    required String signature,
    required String webhookSecret,
  }) {
    final expected = computeSignature(
      payload: payload,
      timestamp: timestamp,
      webhookSecret: webhookSecret,
    );

    return _secureCompare(expected, signature);
  }

  /// Computes the expected HMAC SHA-256 signature.
  @visibleForTesting
  static String computeSignature({
    required String payload,
    required String timestamp,
    required String webhookSecret,
  }) {
    final key = utf8.encode(webhookSecret);
    final message = utf8.encode('$timestamp.$payload');
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(message);
    return digest.toString();
  }

  static bool _secureCompare(String a, String b) {
    if (a.length != b.length) {
      return false;
    }

    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
