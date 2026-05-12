import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'identities_database.dart';

String generateUuid() => const Uuid().v4();

/// Drift table representing stored identities.
///
/// Each record corresponds to an [IdentityRecord],
/// containing identifying information and optional profile details.
@DataClassName('IdentityRecord')
class IdentitiesTable extends Table {
  TextColumn get id => text().clientDefault(generateUuid)();

  /// Permanent DID for this identity.
  TextColumn get did => text()();

  /// Alias / user-facing name override.
  TextColumn get displayName => text()();

  /// JSON blob holding all contact card fields mapped by sdkPath.
  TextColumn get contactInfoJson => text().withDefault(const Constant('{}'))();

  /// Profile picture of the identity
  TextColumn get profilePic => text().nullable()();

  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
