import 'package:flutter_test/flutter_test.dart';
import 'package:mobil_guvenlik/main.dart';

void main() {
  testWidgets('Master login screen opens first', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Master Login'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
  });
}

