import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Rich,
// import '../common_types.dart';
// import '../test_app.dart';
import 'expect_meta.dart';
import 'load_string_en.dart';
import 'matcher_types.dart';
import 'register_types.dart';
import 'widget_meta.dart';

const String instructions = '/// Replace your call to generateExpects with the code below.';
List<WidgetMeta> _previousWidgetMetas = [];
List<String> _previousExpectStrings = [];
bool _isEnStringReverseLookupLoaded = false;
bool _isCommonTypesLoaded = false;
Map<String, List<String>> _enStringReverseLookup = <String, List<String>>{};

/// Output widget tests to the console.
///
/// [silent] determines whether to suppress output to console.
/// [compareWithPrevious] determines whether only changed tests from the previous run are displayed
/// Per EWP-1519, the parameters below are a work in progress
/// [showTip] determines whether the cut-and-paste tip is shown (should be false inside generated widgetTests)
/// [shouldGesture] determines whether to tap, swipe, drag, etc.
/// [copyToClipboard] determines whether to also generate to developer's clipboard,
/// [appGetterText] is a String representation of the build app call.
Future<void> genExpects(
  WidgetTester tester, {
  Type testAppType = MaterialApp,
  Widget Function()? testAppBuilder,
  bool silent = false,
  bool shouldGesture = false,
  bool generateAsFunction = false,
  bool copyToClipboard = true,
  bool showTip = true,
  bool compareWithPrevious = true,
}) async {
  final text = await genExpectsOutput(
    tester,
    testAppType: testAppType,
    testAppBuilder: testAppBuilder,
    silent: silent,
    shouldGesture: shouldGesture,
    generateAsFunction: generateAsFunction,
    copyToClipboard: copyToClipboard,
    showTip: showTip,
    compareWithPrevious: compareWithPrevious,
  );

  _outputText(text);
}

Future<void> _loadEnStringReverseLookupIfNecessary() async {
  if (!_isEnStringReverseLookupLoaded) {
    _enStringReverseLookup = await loadEnStringReverseLookup();
  }
}

Future<void> _loadCommonTypesIfNecessary() async {
  if (!_isCommonTypesLoaded) {
    // Rich,
    // registerTypes(commonTypes);
    _isCommonTypesLoaded = true;
  }
}

/// Manually adds text to the reverse lookup map (instead of loading from file).
/// [markEnStringFileAsLoaded] as true blocks loads from file. This is primarily for testing.
@visibleForTesting
Future<void> addTextToIntlReverseLookup({
  required String stringId,
  required String stringContent,
  bool markEnStringFileAsLoaded = true,
}) async {
  if (markEnStringFileAsLoaded) {
    _isEnStringReverseLookupLoaded = true;
  }

  addToReverseLookup(
    reverseLookupMap: _enStringReverseLookup,
    stringId: stringId,
    stringContent: stringContent,
  );
}

/// See [genExpects] for parameter docs
@visibleForTesting
Future<List<String>> genExpectsOutput(
  WidgetTester tester, {
  // Rich,
  // Type testAppType = TestApp,
  Type testAppType = MaterialApp,
  Widget Function()? testAppBuilder,
  bool silent = false,
  bool shouldGesture = false,
  bool generateAsFunction = false,
  bool copyToClipboard = true,
  bool showTip = true,
  bool compareWithPrevious = true,
}) async {
  assert(!shouldGesture || testAppBuilder != null);

  await _loadEnStringReverseLookupIfNecessary();
  await _loadCommonTypesIfNecessary();

  final text = <String>[];
  late BuildContext context;

  if (!compareWithPrevious) {
    _previousWidgetMetas = [];
    _previousExpectStrings = [];
  }

  try {
    find.byType(testAppType);
    context = tester.element(find.byType(testAppType));
  } catch (e) {
    // If here, the user probably forgot 'await' and the tester widget tree was deleted by the time this find
    // was performed.
    text.add(
      'No ancestors found of type $testAppType at the top of the widget tree. Did you forget "await" before '
      '"dumpWidgets"?',
    );
    return text;
  }

  final widgets = _getWidgetsForExpects(context);

  if (widgets.isEmpty) {
    text.add(
      'No widgets found with keys created by @GenKey. Did you add @GenKey above a class with keys?\n',
    );
  } else {
    text.addAll(
      await _generateExpectsForWidgets(
        widgets,
        tester: tester,
        testAppType: testAppType,
        shouldGesture: shouldGesture,
        generateAsFunction: generateAsFunction,
        showTip: showTip,
        testAppBuilder: testAppBuilder,
        silent: silent,
      ),
    );
  }

  return text;
}

Future<List<String>> _generateExpectsForWidgets(
  List<Widget> widgets, {
  required WidgetTester tester,
  required Type testAppType,
  required bool shouldGesture,
  required bool generateAsFunction,
  required bool showTip,
  required bool silent,
  Widget Function()? testAppBuilder,
}) async {
  final text = <String>[];

  if (!silent && generateAsFunction) {
    const testDescription = 'Confirm widgets display';
    text.add("testWidgets('$testDescription', (WidgetTester tester) async {");
    text.add('\tawait tester.pumpWidget(TestApp());');
  }

  final currentWidgetMetas = widgetMetasFromWidgets(widgets);
  final deltaWidgetMetas = _getDeltaWidgetMetas(currentWidgetMetas, _previousWidgetMetas);
  currentWidgetMetas.addAll(deltaWidgetMetas);
  final currentExpectStrings = _expectStringsFromWidgetMetas(currentWidgetMetas);
  final deltaExpectStrings = _getDeltaExpectStrings(currentExpectStrings, _previousExpectStrings);

  if (!silent) {
    if (deltaExpectStrings.isEmpty) {
      if (_previousWidgetMetas.isEmpty) {
        text.add('/// No widget with keys or custom types found to test');
      } else {
        text.add("/// No changes to widget with keys or custom types since the prior call to 'generateExpects'");
      }
    } else {
      if (showTip) {
        text.add(instructions);
      }
      text.addAll(deltaExpectStrings);
    }
  }

  _previousWidgetMetas = currentWidgetMetas;
  _previousExpectStrings = currentExpectStrings;

  if (!silent && generateAsFunction) {
    text.add('});');
  }

  if (shouldGesture) {
    text.addAll(
      await _outputWidgetTestsWithGestures(
        currentWidgetMetas,
        tester: tester,
        testAppType: testAppType,
        testAppBuilder: testAppBuilder,
      ),
    );
  }

  return text;
}

List<String> _getDeltaExpectStrings(List<String> currentExpectStrings, List<String> previousExpectStrings) {
  final deltaExpectStrings = currentExpectStrings.where((item) => !previousExpectStrings.contains(item)).toList();

  return deltaExpectStrings;
}

/// Convert Widgets into [WidgetMeta]s
///
/// Result contains no duplicates (because duplicate [WidgetMeta]s result in duplicate generated tests
List<WidgetMeta> widgetMetasFromWidgets(List<Widget> widgets) {
  final widgetMetas = <WidgetMeta>[];

  for (final widget in widgets) {
    // Ignore widgets Flutter adds with prefixes (e.g., "[key <")
    if (widget.key == null || _isProperlyFormattedKey(widget)) {
      final widgetMeta = WidgetMeta(widget: widget);
      if (!widgetMetas.contains(widgetMeta)) {
        widgetMetas.add(widgetMeta);
      }
    }
  }

  return widgetMetas;
}

bool _isProperlyFormattedKey(Widget widget) => widget.key.toString().indexOf('[<') == 0;

/// The order to output expects
enum _ExpectTypeOrder {
  NO_TEXT,
  INTL_TEXT,
  NON_INTL_TEXT,
}

/// Generates expect() strings from [WidgetMeta]s. Sorts strings in order of [_ExpectTypeOrder]
List<String> _expectStringsFromWidgetMetas(List<WidgetMeta> widgetMetas) {
  final expectMetas = <ExpectMeta>[];
  final expectStrings = <String>[];

  for (final widgetMeta in widgetMetas) {
    final expectMetaFromWidgetMeta = _expectMetaFromWidgetMeta(widgetMeta);
    expectMetas.add(expectMetaFromWidgetMeta);
  }

  int _sortOrder(ExpectMeta expectMeta) {
    _ExpectTypeOrder result = _ExpectTypeOrder.NO_TEXT;
    if (expectMeta.widgetMeta.hasText) {
      result = _ExpectTypeOrder.INTL_TEXT;
      if (!expectMeta.isIntl) {
        result = _ExpectTypeOrder.NON_INTL_TEXT;
      }
    }
    return result.index;
  }

  expectMetas.sort((a, b) => _sortOrder(a).compareTo(_sortOrder(b)));

  bool generatedNonIntlTextComment = false;

  for (final expectMeta in expectMetas) {
    if (!generatedNonIntlTextComment && _sortOrder(expectMeta) == 2) {
      generatedNonIntlTextComment = true;
      expectStrings.add('\t// No matches in en_string.json for the expect statements below');
    }

    final expectStringsFromWidgetMeta = _expectStringsFromExpectMeta(expectMeta);
    expectStrings.addAll(expectStringsFromWidgetMeta);
  }

  return expectStrings;
}

void _outputText(List<String> strings) {
  for (final expectString in strings) {
    debugPrint('\t$expectString');
  }
}

List<WidgetMeta> _getDeltaWidgetMetas(List<WidgetMeta> currentWidgetMetas, List<WidgetMeta> previousWidgetMetas) {
  final deltaPreviousWidgetMetas = previousWidgetMetas.where((item) => !currentWidgetMetas.contains(item)).toList();

  // Matchers may have changed for the previous tests (e.g., findsOneWidget may now be findNothing), so update
  final updatedDeltaPreviousWidgetMetas =
      deltaPreviousWidgetMetas.map((widgetMeta) => WidgetMeta(widget: widgetMeta.widget)).toList();

  return updatedDeltaPreviousWidgetMetas;
}

/// Per EWP-1519, this is a work in progress
Future<List<String>> _outputWidgetTestsWithGestures(
  List<WidgetMeta> widgetMetas, {
  required WidgetTester tester,
  required Type testAppType,
  Widget Function()? testAppBuilder,
}) async {
  final text = <String>[];

  text.add('/// Copy the code below and paste it in your main()');
  for (final widgetMeta in widgetMetas) {
    final gestureName = getGesture(widgetMeta.widgetKey);
    if (gestureName == 'onTap') {
      final testDescription = 'Tap ${widgetMeta.widgetKey}';
      text.add("testWidgets('$testDescription', (WidgetTester tester) async {");
      text.add('\tawait tester.pumpWidget(TestApp());');
      text.add('\tawait tester.pumpAndSettle();');
      await tester.pumpWidget(testAppBuilder!());
      await tester.pumpAndSettle();
      await genExpectsOutput(
        tester,
        silent: true,
      );
      try {
        await tester.tap(find.byKey(widgetMeta.widget.key!));
        await tester.pumpAndSettle();
        text.add('\tawait tester.tap(find.byKey(${widgetMeta.widgetKey}));');
        text.add('\tawait tester.pumpAndSettle();');
        text.addAll(
          await genExpectsOutput(
            tester,
            showTip: false,
          ),
        );
      } catch (e) {
        text.add('\t// The following line threw an exception');
        text.add('\t// await tester.tap(find.byKey(${widgetMeta.widgetKey}));');
      }
      text.add('});');
    }
  }

  return text;
}

/// Output a sample test app and code to generate the first test
///
/// This effectively outputs a help template to get users started.
///
/// Per EWP-1519, this is a work in progress
void generateSetup({
  String testAppGetterText = 'TestApp()',
  MaterialApp Function()? testAppGetter,
}) {
  final text = <String>[];

  text.addAll(_dumpTestApp());
  text.addAll(_dumpFirstTest(testAppGetterText));

  _outputText(text);
}

/// Dump a simple test app to the console for the user to use as a template
/// Per EWP-1519, this is a work in progress
List<String> _dumpTestApp({Type testAppType = MaterialApp}) {
  final text = <String>[];

  text.add('/// Copy the imports and class below and paste it above your test main(). Customize as needed.');
  text.add("import 'package:flutter/material.dart';");
  text.add("import 'package:flutter_test/flutter_test.dart';");
  text.add('class TestApp extends StatelessWidget {');
  text.add('\tconst TestApp({Key? key}) : super(key: key);');
  text.add('\t@override');
  text.add('\tWidget build(BuildContext context) {');
  text.add('\t\treturn const $testAppType(');
  text.add('\t\t\thome: MyWidget(),');
  text.add('\t\t\tdebugShowCheckedModeBanner: false,');
  text.add('\t\t);');
  text.add('\t}');
  text.add('}');

  return text;
}

/// Dump a simple test for the user to use to generate more tests
/// Per EWP-1519, this is a work in progress
List<String> _dumpFirstTest(String testAppGetterText) {
  final text = <String>[];

  text.add('\t$instructions');
  text.add("\ttestWidgets('Test for initial widgets', (WidgetTester tester) async {");
  text.add('\t\tawait tester.pumpWidget($testAppGetterText);');
  text.add('\t\tgenerateExpects(tester, testAppType: MaterialApp, shouldGesture:true);');
  text.add('\t});');

  return text;
}

/// Get all the widgets of interest for testing (e.g., has keys, has text, is registered)
///
/// Traverses the widget testing tree to build a list of widgets for testing.
///
/// The returned list is in no particular order.
List<Widget> _getWidgetsForExpects(
  BuildContext context,
) {
  final widgets = <Widget>[];

  bool _isEmptyTextWidget(Widget widget) {
    final bool result;
    if (widget is Text && (widget.data == null || widget.data == '')) {
      result = true;
    } else {
      result = false;
    }
    return result;
  }

  bool _isWidgetForExpect(Widget widget) {
    final bool result;
    if (_isEmptyTextWidget(widget)) {
      result = false;
    } else {
      result = (widget.key != null && widget.key.toString().contains('__')) ||
          registeredTypes.contains(widget.runtimeType) ||
          WidgetMeta.isTextEnabled(widget);
    }
    return result;
  }

  void visitor(Element element) {
    final widget = element.widget;
    if (_isWidgetForExpect(widget)) {
      widgets.add(widget);
    }
    element.visitChildren(visitor);
  }

  context.visitChildElements(visitor);

  return widgets;
}

List<String> _expectStringsFromExpectMeta(ExpectMeta expectMeta) {
  final expects = <String>[];

  // Number of attributes (e.g., Type, key, text) to match in expect
  final int attributesToMatchCount = (expectMeta.widgetMeta.widgetKey.isNotEmpty ? 1 : 0) +
      (expectMeta.widgetMeta.widgetText.isNotEmpty ? 1 : 0) +
      (expectMeta.widgetMeta.isWidgetTypeRegistered ? 1 : 0);

  if (attributesToMatchCount >= 1) {
    if (_haveEnString(expectMeta.widgetMeta.widgetText) || attributesToMatchCount >= 2) {
      expects.addAll(_generateExpectWidgets(expectMeta.widgetMeta, attributesToMatchCount));
    } else {
      expects.add(_generateExpect(expectMeta.widgetMeta));
    }
  }

  return expects;
}

String _generateExpect(WidgetMeta widgetMeta) {
  late final String generatedExpect;

  if (widgetMeta.widgetKey.isNotEmpty) {
    generatedExpect = '\texpect(find.byKey(${widgetMeta.widgetKey}), ${widgetMeta.matcherType.matcherName});';
  } else if (widgetMeta.widgetText.isNotEmpty) {
    generatedExpect = "\texpect(find.text('${widgetMeta.widgetText}'), ${widgetMeta.matcherType.matcherName});";
  } else if (widgetMeta.isWidgetTypeRegistered) {
    generatedExpect = '\texpect(find.byType(${widgetMeta.widgetType}), ${widgetMeta.matcherType.matcherName});';
  } else {
    generatedExpect = '(Internal error. Expect not generated.)';
  }

  return generatedExpect;
}

ExpectMeta _expectMetaFromWidgetMeta(WidgetMeta widgetMeta) {
  final expectMeta = ExpectMeta(widgetMeta: widgetMeta);

  if (widgetMeta.widgetText.isNotEmpty) {
    if (_haveEnString(widgetMeta.widgetText)) {
      expectMeta.intlKeys = _enStringReverseLookup[widgetMeta.widgetText];
    }
  }

  return expectMeta;
}

List<String> _generateExpectWidgets(WidgetMeta widgetMeta, int attributesToMatch) {
  final buffer = StringBuffer();
  const intlPlaceHolder = '__INTL_PLACE_HOLDER__';
  List<String>? intlKeys;
  int attributesWrittenToBuffer = 0;

  void _addTextAttributeToBuffer() {
    if (_haveEnString(widgetMeta.widgetText)) {
      intlKeys = _enStringReverseLookup[widgetMeta.widgetText];
      if (intlKeys != null) {
        buffer.write("intl: (s) => s.$intlPlaceHolder");
      }
    } else {
      buffer.write("text: '${widgetMeta.widgetText}'");
    }
  }

  void _addTypeAttributeToBuffer() {
    buffer.write('widgetType: ${widgetMeta.widgetType}');
  }

  void _addKeyAttributeToBuffer() {
    buffer.write("key: ${widgetMeta.widgetKey}");
  }

  void _addMatcherAttributeToBuffer() {
    buffer.write(', matcher: ${widgetMeta.matcherType.matcherName},');
  }

  bool _haveMoreAttributesToProcess() => ++attributesWrittenToBuffer < attributesToMatch;

  buffer.write('\ttester.expectWidget(');

  if (widgetMeta.widgetText.isNotEmpty) {
    _addTextAttributeToBuffer();
    if (_haveMoreAttributesToProcess()) {
      buffer.write(', ');
    }
  }

  if (widgetMeta.isWidgetTypeRegistered) {
    _addTypeAttributeToBuffer();
    if (_haveMoreAttributesToProcess()) {
      buffer.write(', ');
    }
  }

  if (widgetMeta.widgetKey.isNotEmpty) {
    _addKeyAttributeToBuffer();
  }

  if (widgetMeta.matcherType.matcher != findsOneWidget) {
    _addMatcherAttributeToBuffer();
  }

  buffer.write(');');

  final result = <String>[];

  if (intlKeys == null) {
    result.add(buffer.toString());
  } else {
    final bufferString = buffer.toString();
    if (intlKeys!.length > 1) {
      result.add('\t// Multiple matches for "${widgetMeta.widgetText}" in string_en.json. Pick one.');
    }
    for (final intlKey in intlKeys!) {
      result.add(bufferString.replaceAll(intlPlaceHolder, intlKey));
    }
    if (intlKeys!.length > 1) {
      result.add('\t// (End of matches)');
    }
  }

  return result;
}

bool _haveEnString(key) {
  return _enStringReverseLookup.containsKey(key);
}

/// Meta data for gestures
/// Per EWP-1519, this is a work in progress
class _GestureMeta {
  _GestureMeta(this.keyword, this.gestureCallbackName);

  String keyword;
  String gestureCallbackName;

  static List<_GestureMeta> get all => <_GestureMeta>[
        _GestureMeta('button', 'onTap'),
        _GestureMeta('toggle', 'onTap'),
      ];
}

/// Get the gesture associated with the widget key name. E.g., [keyName] containing "button" returns "tap"
String? getGesture(String keyName) {
  String? gestureName;

  if (keyName.isNotEmpty) {
    final keyNameLowerCase = keyName.toLowerCase();
    for (final gestureMeta in _GestureMeta.all) {
      if (keyNameLowerCase.contains(gestureMeta.keyword)) {
        gestureName = gestureMeta.gestureCallbackName;
      }
    }
  }

  return gestureName;
}
