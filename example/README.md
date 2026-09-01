# SplashPay SDK Example

Demo Flutter app for the [`splashpay_sdk`](https://pub.dev/packages/splashpay_sdk) package.

## Setup

```bash
cd example
cp .env.example .env
```

Edit `.env` with your SplashPay credentials:

```env
SPLASHPAY_API_KEY=YOUR_API_KEY
SPLASHPAY_API_SECRET=YOUR_API_SECRET
SPLASHPAY_ENVIRONMENT=sandbox
```

> Use **test/sandbox** keys for development. Never commit `.env` with real secrets.

## Run

```bash
flutter pub get
flutter run
```

## What it demonstrates

- Loading credentials from `.env`
- Initializing `SplashPay`
- Initiating a Mobile Money payment
- Displaying payment status and error handling
