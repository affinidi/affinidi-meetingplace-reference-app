import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

String generateUuid() => const Uuid().v4();

@DataClassName('IdentityRecord')
class IdentitiesTable extends Table {
  TextColumn get id => text().clientDefault(generateUuid)();

  /// Permanent DID for this identity.
  TextColumn get did => text()();

  /// Alias / user-facing name override (not part of SDK contactInfo).
  TextColumn get displayName => text()();

  /// JSON blob holding all contact card fields mapped by sdkPath.
  TextColumn get contactInfoJson => text().withDefault(const Constant('{}'))();

  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
