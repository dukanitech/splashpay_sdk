# Changelog

All notable changes to this project will be documented in this file.

## 1.1.0

- Add `PaymentStatus.isSuccess` / `isFailure` / `isTerminal` helpers for Flutter apps that proxy through a backend.
- Accept backend aliases in `PaymentStatus.fromString` (`paid`, `reject` / `rejected`, `canceled`).
- Add `SplashPay.forMerchant` named constructor; document that merchant credentials must stay server-side.
- Expand README “Backend proxy” guidance for secure Flutter → Backend → SplashPay architecture.

## 1.0.0

- Initial release of the standalone SplashPay SDK.
- Mobile Money payment initiation with PUSH TO PAY.
- Payment status check.
- Cancel payment .
- Idempotency key support with automatic deterministic key generation.

