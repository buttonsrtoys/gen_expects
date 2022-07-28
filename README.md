# gen_expects

`gen_expects` is a code generator for expect statements found in Flutter widgets tests.

Rather than generating a `.dart` test file, you insert a `genExpect` call within your widget test:

    void main() {
        testWidgets('Confirm all widgets appear', (WidgetTester tester) async {
            await tester.pumpWidget(const MyApp());

            await genExpects(tester);
        });
    }

and the `genExpects` function walks the widget tree and outputs expect statements to the debug console or terminal:

	/// Replace your call to generateExpects with the code below.
	expect(find.byType(MyHomePage), findsOneWidget);
	expect(find.byKey(MainKeys.appBar), findsOneWidget);
	expect(find.byType(Fab), findsOneWidget);
	expect(find.text('You have pushed the button this many times:'), findsOneWidget);
	expect(find.text('0'), findsOneWidget);
	expect(find.text('Flutter Demo Home Page'), findsOneWidget);

Following the instructions in the first line of the output that reads `/// Replace your call to generateExpects with the code below`, you copy the statements and paste them into your test:

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

And voila! You have written your widget's first test!

## The details

The widget tree of your test app can be quite large, so rather than include all widgets and generating dozens or hundreds of expects, `genExpects` generates `expects` for:

- Widgets with types passed to the `widgetTypes` parameter.
- Text widgets.
- Widgets with keys formatted by `gen_key`.

**Expects for widgetTypes**

To pass widget types to `widgetTypes` put them in a `Set`:

    final Set<Type> myWidgetTypes = <Type>{
      Fab,
      MyHomePage,
    };

And then pass the `Set` to `genExpects`:

     await genExpects(tester, widgetTypes: myWidgetTypes);

`genExpects` generates an `expect` statement for every `widgetType` found:

	/// Replace your call to generateExpects with the code below.
	expect(find.byType(MyHomePage), findsOneWidget);
	expect(find.byType(Fab), findsOneWidget);

**Expects for Text Widgets**

`Text` widgets always generates `expect` statements:

	/// Replace your call to generateExpects with the code below.
	expect(find.text('You have pushed the button this many times:'), findsOneWidget);
	expect(find.text('0'), findsOneWidget);
	expect(find.text('Flutter Demo Home Page'), findsOneWidget);

### Expects for widgets with keys

`genExpects` also creates `expects` for widgets with keys formatted by `gen_key`. Please see the `gen_key` package for more detail:

	/// Replace your call to generateExpects with the code below.
	expect(find.byKey(MainKeys.appBar), findsOneWidget);

## That's it!

For questions or anything else `gen_expects`, feel free to create an issue of contact me.



