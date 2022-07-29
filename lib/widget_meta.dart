part of 'gen_expects.dart';

/// Meta data for widget selected for inclusion in tests
class WidgetMeta {
  WidgetMeta({
    required this.widget,
  }) {
    _updateWidgetKey();
    widgetType = widget.runtimeType;
    isWidgetTypeRegistered = registeredTypes.contains(widgetType);
    _updateWidgetText();
    _updateMatcher();

    assert(
        widgetKey.isNotEmpty || isWidgetTypeRegistered || widgetText.isNotEmpty,
        'WidgetMeta widget is not valid');
  }

  @override
  bool operator ==(Object other) {
    if (other is WidgetMeta) {
      return widgetKey == other.widgetKey &&
          widgetText == other.widgetText &&
          widgetType == other.widgetType;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => widget.hashCode;

  final Widget widget;

  /// These fields are used repeatedly so their values are cached
  late MatcherTypes matcherType;
  late final String widgetKey;
  late final String widgetText;
  late final Type widgetType;
  late final bool isWidgetTypeRegistered;

  /// If widget has text, get it
  void _updateWidgetText() {
    switch (widget.runtimeType) {
      case Text:
        final text = widget as Text;
        widgetText = text.data ?? '';
        break;
      case TextSpan:
        final text = widget as TextSpan;
        widgetText = text.text ?? '';
        break;
      default:
        widgetText = '';
    }
  }

  bool get hasText => isTextEnabled(widget);

  static bool isTextEnabled(Widget widget) {
    final runtimeType = widget.runtimeType;
    return runtimeType == Text || runtimeType == TextSpan;
  }

  /// Perform a test on the widget and store its result
  void _updateMatcher() {
    matcherType = MatcherTypes.UNKNOWN;

    for (final currentMatcherType in MatcherTypes.values) {
      try {
        if (widgetKey.isNotEmpty) {
          expect(find.byKey(widget.key!), currentMatcherType.matcher);
        } else if (widgetText.isNotEmpty) {
          expect(find.text(widgetText), currentMatcherType.matcher);
        } else if (isWidgetTypeRegistered) {
          expect(find.byType(widgetType), currentMatcherType.matcher);
        }

        // if here, expect didn't throw, so we have our matcher type
        matcherType = currentMatcherType;
        break;
      } catch (e) {
        // Do nothing. Ignore tests that fail
      }
    }
  }

  /// Parse the string key back into its keysClass.keyName format
  ///
  /// If there are 2 words in the widgetKey, it's a field key (keyClass.keyName).
  /// If there are 3 words, it's a function name (keyClass.keyName(index)).
  ///
  /// Widget keys without the Enzo '__' delimiter return an empty string.
  ///
  /// Note that flutter adds a prefix ('[<') and suffix ('>]') to keys that must be removed.
  void _updateWidgetKey() {
    if (widget.key == null) {
      widgetKey = '';
    } else {
      final originalWidgetKey = widget.key.toString();
      if (_isWidgetKeyProperlyFormatted(originalWidgetKey)) {
        final strippedWidgetKey = originalWidgetKey.replaceAll("'", '');
        final startIndex = strippedWidgetKey.indexOf('[<');
        final endIndex = strippedWidgetKey.indexOf('>]');
        final trimmedWidgetKey =
            strippedWidgetKey.substring(startIndex + 2, endIndex);
        final words = trimmedWidgetKey.split(RegExp("__|_"));
        words.removeWhere((word) => word == '');

        if (words.length == 2) {
          widgetKey = '${words[0]}.${words[1]}';
        } else if (words.length == 3) {
          widgetKey = '${words[0]}.${words[1]}(${words[2]})';
        } else {
          /// If here, must be an unsupported key. Do nothing
          widgetKey = '';
        }
      }
    }
  }

  bool _isWidgetKeyProperlyFormatted(String originalWidgetKey) =>
      originalWidgetKey.contains('__') &&
      originalWidgetKey.contains('[<') &&
      originalWidgetKey.contains('>]');
}
