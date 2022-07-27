import 'dart:convert';
import 'dart:io';

Future<Map<String, List<String>>> loadEnStringReverseLookup(String path) async {
  Future<String> loadData() async {
    final dir = Directory.current.path;
    final File file = File(path);
    return file.readAsStringSync();
  }

  final String enString = await loadData();

  final enStringScrubbed = _removeNonJsonCharacters(enString);

  final enMap = jsonDecode(enStringScrubbed) as Map<String, dynamic>;

  final enReverseLookup = <String, List<String>>{};

  enMap.forEach(
    (key, value) => addToReverseLookup(
      reverseLookupMap: enReverseLookup,
      stringId: key,
      stringContent: value as String,
    ),
  );

  return enReverseLookup;
}

void addToReverseLookup({
  required Map<String, List<String>> reverseLookupMap,
  required String stringId,
  required String stringContent,
}) {
  // Swap key/value so that text keys its original ID
  if (!reverseLookupMap.containsKey(stringContent)) {
    reverseLookupMap[stringContent] = <String>[];
  }
  reverseLookupMap[stringContent]?.add(stringId);

  // Add an all-caps text for the special case when code further modifies text with .toUpperCase()
  final valueUpperCase = stringContent.toUpperCase();
  if (stringContent != valueUpperCase) {
    if (!reverseLookupMap.containsKey(valueUpperCase)) {
      reverseLookupMap[valueUpperCase] = <String>[];
    }
    reverseLookupMap[valueUpperCase]?.add('$stringId.toUpperCase()');
  }
}

String _removeNonJsonCharacters(String enString) {
  return enString.replaceAll('\\\$', '\$').replaceAll('\\*', '*').replaceAll('\\"', '');
}
