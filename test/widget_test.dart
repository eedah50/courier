import 'package:flutter_test/flutter_test.dart';
import 'package:sekurecourierapp/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SekureCourierApp());
    expect(find.text('SEKURE COURIER'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
  });
}
