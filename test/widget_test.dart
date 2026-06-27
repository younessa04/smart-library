import 'package:flutter_test/flutter_test.dart';
import 'package:smart_library/main.dart';

void main() {
  testWidgets('Smart Library app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartLibraryApp());
    expect(find.byType(SmartLibraryApp), findsOneWidget);
  });
}
