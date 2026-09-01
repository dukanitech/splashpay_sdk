import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:splashpay_sdk/splashpay_sdk.dart';
import 'package:splashpay_sdk/src/client/splashpay_client.dart';

const _baseUrl = SplashPayConfig.productionBaseUrl;

SplashPay _createSplashPay(DioAdapter adapter) {
  final dio = adapter.dio;
  final config = SplashPayConfig(
    apiKey: 'YOUR_API_KEY',
    apiSecret: 'YOUR_API_SECRET',
  );
  final client = SplashPayClient(config, dio: dio);
  return SplashPay(
    apiKey: 'YOUR_API_KEY',
    apiSecret: 'YOUR_API_SECRET',
    client: client,
  );
}

Map<String, dynamic> _successMobileMoneyResponse({
  String paymentStatus = 'pending',
}) {
  return {
    'status': 'success',
    'code': 'PAYMENT_INITIATED',
    'message': 'Payment initiated',
    'data': {
      'customer_name': 'John Doe',
      'customer_email': 'john.doe@example.com',
      'customer_phone': '255712345678',
      'reference': 'TEST-001',
      'amount': '1000.00',
      'fee': 15.00,
      'net_amount': 985.00,
      'currency': 'TZS',
      'payment_method': 'mobile_money',
      'provider': 'selcom',
      'provider_reference': 'S20618089300',
      'status': paymentStatus,
      'metadata': null,
      'created_at': '2026-07-03T10:28:57Z',
      'processing_at': '2026-07-03T13:28:57Z',
    },
    'meta': [],
    'request_id': '85323840-963b-4464-897f-12613975b8e3',
  };
}

void main() {
  group('SplashPayClient', () {
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

    test('successful HTTP request returns PaymentResponse', () async {
      adapter.onPost(
        '/payments/mobile-money',
        (server) => server.reply(200, _successMobileMoneyResponse()),
        data: Matchers.any,
      );

      final splashPay = _createSplashPay(adapter);
      final result = await splashPay.mobileMoney(
        amount: 1000,
        phone: '255712345678',
        reference: 'TEST-001',
        customerName: 'John Doe',
        customerEmail: 'john.doe@example.com',
      );

      expect(result.success, isTrue);
      expect(result.code, 'PAYMENT_INITIATED');
      expect(result.paymentStatus, PaymentStatus.pending);
      expect(result.providerReference, 'S20618089300');
    });

    test('sends authentication headers', () async {
      Map<String, dynamic>? capturedHeaders;

      adapter.onPost(
        '/payments/mobile-money',
        (server) => server.reply(200, _successMobileMoneyResponse()),
        data: Matchers.any,
      );

      adapter.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedHeaders = Map<String, dynamic>.from(options.headers);
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
        customerEmail: 'john.doe@example.com',
      );

      expect(capturedHeaders?['X-API-KEY'], 'YOUR_API_KEY');
      expect(capturedHeaders?['X-API-SECRET'], 'YOUR_API_SECRET');
      expect(capturedHeaders?['Content-Type'], 'application/json');
      expect(capturedHeaders?['Accept'], 'application/json');
    });

    test('sends correct request body and endpoint', () async {
      Map<String, dynamic>? capturedBody;
      String? capturedPath;

      adapter.onPost(
        '/payments/mobile-money',
        (server) => server.reply(200, _successMobileMoneyResponse()),
        data: Matchers.any,
      );

      adapter.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedBody = options.data as Map<String, dynamic>?;
            capturedPath = options.path;
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
        customerEmail: 'john.doe@example.com',
      );

      expect(capturedPath, '/payments/mobile-money');
      expect(capturedBody?['amount'], 1000);
      expect(capturedBody?['currency'], 'TZS');
      expect(capturedBody?['reference'], 'TEST-001');
      expect(capturedBody?['phone'], '255712345678');
      expect(capturedBody?['customer_name'], 'John Doe');
      expect(capturedBody?['customer_email'], 'john.doe@example.com');
    });

    test('throws SplashPayTimeoutException on timeout', () async {
      adapter.onPost(
        '/payments/mobile-money',
        (server) => server.throws(
          408,
          DioException(
            requestOptions: RequestOptions(path: '/payments/mobile-money'),
            type: DioExceptionType.receiveTimeout,
            message: 'timeout',
          ),
        ),
        data: Matchers.any,
      );

      final splashPay = _createSplashPay(adapter);

      await expectLater(
        splashPay.mobileMoney(
          amount: 1000,
          phone: '255712345678',
          reference: 'TEST-001',
          customerName: 'John Doe',
          customerEmail: 'john.doe@example.com',
        ),
        throwsA(isA<SplashPayTimeoutException>()),
      );
    });

    test('throws SplashPayNetworkException on network error', () async {
      adapter.onPost(
        '/payments/mobile-money',
        (server) => server.throws(
          0,
          DioException(
            requestOptions: RequestOptions(path: '/payments/mobile-money'),
            type: DioExceptionType.connectionError,
            message: 'connection failed',
          ),
        ),
        data: Matchers.any,
      );

      final splashPay = _createSplashPay(adapter);

      await expectLater(
        splashPay.mobileMoney(
          amount: 1000,
          phone: '255712345678',
          reference: 'TEST-001',
          customerName: 'John Doe',
          customerEmail: 'john.doe@example.com',
        ),
        throwsA(isA<SplashPayNetworkException>()),
      );
    });

    test('throws SplashPayAuthenticationException on 401', () async {
      adapter.onPost(
        '/payments/mobile-money',
        (server) => server.reply(
          401,
          {
            'success': false,
            'code': 'UNAUTHORIZED',
            'message': 'Invalid API credentials.',
          },
        ),
        data: Matchers.any,
      );

      final splashPay = _createSplashPay(adapter);

      await expectLater(
        splashPay.mobileMoney(
          amount: 1000,
          phone: '255712345678',
          reference: 'TEST-001',
          customerName: 'John Doe',
          customerEmail: 'john.doe@example.com',
        ),
        throwsA(isA<SplashPayAuthenticationException>()),
      );
    });

    test('throws SplashPayInvalidResponseException on invalid JSON shape', () async {
      adapter.onPost(
        '/payments/mobile-money',
        (server) => server.reply(200, 'not-json'),
        data: Matchers.any,
      );

      final splashPay = _createSplashPay(adapter);

      await expectLater(
        splashPay.mobileMoney(
          amount: 1000,
          phone: '255712345678',
          reference: 'TEST-001',
          customerName: 'John Doe',
          customerEmail: 'john.doe@example.com',
        ),
        throwsA(isA<SplashPayException>()),
      );
    });
  });
}
