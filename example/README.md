# example

Example program for `gen_expects`

## To run

In the debugger, open `/example/test/widget_test.dart` and run the test. Or, in the terminal, navigate to `/example` and enter `flutter test`. The `expect` statements will be generated in the debug console or terminal, respectively:

	/// Replace your call to generateExpects with the code below.
	expect(find.byType(MyHomePage), findsOneWidget);
	expect(find.byKey(MainKeys.appBar), findsOneWidget);
	expect(find.byType(Fab), findsOneWidget);
	expect(find.text('You have pushed the button this many times:'), findsOneWidget);
	expect(find.text('0'), findsOneWidget);
	expect(find.text('Flutter Demo Home Page'), findsOneWidget);
