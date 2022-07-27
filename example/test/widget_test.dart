import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:gen_expects/generate_widget_tests.dart';

final Set<Type> commonTypes = <Type>{
  Fab,
  MyHomePage,
};

extension TesterX on WidgetTester {
  Future<void> expects() => genExpects(this, commonTypes: commonTypes);
}

void main() {
  testWidgets('Confirm all widgets appear', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Call the function directly, like this
    //
    //    await genExpects(tester, commonTypes: commonTypes);
    //
    // Or better yet, extend tester so you can predefine params for your tests
    await tester.expects();
  });
}
