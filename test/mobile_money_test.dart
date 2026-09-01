import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:splashpay_sdk/splashpay_sdk.dart';
import 'package:splashpay_sdk/src/client/splashpay_client.dart';

const _baseUrl = SplashPayConfig.productionBaseUrl;

SplashPay _createSplashPay(DioAdapter adapter) {
  final config = SplashPayConfig(
    apiKey: 'YOUR_API_KEY',
    apiSecret: 'YOUR_API_SECRET',
  );
  final client = SplashPayClient(config, dio: adapter.dio);
  return SplashPay(
    apiKey: 'YOUR_API_KEY',
    apiSecret: 'YOUR_API_SECRET',
    client: client,
  );
}

void main() {
  late DioAdapter adapter;

  setUp(() {
    adapter = DioAdapter(
      dio: Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          validateStatus: (_) => true,
        ),
      ),
    );
  });

  group('MobileMoney', () {
    test('valid payment request succeeds', () async {
      adapter.onPost(
        '/payments/mobile-money',
        (server) => server.reply(
          200,
          {
            'status': 'success',
            'code': 'PAYMENT_INITIATED',
            'message': 'Payment initiated',
            'data': {
              'reference': 'TEST-001',
              'status': 'pending',
              'provider_reference': 'REF-123',
            },
            'meta': [],
            'request_id': 'req-1',
          },
        ),
        data: Matchers.any,
      );

      final splashPay = _createSplashPay(adapter);
      final result = await splashPay.mobileMoney(
        amount: 50000,
        phone: '255712345678',
        reference: 'TEST-001',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
      );

      expect(result.success, isTrue);
      expect(result.reference, 'TEST-001');
    });

    test('invalid amount throws ArgumentError', () {
      final request = MobileMoneyRequest(
        amount: 0,
        phone: '255712345678',
        reference: 'TEST-001',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
      );

      expect(() => request.validate(), throwsArgumentError);
    });

    test('invalid phone throws ArgumentError', () {
      final request = MobileMoneyRequest(
        amount: 1000,
        phone: '',
        reference: 'TEST-001',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
      );

      expect(() => request.validate(), throwsArgumentError);
    });

    test('missing reference throws ArgumentError', () {
      final request = MobileMoneyRequest(
        amount: 1000,
        phone: '255712345678',
        reference: '',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
      );

      expect(() => request.validate(), throwsArgumentError);
    });

    test('pending response maps status correctly', () async {
      adapter.onPost(
        '/payments/mobile-money',
        (server) => server.reply(
          200,
          {
            'status': 'success',
            'code': 'PAYMENT_INITIATED',
            'data': {'status': 'pending', 'reference': 'TEST-001'},
          },
        ),
        data: Matchers.any,
      );

      final splashPay = _createSplashPay(adapter);
      final result = await splashPay.mobileMoney(
        amount: 1000,
        phone: '255712345678',
        reference: 'TEST-001',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
      );

      expect(result.paymentStatus, PaymentStatus.pending);
    });

    test('failed response maps status correctly', () async {
      adapter.onPost(
        '/payments/mobile-money',
        (server) => server.reply(
          200,
          {
            'status': 'success',
            'code': 'PAYMENT_INITIATED',
            'data': {'status': 'failed', 'reference': 'TEST-001'},
          },
        ),
        data: Matchers.any,
      );

      final splashPay = _createSplashPay(adapter);
      final result = await splashPay.mobileMoney(
        amount: 1000,
        phone: '255712345678',
        reference: 'TEST-001',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
      );

      expect(result.paymentStatus, PaymentStatus.failed);
    });

    test('automatically generated idempotency key is sent', () async {
      String? capturedKey;

      adapter.onPost(
        '/payments/mobile-money',
        (server) => server.reply(200, {'status': 'success', 'data': {}}),
        data: Matchers.any,
      );

      adapter.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedKey = options.headers['Idempotency-Key'] as String?;
            handler.next(options);
          },
        ),
      );

      final splashPay = _createSplashPay(adapter);
      await splashPay.mobileMoney(
        amount: 1000,
        phone: '255712345678',
        reference: 'TEST-001',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
      );

      expect(capturedKey, isNotNull);
      expect(capturedKey!.isNotEmpty, isTrue);
    });

    test('explicit idempotency key is sent', () async {
      String? capturedKey;

      adapter.onPost(
        '/payments/mobile-money',
        (server) => server.reply(200, {'status': 'success', 'data': {}}),
        data: Matchers.any,
      );

      adapter.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedKey = options.headers['Idempotency-Key'] as String?;
            handler.next(options);
          },
        ),
      );

      final splashPay = _createSplashPay(adapter);
      await splashPay.mobileMoney(
        amount: 1000,
        phone: '255712345678',
        reference: 'TEST-001',
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        idempotencyKey: 'unique-payment-key',
      );

      expect(capturedKey, 'unique-payment-key');
    });

    test('same key on retry with identical request', () async {
      final keys = <String>[];

      adapter.onPost(
        '/payments/mobile-money',
        (server) => server.reply(200, {'status': 'success', 'data': {}}),
        data: Matchers.any,
      );

      adapter.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            keys.add(options.headers['Idempotency-Key'] as String);
            handler.next(options);
          },
        ),
      );

      final splashPay = _createSplashPay(adapter);
      final params = {
        'amount': 1000,
        'phone': '255712345678',
        'reference': 'TEST-001',
        'customerName': 'John Doe',
        'customerEmail': 'john@example.com',
      };

      await splashPay.mobileMoney(
        amount: params['amount'] as int,
        phone: params['phone'] as String,
        reference: params['reference'] as String,
        customerName: params['customerName'] as String,
        customerEmail: params['customerEmail'] as String,
      );

      await splashPay.mobileMoney(
        amount: params['amount'] as int,
        phone: params['phone'] as String,
        reference: params['reference'] as String,
        customerName: params['customerName'] as String,
        customerEmail: params['customerEmail'] as String,
      );

      expect(keys.length, 2);
      expect(keys[0], keys[1]);
    });
  });
}
