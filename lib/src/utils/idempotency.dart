import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Utilities for SplashPay idempotency key handling.
///
/// SplashPay requires an `Idempotency-Key` header. Reuse the same key when
/// retrying the same request; use a new key for distinct requests.
class Idempotency {
  /// Header name used by SplashPay.
  static const String headerName = 'Idempotency-Key';

  /// Resolves the idempotency key for a request.
  ///
  /// When [explicitKey] is provided, it is used directly.
  /// Otherwise a deterministic key is derived from [requestBody] so that
  /// retries with identical parameters reuse the same key automatically.
  static String resolveKey({
    required Map<String, dynamic> requestBody,
    String? explicitKey,
  }) {
    if (explicitKey != null && explicitKey.isNotEmpty) {
      return explicitKey;
    }

    return deterministicKey(requestBody);
  }

  /// Creates a deterministic idempotency key from request parameters.
  static String deterministicKey(Map<String, dynamic> requestBody) {
    final canonical = _canonicalJson(requestBody);
    final digest = sha256.convert(utf8.encode(canonical));
    return digest.toString();
  }

  static String _canonicalJson(Map<String, dynamic> map) {
    final sortedKeys = map.keys.toList()..sort();
    final canonical = <String, dynamic>{};
    for (final key in sortedKeys) {
      canonical[key] = map[key];
    }
    return jsonEncode(canonical);
  }
}
