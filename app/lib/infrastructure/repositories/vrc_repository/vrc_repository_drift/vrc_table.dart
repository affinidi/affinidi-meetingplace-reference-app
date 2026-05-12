import 'package:drift/drift.dart';

@DataClassName('VrcRow')
class VrcTable extends Table {
  TextColumn get id => text()();
  TextColumn get vc => text()();
  TextColumn get channelId => text()();
  TextColumn get holderIdentityDid => text()();
  TextColumn get issuerIdentityDid => text()();
  DateTimeColumn get issuedAt => dateTime()();
  DateTimeColumn get verifiedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
