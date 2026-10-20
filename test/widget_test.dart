import 'package:flutter_test/flutter_test.dart';
import 'package:just_jeje/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JustJejeApp());
    expect(find.byType(JustJejeApp), findsOneWidget);
  });
}
