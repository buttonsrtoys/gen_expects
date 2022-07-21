library keys_file_builder;

import 'package:analyzer/dart/element/element.dart' as el;
import 'package:build/build.dart';
import 'package:gen_key/annotations.dart';
import 'package:gen_key/functions.dart';
import 'package:gen_key/key_meta.dart';
import 'package:source_gen/source_gen.dart';

Builder keysFileBuilder(BuilderOptions options) {
  return KeysFileBuilder();
}

class KeysFileBuilder implements Builder {
  KeysFileBuilder();

  @override
  final buildExtensions = const {
    '.dart': ['.keys.dart']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    try {
      final fileInputId = buildStep.inputId;
      final filename = fileInputId.pathSegments.last;
      final keysFileInputId = fileInputId.changeExtension('.keys.dart');
      final keysFilename = keysFileInputId.pathSegments.last;
      final libraryElement = await buildStep.resolver.libraryFor(fileInputId);
      const typeChecker = TypeChecker.fromRuntime(GenKey);
      final annotatedElements = LibraryReader(libraryElement).annotatedWith(typeChecker);

      _throwOnPartOrAnnotationWrong(annotatedElements, keysFilename, filename, libraryElement, fileInputId);

      if (annotatedElements.isNotEmpty) {
        final keyMetas = await _keyMetasFromAnnotatedElements(annotatedElements, buildStep);

        _throwOnAnnotationButNoKeys(keyMetas, fileInputId);

        await _generateKeysFile(filename, keyMetas, buildStep, keysFileInputId);
      }
    } on NonLibraryAssetException {
      // if here, likely hit a file we don't want to process. (e.g., .g.dart file). Do nothing.
    }
  }

  Future<List<KeyMeta>> _keyMetasFromAnnotatedElements(
    Iterable<AnnotatedElement> annotatedElements,
    BuildStep buildStep,
  ) async {
    final keyMetasForAllClasses = <KeyMeta>[];
    for (final annotatedElement in annotatedElements) {
      final source = annotatedElement.element.source;

      if (source != null) {
        final sourceCode = await _sourceCodeFromBuildStep(annotatedElement.element, buildStep);
        final keyClasses = _keyClassesFromAnnotation(annotatedElement.annotation);
        final keyMetas = keyMetasFromSourceCode(sourceCode, keyClasses);
        keyMetasForAllClasses.addAll(keyMetas);
      }
    }
    return keyMetasForAllClasses;
  }

  Future<void> _generateKeysFile(
    String filename,
    List<KeyMeta> keyMetasForAllClasses,
    BuildStep buildStep,
    AssetId keysFileInputId,
  ) async {
    final buffer = StringBuffer();
    buffer.write(_generateHeader(filename));
    buffer.write(await generateKeyClass(keyMetasForAllClasses));
    await buildStep.writeAsString(keysFileInputId, buffer.toString());
  }

  void _throwOnAnnotationButNoKeys(List<KeyMeta> keyMetasForAllClasses, AssetId fileInputId) {
    if (keyMetasForAllClasses.isEmpty) {
      throw Exception(
        "No keys found in classes annotated with @GenKey in '$fileInputId'",
      );
    }
  }

  void _throwOnPartOrAnnotationWrong(
    Iterable<AnnotatedElement> annotatedElements,
    String keysFilename,
    String filename,
    el.LibraryElement libraryElement,
    AssetId fileInputId,
  ) {
    final bool havePart = _havePart(libraryElement, keysFilename);

    if (annotatedElements.isNotEmpty && !havePart) {
      throw Exception(
        "The declaration \"part '$keysFilename';\" is missing in '$filename'",
      );
    }

    if (havePart && annotatedElements.isEmpty) {
      throw Exception(
        "No classes annotated with @GenKey in '$filename'",
      );
    }
  }

  bool _havePart(
    el.LibraryElement libraryElement,
    String keysFilename,
  ) {
    bool foundPart = false;

    for (final part in libraryElement.parts) {
      if (part.toString().contains('/$keysFilename')) {
        foundPart = true;
        break;
      }
    }

    return foundPart;
  }
}

String _generateHeader(String partOfFilename) {
  final buffer = StringBuffer();

  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buffer.writeln();
  buffer.writeln("part of '$partOfFilename';");
  buffer.writeln();
  buffer.writeln(
    '// **************************************************************************',
  );
  buffer.writeln('// GenKeyGenerator');
  buffer.writeln(
    '// **************************************************************************',
  );

  return buffer.toString();
}

Future<String> _sourceCodeFromBuildStep(
  el.Element element,
  BuildStep buildStep,
) async {
  final ast = await buildStep.resolver.astNodeFor(element);

  late String classSourceCode;

  if (ast == null) {
    classSourceCode = '';
  } else {
    classSourceCode = ast.toSource();
  }

  return classSourceCode;
}

List<String> _keyClassesFromAnnotation(
  ConstantReader annotation,
) {
  final keyClasses = <String>[];

  try {
    annotation.read('keyClasses').listValue.forEach((dartObject) {
      final String? keyClass = dartObject.toStringValue();
      if (keyClass != null) {
        keyClasses.add(keyClass);
      }
    });
  } on FormatException {
    // If here, parameter not entered. Do nothing
  }

  return keyClasses;
}
