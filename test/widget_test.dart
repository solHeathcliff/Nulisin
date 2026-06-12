import 'package:flutter_test/flutter_test.dart';
import 'package:nulisin/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NulisinApp());
    expect(find.byType(NulisinApp), findsOneWidget);
  });
}
