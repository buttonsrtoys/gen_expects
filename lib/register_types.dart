part of 'gen_expects.dart';

Set<Type> registeredTypes = {};

/// Register class types for tests with Find.byType
void registerTypes(Set<Type> classTypes) {
  registeredTypes.addAll(classTypes);
}
