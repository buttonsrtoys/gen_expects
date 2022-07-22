import 'package:flutter_test/flutter_test.dart';

/// Types of matchers used in 'expect'
enum MatcherTypes {
  FINDS_NOTHING,
  FINDS_ONE_WIDGET,
  FINDS_WIDGETS,
  UNKNOWN,
}

extension MatcherTypesExtension on MatcherTypes {
  Matcher get matcher {
    switch (this) {
      case MatcherTypes.FINDS_NOTHING:
        return findsNothing;
      case MatcherTypes.FINDS_ONE_WIDGET:
        return findsOneWidget;
      case MatcherTypes.FINDS_WIDGETS:
        return findsWidgets;
      default:
        return findsNothing;
    }
  }

  String get matcherName {
    switch (this) {
      case MatcherTypes.FINDS_NOTHING:
        return 'findsNothing';
      case MatcherTypes.FINDS_ONE_WIDGET:
        return 'findsOneWidget';
      case MatcherTypes.FINDS_WIDGETS:
        return 'findsWidgets';
      case MatcherTypes.UNKNOWN:
      default:
        return '(Unknown)';
    }
  }
}
