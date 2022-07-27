import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:gen_expects/generate_widget_tests.dart';

void main() {
  testWidgets('Confirm all widgets appear', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Show expects to the terminal
    await genExpects(tester, appType: MyApp);
  });
}
