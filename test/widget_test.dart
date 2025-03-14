// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';

// Ana uygulama dosyasını import ediyoruz
import 'package:zenvivatodo/main.dart';

void main() {
  testWidgets('Başlangıç testi', (WidgetTester tester) async {
    // Uygulamayı çalıştır ve bir kare işlensin
    await tester.pumpWidget(const MyApp());

    // Uygulama başlığını kontrol et
    expect(find.text('Zenviva'), findsOneWidget);
  });
}
