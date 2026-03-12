import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../presentation/config/persona_field_config.identity_fields.g.dart';
import 'identities_database.dart';

String generateUuid() => const Uuid().v4();

/// Drift table representing stored identities.
///
/// Each record corresponds to an [IdentityRecord],
/// containing identifying information and optional profile details.
@DataClassName('IdentityRecord')
class IdentitiesTable extends Table with GeneratedIdentityPersonaColumns {
  TextColumn get id => text().clientDefault(generateUuid)();
  TextColumn get did => text()();
  TextColumn get displayName => text()();
  TextColumn get profilePic => text().nullable()();
  TextColumn get cardColor => text().nullable()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
