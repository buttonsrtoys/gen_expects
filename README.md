# gen_expects

![gen_expects](https://github.com/buttonsrtoys/gen_expects/blob/main/assets/GenExpectsLogo.png)

Code generator that walks the widget tree of a test app and generates expect statements for Flutter widgets tests.

## How to use GenExpects

Insert a call to `genExpects` into your widget test:

    void main() {
        testWidgets('Confirm all widgets appear', (WidgetTester tester) async {
            await tester.pumpWidget(const MyApp());

            await genExpects(tester);
        });
    }

GenExpects walks the widget tree of your test app and generates expect statements. Rather than generating a `.dart` test file, GenExpects outputs to the debug console or terminal:

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

The widget tree of your test app can be quite large, so rather than include all widgets and generating dozens or hundreds of expects, GenExpects generates `expects` for:

- Widgets with types passed to the `widgetTypes` parameter.
- Text widgets.
- Widgets with keys of type `ValueKey(<enum value>)`
- Widgets with keys formatted by [gen_keys](https://pub.dev/packages/gen_keys).

### Expects for widget types

To pass widget types to `widgetTypes` put them in a `Set`:

    final Set<Type> myWidgetTypes = <Type>{
      Fab,
      MyHomePage,
    };

And then pass the `Set` to `genExpects`:

     await genExpects(tester, widgetTypes: myWidgetTypes);

GenExpects generates an `expect` statement for every `widgetType` found:

	/// Replace your call to generateExpects with the code below.
	expect(find.byType(MyHomePage), findsOneWidget);
	expect(find.byType(Fab), findsOneWidget);

### Expects for Text widgets

`Text` widgets always generates `expect` statements:

	/// Replace your call to generateExpects with the code below.
	expect(find.text('You have pushed the button this many times:'), findsOneWidget);
	expect(find.text('0'), findsOneWidget);
	expect(find.text('Flutter Demo Home Page'), findsOneWidget);

### Expects for widgets with keys of type `ValueKey(<enum type>)`

GenExpects supports `ValueKey` for enum types. Typically, if you have a class named `MyClass`, 
create an `enum` for storing keys. GenExpects looks for keys in enum format and exports them to 
expects. (Note that GenExpects generates `expect` statements only for public keys . Private enums
(e.g., `_MyClassKeys`) are not supported. 

To created enum keys:

    class MyClass extends StatelessWidget {
        :
        Container(key: const ValueKey(MyClassKeys.topContainer);
        :
    }

    enum MyClassKeys {
        topContainer,
    }

GenExpects will generate:

	/// Replace your call to generateExpects with the code below.
	expect(find.byKey(const ValueKey(MyClassKeys.topContainer)), findsOneWidget);

### Expects for widgets with keys

GenExpects also creates `expects` for widgets with keys formatted by `gen_keys`. Please see the [gen_keys package](https://pub.dev/packages/gen_keys) for more detail:

	/// Replace your call to generateExpects with the code below.
	expect(find.byKey(MainKeys.appBar), findsOneWidget);

## Use after gestures, too!

GenExpects generates `diff` outputs when run in the same widget test. E.g.,

        testWidgets('Confirm all widgets appear', (WidgetTester tester) async {
            await tester.pumpWidget(const MyApp());

	        genExpects(tester);              // <- Outputs all found expects
	        tester.tap(find.byType(Fab));    // <- Gesture
	        genExpects(tester);              // <- Outputs only expects that changed
        });

Because the second call to `genExpects` only outputs changes, it is handy for writing tests with gestures and for debugging.

## That's it!

For questions or anything else GenExpects, feel free to create an issue or contact me.
