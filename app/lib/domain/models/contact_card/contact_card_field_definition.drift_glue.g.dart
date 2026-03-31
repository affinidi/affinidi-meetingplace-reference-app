// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:drift/drift.dart';

import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card_field_definition.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/contacts_repository/contacts_repository_drift/contacts_database.dart'
    as contacts_db;
import 'package:mpx_flutter_reference_app/infrastructure/repositories/identities_repository/identities_repository_drift/identities_database.dart';

class GeneratedTextColumnMigration {
  const GeneratedTextColumnMigration({
    required this.key,
    required this.tableName,
    required this.columnName,
    required this.isNullable,
    this.defaultValue = '',
  });

  final ContactCardFieldKey key;
  final String tableName;
  final String columnName;
  final bool isNullable;
  final String defaultValue;

  String get addColumnSql {
    final escapedDefaultValue = defaultValue.replaceAll("'", "''");
    final nullableClause = isNullable
        ? ''
        : " NOT NULL DEFAULT '$escapedDefaultValue'";
    return 'ALTER TABLE $tableName ADD COLUMN $columnName TEXT$nullableClause';
  }
}

List<String> missingGeneratedColumnSql(
  Iterable<GeneratedTextColumnMigration> migrations,
  Iterable<String> existingColumns,
) {
  final existing = existingColumns.toSet();
  return [
    for (final migration in migrations)
      if (!existing.contains(migration.columnName)) migration.addColumnSql,
  ];
}

const generatedIdentityContactCardFieldMigrations =
    <GeneratedTextColumnMigration>[
      GeneratedTextColumnMigration(
        key: ContactCardFieldKey.firstName,
        tableName: 'identities_table',
        columnName: 'firstName',
        isNullable: false,
      ),
      GeneratedTextColumnMigration(
        key: ContactCardFieldKey.lastName,
        tableName: 'identities_table',
        columnName: 'lastName',
        isNullable: true,
      ),
      GeneratedTextColumnMigration(
        key: ContactCardFieldKey.organization,
        tableName: 'identities_table',
        columnName: 'organization',
        isNullable: true,
      ),
      GeneratedTextColumnMigration(
        key: ContactCardFieldKey.website,
        tableName: 'identities_table',
        columnName: 'website',
        isNullable: true,
      ),
      GeneratedTextColumnMigration(
        key: ContactCardFieldKey.email,
        tableName: 'identities_table',
        columnName: 'email',
        isNullable: true,
      ),
      GeneratedTextColumnMigration(
        key: ContactCardFieldKey.mobile,
        tableName: 'identities_table',
        columnName: 'mobile',
        isNullable: true,
      ),
      GeneratedTextColumnMigration(
        key: ContactCardFieldKey.postcode,
        tableName: 'identities_table',
        columnName: 'postcode',
        isNullable: true,
      ),
    ];

const generatedContactCardFieldMigrations = <GeneratedTextColumnMigration>[
  GeneratedTextColumnMigration(
    key: ContactCardFieldKey.firstName,
    tableName: 'contact_cards',
    columnName: 'firstName',
    isNullable: false,
    defaultValue: '',
  ),
  GeneratedTextColumnMigration(
    key: ContactCardFieldKey.lastName,
    tableName: 'contact_cards',
    columnName: 'lastName',
    isNullable: false,
    defaultValue: '',
  ),
  GeneratedTextColumnMigration(
    key: ContactCardFieldKey.organization,
    tableName: 'contact_cards',
    columnName: 'organization',
    isNullable: false,
    defaultValue: '',
  ),
  GeneratedTextColumnMigration(
    key: ContactCardFieldKey.website,
    tableName: 'contact_cards',
    columnName: 'website',
    isNullable: false,
    defaultValue: '',
  ),
  GeneratedTextColumnMigration(
    key: ContactCardFieldKey.email,
    tableName: 'contact_cards',
    columnName: 'email',
    isNullable: false,
    defaultValue: '',
  ),
  GeneratedTextColumnMigration(
    key: ContactCardFieldKey.mobile,
    tableName: 'contact_cards',
    columnName: 'mobile',
    isNullable: false,
    defaultValue: '',
  ),
  GeneratedTextColumnMigration(
    key: ContactCardFieldKey.postcode,
    tableName: 'contact_cards',
    columnName: 'postcode',
    isNullable: false,
    defaultValue: '',
  ),
];

List<String> missingIdentityContactCardFieldSql(
  Iterable<String> existingColumns,
) {
  return missingGeneratedColumnSql(
    generatedIdentityContactCardFieldMigrations,
    existingColumns,
  );
}

List<String> missingContactCardFieldSql(Iterable<String> existingColumns) {
  return missingGeneratedColumnSql(
    generatedContactCardFieldMigrations,
    existingColumns,
  );
}

IdentityRecord buildIdentityRecordFromIdentity(Identity identity) {
  final fieldValues = ContactCardFieldDefinitions.valuesFromCard(identity.card);
  return IdentityRecord(
    id: identity.id,
    did: identity.did,
    isPrimary: identity.isPrimary,
    displayName: identity.card.displayName,
    firstName: fieldValues[ContactCardFieldKey.firstName] ?? '',
    lastName: fieldValues[ContactCardFieldKey.lastName],
    organization: fieldValues[ContactCardFieldKey.organization],
    website: fieldValues[ContactCardFieldKey.website],
    email: fieldValues[ContactCardFieldKey.email],
    mobile: fieldValues[ContactCardFieldKey.mobile],
    postcode: fieldValues[ContactCardFieldKey.postcode],
    profilePic: identity.card.profilePic,
    cardColor: identity.card.cardColor,
  );
}

Map<ContactCardFieldKey, String?> identityRecordFieldValues(
  IdentityRecord record,
) {
  return {
    ContactCardFieldKey.firstName: record.firstName,
    ContactCardFieldKey.lastName: record.lastName,
    ContactCardFieldKey.organization: record.organization,
    ContactCardFieldKey.website: record.website,
    ContactCardFieldKey.email: record.email,
    ContactCardFieldKey.mobile: record.mobile,
    ContactCardFieldKey.postcode: record.postcode,
  };
}

contacts_db.ContactCardsCompanion buildContactCardCompanion({
  required ContactCard card,
  String? contactId,
}) {
  final fieldValues = ContactCardFieldDefinitions.nonNullableValuesFromCard(
    card,
  );
  return contacts_db.ContactCardsCompanion(
    contactId: contactId == null ? const Value.absent() : Value(contactId),
    did: Value(card.did),
    type: Value(card.type),
    firstName: Value(fieldValues[ContactCardFieldKey.firstName] ?? ''),
    lastName: Value(fieldValues[ContactCardFieldKey.lastName] ?? ''),
    organization: Value(fieldValues[ContactCardFieldKey.organization] ?? ''),
    website: Value(fieldValues[ContactCardFieldKey.website] ?? ''),
    email: Value(fieldValues[ContactCardFieldKey.email] ?? ''),
    mobile: Value(fieldValues[ContactCardFieldKey.mobile] ?? ''),
    postcode: Value(fieldValues[ContactCardFieldKey.postcode] ?? ''),
    profilePic: Value(card.profilePic ?? ''),
    meetingplaceIdentityCardColor: Value(card.cardColor ?? ''),
  );
}

Map<ContactCardFieldKey, String?> contactCardRowFieldValues(
  contacts_db.ContactCard record,
) {
  return {
    ContactCardFieldKey.firstName: record.firstName,
    ContactCardFieldKey.lastName: record.lastName,
    ContactCardFieldKey.organization: record.organization,
    ContactCardFieldKey.website: record.website,
    ContactCardFieldKey.email: record.email,
    ContactCardFieldKey.mobile: record.mobile,
    ContactCardFieldKey.postcode: record.postcode,
  };
}

ContactCard hydrateIdentityRecordContactCard(
  IdentityRecord record, {
  required String type,
}) {
  return ContactCardFieldDefinitions.applyFieldValues(
    ContactCard(
      id: record.id,
      did: record.did,
      type: type,
      firstName: '',
      displayName: record.displayName,
      profilePic: record.profilePic,
      cardColor: record.cardColor,
    ),
    identityRecordFieldValues(record),
  );
}

ContactCard hydrateContactCardRow(
  contacts_db.ContactCard record, {
  required String id,
}) {
  final hydratedCard = ContactCardFieldDefinitions.applyFieldValues(
    ContactCard(
      id: id,
      did: record.did,
      type: record.type,
      firstName: '',
      displayName: '',
    ),
    contactCardRowFieldValues(record),
  );
  return hydratedCard.copyWith(
    displayName: hydratedCard.fullName,
    profilePic: record.profilePic.isEmpty ? null : record.profilePic,
    cardColor: record.meetingplaceIdentityCardColor.isEmpty
        ? null
        : record.meetingplaceIdentityCardColor,
  );
}
