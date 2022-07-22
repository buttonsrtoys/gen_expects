// import 'package:flutter/widgets.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:testable/testers/widget_tests.dart';
//
// void main() {
//   const String text = 'Hello';
//   const textWidget = Text(text);
//   const _prefix = '<SendCheckDataUtils Tests> ';
//
//   group('$_prefix formatAddress tests ', () {
//     test(
//       'Validate address is empty',
//       () {
//         final widgets = <Widget>[
//           const Text(text),
//         ];
//         final widgetMetas = <WidgetMeta>[
//           const WidgetMeta(widget: widget)
//         ]
//
//         final values = widgetMetasFromWidgets(widgets);
//
//         expect(values, true);
//       },
//     );
//   });
// }
/*
final currentWidgetMetas = widgetMetasFromWidgets(widgets);
final deltaWidgetMetas = _getDeltaWidgetMetas(currentWidgetMetas, _previousWidgetMetas);
currentWidgetMetas.addAll(deltaWidgetMetas);
final currentExpectStrings = _expectStringsFromWidgetMetas(currentWidgetMetas);
final deltaExpectStrings = _getDeltaExpectStrings(currentExpectStrings, _previousExpectStrings);
 */
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gen_expects/generate_widget_tests.dart';
import 'package:gen_expects/register_types.dart';

MaterialApp testApp(Widget widget) {
  return MaterialApp(
    home: widget,
  );
}

void main() {
  const text = 'Testing 1, 2, 3';
  const valueKey = ValueKey('__MyKeyClassName__myKeyName__');
  const keyName = 'MyKeyClassName.myKeyName';
  const textWidgetNoKey = Text(text);
  const textWidgetWithKey = Text(
    text,
    key: valueKey,
  );
  final textButtonWithKey = TextButton(
    key: valueKey,
    onPressed: () {},
    child: textWidgetNoKey,
  );
  final textButtonNoKey = TextButton(
    onPressed: () {},
    child: textWidgetNoKey,
  );

  setUpAll(() {
    // registerClassTypes({});
  });

  void expectInstructions(List<String> output) {
    expect(output.isNotEmpty, true);
    expect(output[0], '/// Replace your call to generateWidgetTests with the code below.');
  }

  group('Individual widget tests', () {
    testWidgets('Text widget without key create nothing', (WidgetTester tester) async {
      final app = testApp(textWidgetNoKey);
      await tester.pumpWidget(app);

      final output = await genExpectsOutput(tester, testAppType: MaterialApp);

      expect(output.length, 0);
    });

    testWidgets('Text widget with key creates expectWidget', (WidgetTester tester) async {
      final app = testApp(textWidgetWithKey);
      await tester.pumpWidget(app);

      final output = await genExpectsOutput(tester);

      expect(output[1], "\ttester.expectWidget(text: '$text', key: $keyName);");
    });

    testWidgets('TextButton key creates expect with find.byKey', (WidgetTester tester) async {
      final app = testApp(textButtonWithKey);
      await tester.pumpWidget(app);

      final output = await genExpectsOutput(tester);

      expect(output[1], "\texpect(find.byKey($keyName), findsOneWidget);");
    });

    testWidgets('registerClassTypes adds a Type that is in a generated find.byType test', (WidgetTester tester) async {
      final app = testApp(textButtonNoKey);
      await tester.pumpWidget(app);

      registerTypes({TextButton});

      final output = await genExpectsOutput(tester);

      expect(output[1], '\texpect(find.byType(TextButton), findsOneWidget);');
    });
  });
}
