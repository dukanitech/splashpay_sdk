import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:splashpay_sdk/splashpay_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.example');
  await dotenv.load(
    fileName: '.env',
    mergeWith: dotenv.env,
    isOptional: true,
  );
  runApp(const SplashPayDemoApp());
}

class SplashPayDemoApp extends StatelessWidget {
  const SplashPayDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SplashPay SDK Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SplashPayDemoPage(),
    );
  }
}

class SplashPayDemoPage extends StatefulWidget {
  const SplashPayDemoPage({super.key});

  @override
  State<SplashPayDemoPage> createState() => _SplashPayDemoPageState();
}

class _SplashPayDemoPageState extends State<SplashPayDemoPage> {
  late final TextEditingController _apiKeyController;
  late final TextEditingController _apiSecretController;
  final _amountController = TextEditingController(text: '50000');
  final _phoneController = TextEditingController(text: '255712345678');
  final _referenceController = TextEditingController(text: 'TEST-001');
  final _customerNameController = TextEditingController(text: 'John Doe');
  final _customerEmailController = TextEditingController(text: 'john@example.com');

  bool _loading = false;
  String? _resultText;
  late final SplashPayEnvironment _environment;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(
      text: dotenv.env['SPLASHPAY_API_KEY'] ?? '',
    );
    _apiSecretController = TextEditingController(
      text: dotenv.env['SPLASHPAY_API_SECRET'] ?? '',
    );
    _environment = _parseEnvironment(dotenv.env['SPLASHPAY_ENVIRONMENT']);
  }

  SplashPayEnvironment _parseEnvironment(String? value) {
    switch (value?.toLowerCase()) {
      case 'production':
      case 'live':
        return SplashPayEnvironment.production;
      case 'sandbox':
      case 'test':
      default:
        return SplashPayEnvironment.sandbox;
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _apiSecretController.dispose();
    _amountController.dispose();
    _phoneController.dispose();
    _referenceController.dispose();
    _customerNameController.dispose();
    _customerEmailController.dispose();
    super.dispose();
  }

  Future<void> _payWithSplashPay() async {
    final apiKey = _apiKeyController.text.trim();
    final apiSecret = _apiSecretController.text.trim();

    if (apiKey.isEmpty || apiSecret.isEmpty) {
      setState(() {
        _resultText =
            'Please enter API Key and API Secret (or set them in .env).';
      });
      return;
    }

    setState(() {
      _loading = true;
      _resultText = null;
    });

    try {
      final splashPay = SplashPay(
        apiKey: apiKey,
        apiSecret: apiSecret,
        environment: _environment,
      );

      final amount = num.tryParse(_amountController.text.trim()) ?? 0;

      final result = await splashPay.mobileMoney(
        amount: amount,
        phone: _phoneController.text.trim(),
        reference: _referenceController.text.trim(),
        customerName: _customerNameController.text.trim(),
        customerEmail: _customerEmailController.text.trim(),
      );

      setState(() {
        _resultText = '''
Status: ${result.paymentStatus.value}
Transaction ID: ${result.transactionId ?? '-'}
Reference: ${result.reference ?? '-'}
Message: ${result.message ?? '-'}
Code: ${result.code ?? '-'}
''';
      });
    } on SplashPayException catch (e) {
      setState(() {
        _resultText = 'Error: ${e.message}\nCode: ${e.code ?? '-'}';
      });
    } catch (e) {
      setState(() {
        _resultText = 'Unexpected error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SplashPay SDK Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SplashPay SDK Demo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Credentials loaded from .env (${_environment.name})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'YOUR_API_KEY',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiSecretController,
              decoration: const InputDecoration(
                labelText: 'API Secret',
                hintText: 'YOUR_API_SECRET',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(labelText: 'Reference'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customerNameController,
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customerEmailController,
              decoration: const InputDecoration(labelText: 'Customer Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _payWithSplashPay,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('PAY WITH SPLASHPAY'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Result:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_resultText ?? 'No result yet.'),
          ],
        ),
      ),
    );
  }
}
