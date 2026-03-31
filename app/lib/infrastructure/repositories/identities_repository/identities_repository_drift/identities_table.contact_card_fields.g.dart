// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identities_table.dart';

@DataClassName('IdentityRecord')
class IdentitiesTable extends Table {
  TextColumn get id => text().clientDefault(generateUuid)();
  TextColumn get did => text()();
  TextColumn get displayName => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text().nullable()();
  TextColumn get organization => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get mobile => text().nullable()();
  TextColumn get postcode => text().nullable()();
  TextColumn get profilePic => text().nullable()();
  TextColumn get cardColor => text().nullable()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
