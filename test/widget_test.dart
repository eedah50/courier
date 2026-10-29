import 'package:flutter_test/flutter_test.dart';
import 'package:sekurecourierapp/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SekureDeliveryApp());
    expect(find.text('SEKURE DELIVERY'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
  });
}
