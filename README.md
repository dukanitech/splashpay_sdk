# splashpay_sdk

[![pub package](https://img.shields.io/pub/v/splashpay_sdk.svg)](https://pub.dev/packages/splashpay_sdk)
[![pub publisher](https://img.shields.io/pub/publisher/splashpay_sdk?label=dukanitech.com)](https://pub.dev/publishers/dukanitech.com/packages)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A standalone, production-ready Flutter/Dart package for integrating the [SplashPay Tanzania REST API](https://docs.splashpay.co.tz).

Published by [dukanitech.com](https://pub.dev/publishers/dukanitech.com/packages) on pub.dev.

This package is a standalone SDK that can be consumed by any Flutter application as a normal dependency.

## Features

- Mobile Money payment initiation
- Payment status check
- Cancel pending payment
- Typed request and response models
- Payment status enum mapping
- Idempotency key support
- Webhook payload models and signature verification helper (for backend use)
- Comprehensive exception hierarchy

## Installation

### pub.dev

```yaml
dependencies:
  splashpay_sdk: ^1.0.0
```

```bash
flutter pub get
```

### Local path dependency

```yaml
dependencies:
  splashpay_sdk:
    path: ../splashpay_sdk
```

### Git dependency

```yaml
dependencies:
  splashpay_sdk:
    git:
      url: https://github.com/dukanitech/splashpay_sdk.git
      ref: main
```

## Initialization

```dart
import 'package:splashpay_sdk/splashpay_sdk.dart';

final splashPay = SplashPay(
  apiKey: 'YOUR_API_KEY',
  apiSecret: 'YOUR_API_SECRET',
  environment: SplashPayEnvironment.sandbox, // or production
);
```

Authentication uses documented headers:

- `X-API-KEY`
- `X-API-SECRET`
- `Content-Type: application/json`
- `Accept: application/json`

Use `pk_test_` / `sk_test_` credentials for sandbox and `pk_live_` / `sk_live_` for production. Both environments use the documented base URL: `https://api.splashpay.co.tz/api/v1`.

## Mobile Money

Initiate a Mobile Money payment per the [official documentation](https://docs.splashpay.co.tz/collections/mobile-money):

```dart
final result = await splashPay.mobileMoney(
  amount: 1000,
  currency: 'TZS', // optional, defaults to TZS
  phone: '255712345678',
  reference: 'INV-1234',
  customerName: 'John Doe',
  customerEmail: 'john.doe@example.com',
  metadata: {'order_id': '12345'}, // optional
  idempotencyKey: 'unique-payment-key', // optional
);
```

Required fields: `amount`, `currency` (TZS), `reference`, `phone`, `customer_name`, `customer_email`.

A successful API response does **not** mean the customer has paid. The initial transaction status is typically `pending`. Use webhooks or the status API for the final outcome.

## Response

```dart
print(result.success);           // API request succeeded
print(result.code);              // e.g. PAYMENT_INITIATED
print(result.message);
print(result.paymentStatus);     // PaymentStatus.pending, etc.
print(result.reference);
print(result.transactionId);     // provider_reference
print(result.data?.fee);
print(result.data?.netAmount);
```

### Payment statuses

| Status | Description |
|--------|-------------|
| `pending` | Waiting for customer confirmation |
| `processing` | Payment is being processed |
| `success` | Payment completed successfully |
| `failed` | Payment failed |
| `cancelled` | Payment was cancelled |
| `expired` | Payment expired |

Unknown future status values are mapped to `PaymentStatus.unknown` without throwing.

## Payment status check

```dart
final status = await splashPay.paymentStatus(reference: 'INV-1234');
print(status.paymentStatus);
```

## Cancel payment

```dart
final cancelled = await splashPay.cancelPayment(reference: 'INV-1234');
```

Only pending (and optionally processing) payments can be cancelled.

## Error handling

```dart
try {
  final result = await splashPay.mobileMoney(
    amount: 1000,
    phone: '255712345678',
    reference: 'INV-1234',
    customerName: 'John Doe',
    customerEmail: 'john@example.com',
  );
} on SplashPayAuthenticationException catch (e) {
  // Invalid API credentials (401 / UNAUTHORIZED)
} on SplashPayValidationException catch (e) {
  // Invalid request payload
} on SplashPayTimeoutException catch (e) {
  // Request timed out
} on SplashPayNetworkException catch (e) {
  // Network connectivity issues
} on SplashPayApiException catch (e) {
  // API returned an error
} on SplashPayException catch (e) {
  print(e.message);
  print(e.code);
}
```

## Idempotency

SplashPay requires an `Idempotency-Key` header for Mobile Money requests.

- If you pass `idempotencyKey`, that value is used.
- If omitted, the SDK generates a **deterministic** key from the request body so retries with identical parameters reuse the same key.
- Reuse the same key only when retrying the **same** request. Use a new key for distinct payments.

## Security

**Do not embed API secrets in distributed Flutter apps** if they must remain confidential. SplashPay documentation states:

> Never expose your API Secret in frontend applications, mobile apps, or public repositories.

Recommended architecture for production:

```text
Flutter App  →  Your Backend  →  SplashPay API
```

Your backend holds `X-API-KEY` and `X-API-SECRET`. The mobile app calls your backend, not SplashPay directly.

Use [SplashPay.forMerchant] **only** on the server. The SDK does not log API keys, secrets, or sensitive customer data.

### Flutter apps (backend proxy)

Distributed apps should **never** construct `SplashPay(...)` / `SplashPay.forMerchant(...)` with real credentials.

Instead:

1. Call your authenticated backend (`POST /billing/subscribe`, status, cancel, webhooks).
2. Reuse SDK models/helpers on the client for status interpretation:

```dart
import 'package:splashpay_sdk/splashpay_sdk.dart';

final status = PaymentStatus.fromString(payment['status'] as String?);
if (status.isSuccess) { /* activate UI */ }
if (status.isTerminal) { /* stop polling */ }
```

`PaymentStatus.fromString` also accepts common backend aliases (`paid` → success, `reject` → failed).

### Backend Dart services

Server-side Dart may use the full merchant client:

```dart
final splashPay = SplashPay.forMerchant(
  apiKey: Platform.environment['SPLASHPAY_API_KEY']!,
  apiSecret: Platform.environment['SPLASHPAY_API_SECRET']!,
  environment: SplashPayEnvironment.production,
);
```

## Webhooks

A Flutter package cannot safely act as the production webhook endpoint. Webhook handling belongs on your **backend**:

```text
SplashPay → webhook → Backend → Database → Flutter application
```

The SDK provides models and a signature verifier for backend Dart services:

```dart
final event = SplashPayWebhookEvent.fromJsonString(payload);
final valid = SplashPayWebhookVerifier.verify(
  payload: rawBody,
  timestamp: timestamp,
  signature: signature,
  webhookSecret: 'YOUR_WEBHOOK_SECRET',
);
```

Verify signatures using `HMAC_SHA256(timestamp + "." + request_body, WEBHOOK_SECRET)` per SplashPay documentation.

## Example app

```bash
cd example
cp .env.example .env
# Edit .env with your credentials
flutter run
```

The example loads `SPLASHPAY_API_KEY`, `SPLASHPAY_API_SECRET`, and
`SPLASHPAY_ENVIRONMENT` from `.env`. Never commit real API keys.

## API reference

| Method | Endpoint |
|--------|----------|
| Mobile Money | `POST /payments/mobile-money` |
| Check status | `POST /payments/check-status` |
| Cancel | `POST /payments/cancel` |

Base URL: `https://api.splashpay.co.tz/api/v1`

## License

MIT — see [LICENSE](LICENSE).

## Publishing

Published under the [dukanitech.com](https://pub.dev/publishers/dukanitech.com/packages) verified publisher on pub.dev.

See [PUBLISHING.md](PUBLISHING.md) for deployment and publisher transfer instructions.
