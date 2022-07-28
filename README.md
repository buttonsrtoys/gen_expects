# gen_expects

`gen_expects` is a code generator for expect statements in test.

Rather than generating a `.dart` test file, `gen_expects` runs within your test and output `expect` statements for widgets it finds in the active widget tree.

E.g., you write a test file that calls `genExpects`:

    void main() {
        testWidgets('Confirm all widgets appear', (WidgetTester tester) async {
            await tester.pumpWidget(const MyApp());

            await genExpects(tester);
        });
    }

The `tester.pumpWidget` statement loads the widget tree and then `genExpects` walks the tree and generates expects statements for your custom widgets and widgets with text.

Rather than writing the `expect` statements to file, `genExpects` outputs them to the debug screen or terminal:

	/// Replace your call to generateExpects with the code below.
	expect(find.byType(MyHomePage), findsOneWidget);
	expect(find.byKey(MainKeys.appBar), findsOneWidget);
	expect(find.byType(Fab), findsOneWidget);
	expect(find.text('You have pushed the button this many times:'), findsOneWidget);
	expect(find.text('0'), findsOneWidget);
	expect(find.text('Flutter Demo Home Page'), findsOneWidget);

Following the instructions in the first line of the output, you copy the statements and replace your call to `genExpects`. Your test is now:

    void main() {
        testWidgets('Confirm all widgets appear', (WidgetTester tester) async {
            await tester.pumpWidget(const MyApp());

	        expect(find.byType(MyHomePage), findsOneWidget);
	        expect(find.byKey(MainKeys.appBar), findsOneWidget);
	        expect(find.byType(Fab), findsOneWidget);
	        expect(find.text('You have pushed the button this many times:'), findsOneWidget);
	        expect(find.text('0'), findsOneWidget);
	        expect(find.text('Flutter Demo Home Page'), findsOneWidget);
        });
    }

And your done with your test!

## The details

The widget tree of you test app can be quite large, so rather than include all widgets and generating dozens or hundreds of expects, `gen_expects` includes:

- Widgets with types passed to `widgetTypes`.
- Widgets with text.
- Widgets with keys formatted by `gen_key`.

To pass widget types to `widgetTypes` put them in a set:

    final Set<Type> myWidgetTypes = <Type>{
      Fab,
      MyHomePage,
    };

And then pass them to `genExpects`:

     await genExpects(tester, widgetTypes: myWidgetTypes);

Which will now include `expect` statements for every `widgetType` found:

	/// Replace your call to generateExpects with the code below.
	expect(find.byType(MyHomePage), findsOneWidget);
	expect(find.byType(Fab), findsOneWidget);

`Text` which are a special case. `genExpects` always generates `expect` statements for `TextWidgets`:

	/// Replace your call to generateExpects with the code below.
	expect(find.text('You have pushed the button this many times:'), findsOneWidget);
	expect(find.text('0'), findsOneWidget);
	expect(find.text('Flutter Demo Home Page'), findsOneWidget);

`genExpects` will also always create `expects` for widgets with keys formated by `gen_keys`. Please see the `gen_keys` package for more detail:

	/// Replace your call to generateExpects with the code below.
	expect(find.byKey(MainKeys.appBar), findsOneWidget);

## That's it!

For questions or anything else `gen_expects`, feel free to create an issue of contact me.



