import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:splashpay_sdk_example/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    dotenv.testLoad(fileInput: '''
SPLASHPAY_API_KEY=YOUR_API_KEY
SPLASHPAY_API_SECRET=YOUR_API_SECRET
SPLASHPAY_ENVIRONMENT=sandbox
''');
  });

  testWidgets('demo app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const SplashPayDemoApp());

    expect(find.text('SplashPay SDK Demo'), findsWidgets);
    expect(find.text('PAY WITH SPLASHPAY'), findsOneWidget);
  });
}
