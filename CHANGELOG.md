# Changelog

All notable changes to this project will be documented in this file.

## 1.0.0

- Initial release of the standalone SplashPay SDK.
- Mobile Money payment initiation (`POST /payments/mobile-money`).
- Payment status check (`POST /payments/check-status`).
- Cancel payment (`POST /payments/cancel`).
- Typed request and response models.
- Payment status enum mapping.
- Idempotency key support with automatic deterministic key generation.
- Exception hierarchy for network, auth, validation, and API errors.
- Webhook payload models and signature verification helper.
- Unit tests with mocked HTTP responses.
- Example Flutter application.
