import 'package:build/build.dart';

const _fieldDefinitionPath =
    'lib/domain/models/contact_card/contact_card_field_definition.dart';
const _contactCardPath = 'lib/domain/models/contact_card/contact_card.dart';

/// Generates `contact_card.registry.g.dart` from `ContactCardFieldDefinitions`.
///
/// The app previously had additional builders to generate Drift glue and per-
/// field table columns. After migrating persistence to a JSON blob, only the
/// ContactCard model generation remains.
Builder contactCardModelBuilder(BuilderOptions options) {
  return const _ContactCardModelBuilder();
}

class _ContactCardModelBuilder extends _ContactCardRegistryBuilder {
  const _ContactCardModelBuilder();

  @override
  String get inputPath => _contactCardPath;

  @override
  String get outputExtension => '.registry.g.dart';

  @override
  String buildOutput(List<_ParsedField> fields) {
    return _GeneratedContactCardModelWriter(fields).write();
  }
}

abstract class _ContactCardRegistryBuilder implements Builder {
  const _ContactCardRegistryBuilder();

  String get inputPath;

  String get outputExtension;

  String buildOutput(List<_ParsedField> fields);

  @override
  Map<String, List<String>> get buildExtensions => {
    '.dart': [outputExtension],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    if (buildStep.inputId.path != inputPath) {
      return;
    }

    final fields = await _loadFields(buildStep);
    final outputId = buildStep.inputId.changeExtension(outputExtension);
    await buildStep.writeAsString(outputId, buildOutput(fields));
  }

  Future<List<_ParsedField>> _loadFields(BuildStep buildStep) async {
    final fieldDefinitionsId = AssetId(
      buildStep.inputId.package,
      _fieldDefinitionPath,
    );
    final source = await buildStep.readAsString(fieldDefinitionsId);
    final fields = _ContactCardFieldParser.parse(source);
    if (fields.isEmpty) {
      throw StateError(
        'No ContactCardFieldDefinition entries found in $_fieldDefinitionPath.',
      );
    }
    return fields;
  }
}

class _ParsedField {
  const _ParsedField({required this.key, required this.nullWhenEmpty});

  final String key;
  final bool nullWhenEmpty;

  String get modelType => nullWhenEmpty ? 'String?' : 'String';
}

class _ContactCardFieldParser {
  static const String _definitionToken = 'ContactCardFieldDefinition(';
  static final RegExp _keyPattern = RegExp(
    r'key:\s*ContactCardFieldKey\.(\w+)',
  );
  static final RegExp _nullWhenEmptyPattern = RegExp(
    r'nullWhenEmpty:\s*(true|false)',
  );

  static List<_ParsedField> parse(String source) {
    final blocks = _extractDefinitionBlocks(source);
    return blocks
        .map((block) {
          return _ParsedField(
            key: _readRequired(_keyPattern, block, 'key'),
            nullWhenEmpty:
                _readRequired(_nullWhenEmptyPattern, block, 'nullWhenEmpty') ==
                'true',
          );
        })
        .toList(growable: false);
  }

  static List<String> _extractDefinitionBlocks(String source) {
    final blocks = <String>[];
    var searchIndex = 0;

    while (true) {
      final tokenIndex = source.indexOf(_definitionToken, searchIndex);
      if (tokenIndex < 0) break;

      final startParenIndex = tokenIndex + _definitionToken.length - 1;

      // Skip the constructor declaration `ContactCardFieldDefinition({ ... })`.
      var lookahead = startParenIndex + 1;
      while (lookahead < source.length && source[lookahead].trim().isEmpty) {
        lookahead++;
      }
      if (lookahead < source.length && source[lookahead] == '{') {
        searchIndex = lookahead + 1;
        continue;
      }

      final extracted = _extractBalancedParentheses(source, startParenIndex);
      blocks.add(extracted.content);
      searchIndex = extracted.endIndex;
    }

    return blocks;
  }

  static ({String content, int endIndex}) _extractBalancedParentheses(
    String source,
    int startParenIndex,
  ) {
    if (startParenIndex < 0 || startParenIndex >= source.length) {
      throw StateError('Invalid ContactCardFieldDefinition start index.');
    }
    if (source[startParenIndex] != '(') {
      throw StateError('Expected "(" at ContactCardFieldDefinition start.');
    }

    var depth = 0;
    var i = startParenIndex;

    var inLineComment = false;
    var inBlockComment = false;
    String? stringDelimiter;
    var isTripleQuoted = false;

    for (; i < source.length; i++) {
      final ch = source[i];

      if (inLineComment) {
        if (ch == '\n') {
          inLineComment = false;
        }
        continue;
      }

      if (inBlockComment) {
        if (ch == '*' && i + 1 < source.length && source[i + 1] == '/') {
          inBlockComment = false;
          i++;
        }
        continue;
      }

      if (stringDelimiter != null) {
        if (!isTripleQuoted && ch == '\\') {
          i++;
          continue;
        }

        if (isTripleQuoted) {
          if (i + 2 < source.length &&
              source[i] == stringDelimiter &&
              source[i + 1] == stringDelimiter &&
              source[i + 2] == stringDelimiter) {
            stringDelimiter = null;
            isTripleQuoted = false;
            i += 2;
          }
          continue;
        }

        if (ch == stringDelimiter) {
          stringDelimiter = null;
        }
        continue;
      }

      if (ch == '/' && i + 1 < source.length) {
        final next = source[i + 1];
        if (next == '/') {
          inLineComment = true;
          i++;
          continue;
        }
        if (next == '*') {
          inBlockComment = true;
          i++;
          continue;
        }
      }

      if (ch == '\'' || ch == '"') {
        final delimiter = ch;
        if (i + 2 < source.length &&
            source[i + 1] == delimiter &&
            source[i + 2] == delimiter) {
          stringDelimiter = delimiter;
          isTripleQuoted = true;
          i += 2;
          continue;
        }

        stringDelimiter = delimiter;
        isTripleQuoted = false;
        continue;
      }

      if (ch == '(') {
        depth++;
        continue;
      }

      if (ch == ')') {
        depth--;
        if (depth == 0) {
          final content = source.substring(startParenIndex + 1, i);
          return (content: content, endIndex: i + 1);
        }
        continue;
      }
    }

    throw StateError('Unterminated ContactCardFieldDefinition parentheses.');
  }

  static String _readRequired(RegExp pattern, String input, String label) {
    final match = pattern.firstMatch(input);
    final value = match?.group(1);
    if (value == null) {
      throw StateError(
        'Missing $label while parsing contact card field definition.',
      );
    }
    return value;
  }
}

class _GeneratedContactCardModelWriter {
  const _GeneratedContactCardModelWriter(this.fields);

  final List<_ParsedField> fields;

  String write() {
    final nonNullableFields = fields.where((field) => !field.nullWhenEmpty);
    final nullableFields = fields.where((field) => field.nullWhenEmpty);

    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln()
      ..writeln("part of 'contact_card.dart';")
      ..writeln()
      ..writeln('@freezed')
      ..writeln('abstract class ContactCard with _\$ContactCard {')
      ..writeln('  const factory ContactCard({')
      ..writeln('    required String id,')
      ..writeln('    required String did,')
      ..writeln('    required String type,');

    for (final field in nonNullableFields) {
      buffer.writeln('    required ${field.modelType} ${field.key},');
    }

    buffer.writeln('    required String displayName,');

    for (final field in nullableFields) {
      buffer.writeln('    ${field.modelType} ${field.key},');
    }

    buffer
      ..writeln('    String? profilePic,')
      ..writeln('    String? cardColor,')
      ..writeln('  }) = _ContactCard;')
      ..writeln()
      ..writeln('  factory ContactCard.empty() {')
      ..writeln('    return const ContactCard(')
      ..writeln("      id: '0',")
      ..writeln("      did: '',")
      ..writeln("      type: '',");

    for (final field in nonNullableFields) {
      buffer.writeln("      ${field.key}: '',");
    }

    buffer.writeln("      displayName: '',");

    for (final field in nullableFields) {
      buffer.writeln('      ${field.key}: null,');
    }

    buffer
      ..writeln('      profilePic: null,')
      ..writeln('      cardColor: null,')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}');

    return buffer.toString();
  }
}
