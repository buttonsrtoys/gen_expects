import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gen_expects/gen_expects.dart';

MaterialApp _buildApp(Widget widget) {
  return MaterialApp(
    home: MyCustomClass(
      widget: widget,
    ),
  );
}

class MyCustomClass extends StatelessWidget {
  const MyCustomClass({
    required this.widget,
    Key? key,
  }) : super(key: key);

  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget,
    );
  }
}

enum MyEnumKeys {
  myKeyName,
}

void main() {
  const textNotInLookup = 'I am text that is not in the lookup map';
  const text = 'Testing 1, 2, 3';
  const textUpperCase = 'TESTING 1, 2, 3';
  const textStringId = 'testing123';
  const anotherTextStringId = 'anotherTesting123';
  const valueKey = ValueKey('__MyKeyClassName__myKeyName');
  const keyName = 'MyKeyClassName.myKeyName';
  const enumKeyName = 'MyEnumKeys.myKeyName';
  const textWidgetNoKey = Text(text);
  const textWidgetUpperCase = Text(textUpperCase);
  const textWidgetWithKeyAndNotInLookup = Text(
    textNotInLookup,
    key: valueKey,
  );
  const textWidgetWithKey = Text(
    text,
    key: valueKey,
  );
  final textButtonWithKey = TextButton(
    key: valueKey,
    onPressed: () {},
    child: textWidgetNoKey,
  );
  final textButtonWithEnumKey = TextButton(
    key: const ValueKey(MyEnumKeys.myKeyName),
    onPressed: () {},
    child: textWidgetNoKey,
  );
  final textButtonNoKey = TextButton(
    onPressed: () {},
    child: textWidgetNoKey,
  );

  setUp(() {
    registerTypes({MyCustomClass});
  });

  setUpAll(() async {
    await addTextToIntlReverseLookup(stringContent: text, stringId: textStringId);
    return addTextToIntlReverseLookup(stringContent: text, stringId: anotherTextStringId);
  });

  /// Tests require compareWithPrevious=false to ensure behavior does not span calls to testWidget
  group('Widget tests for different Finders', () {
    testWidgets('Text not in lookup map passed to the "text:" parameter of expectWidget, key passed to "key:"',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp(textWidgetWithKeyAndNotInLookup));
      await tester.pumpAndSettle();

      final output = await genExpectsOutput(tester, compareWithPrevious: false);

      expect(output.contains(instructions), true);
      expect(output.contains("\ttester.expectWidget(text: '$textNotInLookup', key: $keyName);"), true);
    });

    testWidgets('Text in lookup map passed to the "intl:" parameter of expectWidget, key passed to "key:"',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp(textWidgetWithKey));
      await tester.pumpAndSettle();

      final output = await genExpectsOutput(tester, compareWithPrevious: false);

      expect(output.contains(instructions), true);
      expect(output.contains("\ttester.expectWidget(intl: (s) => s.$textStringId, key: $keyName);"), true);
    });

    testWidgets(
      'Key (no text or type) passed to find.byKey',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildApp(textButtonWithKey));
        await tester.pumpAndSettle();

        final output = await genExpectsOutput(tester, compareWithPrevious: false);

        expect(output.contains(instructions), true);
        expect(output.contains("\texpect(find.byKey($keyName), findsOneWidget);"), true);
      },
    );

    testWidgets(
      'Key (no text or type) passed to find.byKey',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildApp(textButtonWithEnumKey));
        await tester.pumpAndSettle();

        final output = await genExpectsOutput(tester, compareWithPrevious: false);

        await genExpects(tester);
        expect(output.contains(instructions), true);
        expect(output.contains("\texpect(find.byKey(const ValueKey($enumKeyName)), findsOneWidget);"), true);
      },
    );

    testWidgets(
      'Intl text has its key passed to the "intl:" parameter of expectWidget',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildApp(textWidgetNoKey));
        await tester.pumpAndSettle();

        final output = await genExpectsOutput(tester, compareWithPrevious: false);

        expect(output.contains(instructions), true);
        expect(output.contains("\ttester.expectWidget(intl: (s) => s.$textStringId);"), true);
      },
    );

    testWidgets(
      'Intl text in upper case creates expectWidget with .toUpperCase',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildApp(textWidgetUpperCase));
        await tester.pumpAndSettle();

        final output = await genExpectsOutput(tester, compareWithPrevious: false);

        expect(output.contains(instructions), true);
        expect(output.contains("\ttester.expectWidget(intl: (s) => s.$textStringId.toUpperCase());"), true);
      },
    );

    testWidgets(
      'Intl text that matches two keys generates two expectWidget statements',
      (WidgetTester tester) async {
        await tester.pumpWidget(_buildApp(textWidgetNoKey));
        await tester.pumpAndSettle();

        final output = await genExpectsOutput(tester, compareWithPrevious: false);

        expect(output.contains(instructions), true);
        expect(output.contains("\ttester.expectWidget(intl: (s) => s.$textStringId);"), true);
        expect(output.contains("\ttester.expectWidget(intl: (s) => s.$anotherTextStringId);"), true);
      },
    );

    testWidgets('registerTypes results in statement: expect find.byType with the registered type',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildApp(textButtonNoKey));
      await tester.pumpAndSettle();

      final output = await genExpectsOutput(tester, compareWithPrevious: false);

      expect(output.contains(instructions), true);
      expect(output.contains('\texpect(find.byType(MyCustomClass), findsOneWidget);'), true);
    });

    testWidgets('two equal widgets: one test (not two)', (WidgetTester tester) async {
      await tester.pumpWidget(
        _buildApp(
          Column(
            children: [
              textButtonNoKey,
              textButtonNoKey,
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      registerTypes({TextButton});

      final output = await genExpectsOutput(tester, compareWithPrevious: false);

      expect(output.contains(instructions), true);

      int expectCount = 0;
      for (final str in output) {
        if (str == '\texpect(find.byType(TextButton), findsWidgets);') {
          expectCount++;
        }
      }
      expect(expectCount, 1);
    });
  });
}
