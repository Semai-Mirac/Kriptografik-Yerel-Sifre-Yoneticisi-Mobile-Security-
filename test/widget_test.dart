import 'package:flutter_test/flutter_test.dart';
import 'package:mobil_guvenlik/main.dart';

void main() {
  testWidgets('Splash opens first then master login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Local Password Manager'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('Master Login'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
  });
}
