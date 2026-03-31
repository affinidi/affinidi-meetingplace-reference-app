import 'package:build/build.dart';

const _fieldDefinitionPath =
    'lib/domain/models/contact_card/contact_card_field_definition.dart';
const _contactCardPath = 'lib/domain/models/contact_card/contact_card.dart';
const _contactsDatabasePath =
    'lib/infrastructure/repositories/contacts_repository/'
    'contacts_repository_drift/contacts_database.dart';
const _identitiesTablePath =
    'lib/infrastructure/repositories/identities_repository/'
    'identities_repository_drift/identities_table.dart';

Builder contactCardFieldDriftGlueBuilder(BuilderOptions options) {
  return const _ContactCardFieldDriftGlueBuilder();
}

Builder contactCardModelBuilder(BuilderOptions options) {
  return const _ContactCardModelBuilder();
}

Builder contactCardsTableBuilder(BuilderOptions options) {
  return const _ContactCardsTableBuilder();
}

Builder identitiesTableBuilder(BuilderOptions options) {
  return const _IdentitiesTableBuilder();
}

class _ContactCardFieldDriftGlueBuilder extends _ContactCardRegistryBuilder {
  const _ContactCardFieldDriftGlueBuilder();

  @override
  String get inputPath => _fieldDefinitionPath;

  @override
  String get outputExtension => '.drift_glue.g.dart';

  @override
  String buildOutput(List<_ParsedField> fields) {
    return _GeneratedGlueWriter(fields).write();
  }
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

class _ContactCardsTableBuilder extends _ContactCardRegistryBuilder {
  const _ContactCardsTableBuilder();

  @override
  String get inputPath => _contactsDatabasePath;

  @override
  String get outputExtension => '.contact_card_fields.g.dart';

  @override
  String buildOutput(List<_ParsedField> fields) {
    return _GeneratedContactCardsTableWriter(fields).write();
  }
}

class _IdentitiesTableBuilder extends _ContactCardRegistryBuilder {
  const _IdentitiesTableBuilder();

  @override
  String get inputPath => _identitiesTablePath;

  @override
  String get outputExtension => '.contact_card_fields.g.dart';

  @override
  String buildOutput(List<_ParsedField> fields) {
    return _GeneratedIdentitiesTableWriter(fields).write();
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
  const _ParsedField({
    required this.key,
    required this.identitiesColumnName,
    required this.contactsColumnName,
    required this.nullWhenEmpty,
  });

  final String key;
  final String identitiesColumnName;
  final String contactsColumnName;
  final bool nullWhenEmpty;

  String get enumValue => 'ContactCardFieldKey.$key';

  String get modelType => nullWhenEmpty ? 'String?' : 'String';

  String get identitiesColumnTypeSuffix => nullWhenEmpty ? '.nullable()' : '';
}

class _ContactCardFieldParser {
  static const String _definitionToken = 'ContactCardFieldDefinition(';
  static final RegExp _keyPattern = RegExp(
    r'key:\s*ContactCardFieldKey\.(\w+)',
  );
  static final RegExp _identitiesColumnPattern = RegExp(
    r"identitiesColumnName:\s*'([^']+)'",
  );
  static final RegExp _contactsColumnPattern = RegExp(
    r"contactsColumnName:\s*'([^']+)'",
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
            identitiesColumnName: _readRequired(
              _identitiesColumnPattern,
              block,
              'identitiesColumnName',
            ),
            contactsColumnName: _readRequired(
              _contactsColumnPattern,
              block,
              'contactsColumnName',
            ),
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

      // Skip the constructor declaration:
      // `ContactCardFieldDefinition({ ... })`.
      // We only want instances: `ContactCardFieldDefinition(`.
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

class _GeneratedContactCardsTableWriter {
  const _GeneratedContactCardsTableWriter(this.fields);

  final List<_ParsedField> fields;

  String write() {
    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln()
      ..writeln("part of 'contacts_database.dart';")
      ..writeln()
      ..writeln('@DataClassName(\'ContactCard\')')
      ..writeln('class ContactCards extends Table {')
      ..writeln('  IntColumn get id => integer().autoIncrement()();')
      ..writeln('  TextColumn get contactId => text().customConstraint(')
      ..writeln(
        "    'REFERENCES contacts(id) ON DELETE CASCADE UNIQUE NOT NULL',",
      )
      ..writeln('  )();')
      ..writeln('  TextColumn get did => text()();')
      ..writeln('  TextColumn get type => text()();');

    for (final field in fields) {
      buffer.writeln(
        '  TextColumn get ${field.contactsColumnName} => text()();',
      );
    }

    buffer
      ..writeln('  TextColumn get profilePic => text()();')
      ..writeln('  TextColumn get meetingplaceIdentityCardColor => text()();')
      ..writeln('}');

    return buffer.toString();
  }
}

class _GeneratedIdentitiesTableWriter {
  const _GeneratedIdentitiesTableWriter(this.fields);

  final List<_ParsedField> fields;

  String write() {
    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln()
      ..writeln("part of 'identities_table.dart';")
      ..writeln()
      ..writeln('@DataClassName(\'IdentityRecord\')')
      ..writeln('class IdentitiesTable extends Table {')
      ..writeln('  TextColumn get id => text().clientDefault(generateUuid)();')
      ..writeln('  TextColumn get did => text()();')
      ..writeln('  TextColumn get displayName => text()();');

    for (final field in fields) {
      buffer.writeln(
        '  TextColumn get ${field.identitiesColumnName} => '
        'text()${field.identitiesColumnTypeSuffix}();',
      );
    }

    buffer
      ..writeln('  TextColumn get profilePic => text().nullable()();')
      ..writeln('  TextColumn get cardColor => text().nullable()();')
      ..writeln(
        '  BoolColumn get isPrimary => '
        'boolean().withDefault(const Constant(false))();',
      )
      ..writeln()
      ..writeln('  @override')
      ..writeln('  Set<Column> get primaryKey => {id};')
      ..writeln('}');

    return buffer.toString();
  }
}

class _GeneratedGlueWriter {
  const _GeneratedGlueWriter(this.fields);

  final List<_ParsedField> fields;

  String write() {
    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln()
      ..writeln("import 'package:drift/drift.dart';")
      ..writeln()
      ..writeln(
        '''import 'package:mpx_flutter_reference_app/'''
        '''domain/models/contact_card/contact_card.dart';''',
      )
      ..writeln(
        '''import 'package:mpx_flutter_reference_app/'''
        '''domain/models/contact_card/contact_card_field_definition.dart';''',
      )
      ..writeln(
        '''import 'package:mpx_flutter_reference_app/'''
        '''domain/models/identity/identity.dart';''',
      )
      ..writeln(
        '''import 'package:mpx_flutter_reference_app/infrastructure/'''
        '''extensions/contact_card_extensions.dart';''',
      )
      ..writeln(
        '''import 'package:mpx_flutter_reference_app/infrastructure/'''
        '''repositories/contacts_repository/contacts_repository_drift/'''
        '''contacts_database.dart' as contacts_db;''',
      )
      ..writeln(
        '''import 'package:mpx_flutter_reference_app/infrastructure/'''
        '''repositories/identities_repository/'''
        '''identities_repository_drift/identities_database.dart';''',
      )
      ..writeln()
      ..writeln('class GeneratedTextColumnMigration {')
      ..writeln('  const GeneratedTextColumnMigration({')
      ..writeln('    required this.key,')
      ..writeln('    required this.tableName,')
      ..writeln('    required this.columnName,')
      ..writeln('    required this.isNullable,')
      ..writeln("    this.defaultValue = '',")
      ..writeln('  });')
      ..writeln()
      ..writeln('  final ContactCardFieldKey key;')
      ..writeln('  final String tableName;')
      ..writeln('  final String columnName;')
      ..writeln('  final bool isNullable;')
      ..writeln('  final String defaultValue;')
      ..writeln()
      ..writeln('  String get addColumnSql {')
      ..writeln(
        '''    final escapedDefaultValue = '''
        '''defaultValue.replaceAll("'", "''");''',
      )
      ..writeln(
        '''    final nullableClause = isNullable ? '' : '''
        '''" NOT NULL DEFAULT '\$escapedDefaultValue'";''',
      )
      ..writeln(
        '''    return 'ALTER TABLE \$tableName ADD COLUMN '''
        '''\$columnName TEXT\$nullableClause';''',
      )
      ..writeln('  }')
      ..writeln('}')
      ..writeln()
      ..writeln('List<String> missingGeneratedColumnSql(')
      ..writeln('  Iterable<GeneratedTextColumnMigration> migrations,')
      ..writeln('  Iterable<String> existingColumns,')
      ..writeln(') {')
      ..writeln('  final existing = existingColumns.toSet();')
      ..writeln('  return [')
      ..writeln('    for (final migration in migrations)')
      ..writeln(
        '''      if (!existing.contains(migration.columnName)) '''
        '''migration.addColumnSql,''',
      )
      ..writeln('  ];')
      ..writeln('}')
      ..writeln()
      ..writeln('const generatedIdentityContactCardFieldMigrations =')
      ..writeln('    <GeneratedTextColumnMigration>[');

    for (final field in fields) {
      buffer.writeln(_identityMigrationLine(field));
    }

    buffer
      ..writeln('];')
      ..writeln()
      ..writeln('const generatedContactCardFieldMigrations =')
      ..writeln('    <GeneratedTextColumnMigration>[');

    for (final field in fields) {
      buffer.writeln(_contactMigrationLine(field));
    }

    buffer
      ..writeln('];')
      ..writeln()
      ..writeln('List<String> missingIdentityContactCardFieldSql(')
      ..writeln('  Iterable<String> existingColumns,')
      ..writeln(') {')
      ..writeln('  return missingGeneratedColumnSql(')
      ..writeln('    generatedIdentityContactCardFieldMigrations,')
      ..writeln('    existingColumns,')
      ..writeln('  );')
      ..writeln('}')
      ..writeln()
      ..writeln('List<String> missingContactCardFieldSql(')
      ..writeln('  Iterable<String> existingColumns,')
      ..writeln(') {')
      ..writeln('  return missingGeneratedColumnSql(')
      ..writeln('    generatedContactCardFieldMigrations,')
      ..writeln('    existingColumns,')
      ..writeln('  );')
      ..writeln('}')
      ..writeln()
      ..writeln(
        'IdentityRecord buildIdentityRecordFromIdentity(Identity identity) {',
      )
      ..writeln(
        '''  final fieldValues = ContactCardFieldDefinitions.'''
        '''valuesFromCard(identity.card);''',
      )
      ..writeln('  return IdentityRecord(')
      ..writeln('    id: identity.id,')
      ..writeln('    did: identity.did,')
      ..writeln('    isPrimary: identity.isPrimary,')
      ..writeln('    displayName: identity.card.displayName,');

    for (final field in fields) {
      final suffix = field.nullWhenEmpty ? '' : " ?? ''";
      buffer.writeln(
        '''    ${field.identitiesColumnName}: '''
        '''fieldValues[${field.enumValue}]$suffix,''',
      );
    }

    buffer
      ..writeln('    profilePic: identity.card.profilePic,')
      ..writeln('    cardColor: identity.card.cardColor,')
      ..writeln('  );')
      ..writeln('}')
      ..writeln()
      ..writeln('Map<ContactCardFieldKey, String?> identityRecordFieldValues(')
      ..writeln('  IdentityRecord record,')
      ..writeln(') {')
      ..writeln('  return {');

    for (final field in fields) {
      buffer.writeln(
        '    ${field.enumValue}: record.${field.identitiesColumnName},',
      );
    }

    buffer
      ..writeln('  };')
      ..writeln('}')
      ..writeln()
      ..writeln('contacts_db.ContactCardsCompanion buildContactCardCompanion({')
      ..writeln('  required ContactCard card,')
      ..writeln('  String? contactId,')
      ..writeln('}) {')
      ..writeln(
        '''  final fieldValues = ContactCardFieldDefinitions.'''
        '''nonNullableValuesFromCard(card);''',
      )
      ..writeln('  return contacts_db.ContactCardsCompanion(')
      ..writeln(
        '''    contactId: contactId == null ? const Value.absent() : '''
        '''Value(contactId),''',
      )
      ..writeln('    did: Value(card.did),')
      ..writeln('    type: Value(card.type),');

    for (final field in fields) {
      buffer.writeln(
        '''    ${field.contactsColumnName}: '''
        '''Value(fieldValues[${field.enumValue}] ?? ''),''',
      );
    }

    buffer
      ..writeln("    profilePic: Value(card.profilePic ?? ''),")
      ..writeln(
        "    meetingplaceIdentityCardColor: Value(card.cardColor ?? ''),",
      )
      ..writeln('  );')
      ..writeln('}')
      ..writeln()
      ..writeln('Map<ContactCardFieldKey, String?> contactCardRowFieldValues(')
      ..writeln('  contacts_db.ContactCard record,')
      ..writeln(') {')
      ..writeln('  return {');

    for (final field in fields) {
      buffer.writeln(
        '    ${field.enumValue}: record.${field.contactsColumnName},',
      );
    }

    buffer
      ..writeln('  };')
      ..writeln('}')
      ..writeln()
      ..writeln('ContactCard hydrateIdentityRecordContactCard(')
      ..writeln('  IdentityRecord record, {')
      ..writeln('  required String type,')
      ..writeln('}) {')
      ..writeln('  return ContactCardFieldDefinitions.applyFieldValues(')
      ..writeln('    ContactCard(')
      ..writeln('      id: record.id,')
      ..writeln('      did: record.did,')
      ..writeln('      type: type,');

    for (final field in fields.where((field) => !field.nullWhenEmpty)) {
      buffer.writeln("      ${field.key}: '',");
    }

    buffer
      ..writeln('      displayName: record.displayName,')
      ..writeln('      profilePic: record.profilePic,')
      ..writeln('      cardColor: record.cardColor,')
      ..writeln('    ),')
      ..writeln('    identityRecordFieldValues(record),')
      ..writeln('  );')
      ..writeln('}')
      ..writeln()
      ..writeln('ContactCard hydrateContactCardRow(')
      ..writeln('  contacts_db.ContactCard record, {')
      ..writeln('  required String id,')
      ..writeln('}) {')
      ..writeln(
        '  final hydratedCard = ContactCardFieldDefinitions.applyFieldValues(',
      )
      ..writeln('    ContactCard(')
      ..writeln('      id: id,')
      ..writeln('      did: record.did,')
      ..writeln('      type: record.type,');

    for (final field in fields.where((field) => !field.nullWhenEmpty)) {
      buffer.writeln("      ${field.key}: '',");
    }

    buffer
      ..writeln("      displayName: '',")
      ..writeln('    ),')
      ..writeln('    contactCardRowFieldValues(record),')
      ..writeln('  );')
      ..writeln('  return hydratedCard.copyWith(')
      ..writeln('    displayName: hydratedCard.fullName,')
      ..writeln(
        '    profilePic: record.profilePic.isEmpty ? null : record.profilePic,',
      )
      ..writeln('    cardColor: record.meetingplaceIdentityCardColor.isEmpty')
      ..writeln('        ? null')
      ..writeln('        : record.meetingplaceIdentityCardColor,')
      ..writeln('  );')
      ..writeln('}');

    return buffer.toString();
  }

  String _identityMigrationLine(_ParsedField field) {
    final nullable = field.nullWhenEmpty ? 'true' : 'false';
    return '  GeneratedTextColumnMigration('
        'key: ${field.enumValue}, '
        "tableName: 'identities_table', "
        "columnName: '${field.identitiesColumnName}', "
        'isNullable: $nullable),';
  }

  String _contactMigrationLine(_ParsedField field) {
    return '  GeneratedTextColumnMigration('
        'key: ${field.enumValue}, '
        "tableName: 'contact_cards', "
        "columnName: '${field.contactsColumnName}', "
        "isNullable: false, defaultValue: ''),";
  }
}
