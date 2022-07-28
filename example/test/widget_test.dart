import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';
import 'package:gen_expects/gen_expects.dart';

/// You can pass a Set of widget types to [genExpects] and it will create expect statements if it finds them in the
/// widget tree.
final Set<Type> widgetTypes = <Type>{
  Fab,
  MyHomePage,
};

/// Consider extending WidgetTester instead of typing
///
///     genExpects(tester, widgetTypes: widgetTypes);
///
/// you type
///
///     tester.expects();
extension TesterX on WidgetTester {
  Future<void> expects() => genExpects(this, widgetTypes: widgetTypes);
}

void main() {
  testWidgets('Confirm all widgets appear', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Call the function directly, like this
    //
    //    await genExpects(tester, widgetTypes: widgetTypes);
    //
    // Or better yet, extend tester so you can predefine params for your tests
    await tester.expects();
  });
}
