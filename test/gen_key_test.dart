import 'package:flutter_test/flutter_test.dart';
import 'package:gen_key/functions.dart';

void main() {
  const prefix = '<KeysFileBuilder Tests> ';
  const keyClassName = 'MyClassKeys';
  const keyName = 'myKey';
  const fullKeyName = '$keyClassName.$keyName';
  const anotherFullKeyNameWithSameKeyClass = '$keyClassName.anotherKeyName';
  const anotherFullKeyNameWithDifferentKeyClass = 'anotherClassKeys.anotherKeyName';
  const keyClassesOneClass = <String>[keyClassName];
  const keyClassesNoClasses = <String>[];

  String mockCode(
    String key0,
    String punctuation0, [
    String key1 = '',
    String punctuation1 = '',
  ]) {
    return """
class _Cta extends StatelessWidget {
  const _Cta({
    required this.buttonText,
    required this.onTapFunc,
    Key? key,
  }) : super(key: key);

  final String? buttonText;
  final void Function() onTapFunc;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomCenter,
    child: Column(
      children: [
      EnzoCtaButton(
        key: $key0$punctuation0
        text: buttonText ?? '',
        isEnabled: true,
        onPressed: onTapFunc,
      ),
      Text(
        'blah',
        key: $key1$punctuation1
      ),
  );
}
""";
  }

  group('$prefix key generation ', () {
    test('generates for key followed by comma', () {
      final sourceCode = mockCode(fullKeyName, ',');
      final keyMetas = keyMetasFromSourceCode(sourceCode, keyClassesNoClasses);
      expect(keyMetas.length, 1);
      final keyDeclaration = keyDeclarationFromKeyMeta(keyMetas[0]);
      expect(keyDeclaration, "\tstatic const Key myKey = Key('\${_prefix}$keyName');");
    });

    test('generates for key followed by parenthesis', () {
      final sourceCode = mockCode(fullKeyName, ')');
      final keyMetas = keyMetasFromSourceCode(sourceCode, keyClassesNoClasses);
      expect(keyMetas.length, 1);
      final keyDeclaration = keyDeclarationFromKeyMeta(keyMetas[0]);
      expect(keyDeclaration, "\tstatic const Key myKey = Key('\${_prefix}$keyName');");
    });

    test('ignores key followed by space', () {
      final sourceCode = mockCode(fullKeyName, ' ');
      final keyMetas = keyMetasFromSourceCode(sourceCode, keyClassesNoClasses);
      expect(keyMetas.length, 0);
    });

    test('ignores key without period', () {
      final sourceCode = mockCode(keyClassName, ',');
      final keyMetas = keyMetasFromSourceCode(sourceCode, keyClassesNoClasses);
      expect(keyMetas.length, 0);
    });

    test('ignores key with two periods', () {
      final sourceCode = mockCode('$fullKeyName.tooMany', ',');
      final keyMetas = keyMetasFromSourceCode(sourceCode, keyClassesNoClasses);
      expect(keyMetas.length, 0);
    });

    test('generates for indexed key', () {
      final sourceCode = mockCode('$fullKeyName(someIndex)', ',');
      final keyMetas = keyMetasFromSourceCode(sourceCode, keyClassesNoClasses);
      expect(keyMetas.length, 1);
      final keyDeclaration = keyDeclarationFromKeyMeta(keyMetas[0]);
      expect(
        keyDeclaration,
        "\tstatic Key myKey(Object object) => Key('\${_prefix}myKey__\$object');",
      );
    });

    test('generates two keys when key class name is the same', () {
      final sourceCode = mockCode(fullKeyName, ',', anotherFullKeyNameWithSameKeyClass, ',');
      final keyMetas = keyMetasFromSourceCode(sourceCode, keyClassesNoClasses);
      expect(keyMetas.length, 2);
    });

    test('generates two keys when key class names are different', () {
      final sourceCode = mockCode(fullKeyName, ',', anotherFullKeyNameWithDifferentKeyClass, ',');
      final keyMetas = keyMetasFromSourceCode(sourceCode, keyClassesNoClasses);
      expect(keyMetas.length, 2);
    });

    test('ignores a key when key class name not passed as parameter', () {
      final sourceCode = mockCode(fullKeyName, ',', anotherFullKeyNameWithDifferentKeyClass, ',');
      final keyMetas = keyMetasFromSourceCode(sourceCode, keyClassesOneClass);
      expect(keyMetas.length, 1);
    });
  });
}
