/// build_runner annotation for generating key classes
class GenKey {
  /// [keyClasses] is an optional parameter to explicitly list the names of the key classes to be generated. If the
  /// list is empty, all keys within the annotated class will be placed in a respective generated key class.
  /// This parameter is typically only used when the source code contains keys that are declared elsewhere, so do not
  /// need to be generated.
  const GenKey({
    this.keyClasses = const [],
  });

  final List<String> keyClasses;
}
