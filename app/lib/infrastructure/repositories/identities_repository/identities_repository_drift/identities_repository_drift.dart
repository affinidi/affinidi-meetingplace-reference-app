import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../domain/models/identity/identity.dart';
import '../../../../domain/repositories/identities_repository.dart';
import '../../../../presentation/config/persona_field_config.identity_fields.g.dart';
import '../../../database/drift_sql.dart';
import '../../../extensions/contact_card_extensions.dart';
import '../../../loggers/app_logger/app_logger.dart';
import '../../../providers/app_logger_provider.dart';
import 'identities_database.dart';

Future<IdentitiesRepository> identitiesRepositoryDrift(Ref ref) async {
  final database = await ref.read(identitiesDatabaseProvider.future);

  final logger = ref.read(appLoggerProvider);
  return IdentitiesRepositoryDrift(db: database, logger: logger);
}

Future<IdentitiesRepository> identitiesRepositoryInMemoryDrift(Ref ref) async {
  final database = await ref.read(identitiesInMemoryDatabaseProvider.future);

  final logger = ref.read(appLoggerProvider);
  return IdentitiesRepositoryDrift(db: database, logger: logger);
}

class IdentitiesRepositoryDrift implements IdentitiesRepository {
  IdentitiesRepositoryDrift({required this.db, required this.logger});
  final IdentitiesDatabase db;
  final AppLogger logger;

  @override
  Future<List<Identity>> listIdentities() async {
    final rows = await db.customSelect('SELECT * FROM identities_table').get();
    return rows.map(IdentityMapper.fromRow).toList();
  }

  @override
  Future<Identity> addIdentity(Identity identity) async {
    final values = _identityValues(identity);
    await db.customInsert(
      buildInsertSql(
        tableName: 'identities_table',
        columnNames: values.keys,
      ),
      variables: variablesFromExpressions(values),
      updates: {db.identitiesTable},
    );
    return identity;
  }

  @override
  Future<void> updateIdentity(Identity identity) async {
    final values = _identityValues(identity, includeId: false);
    await db.customUpdate(
      buildUpdateSql(
        tableName: 'identities_table',
        columnNames: values.keys,
        whereClause: 'id = ?',
      ),
      variables: [
        ...variablesFromExpressions(values),
        Variable<String>(identity.id),
      ],
      updates: {db.identitiesTable},
      updateKind: UpdateKind.update,
    );
  }

  @override
  Future<void> deleteIdentity(String id) async {
    await (db.delete(
      db.identitiesTable,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  Map<String, Expression> _identityValues(
    Identity identity, {
    bool includeId = true,
  }) {
    final values = <String, Expression>{
      'did': Variable<String>(identity.did),
      'is_primary': Variable<bool>(identity.isPrimary),
      'display_name': Variable<String>(identity.card.displayName),
      'profile_pic': Variable<String>(identity.card.profilePic ?? ''),
      'card_color': Variable<String>(identity.card.cardColor ?? ''),
      ...buildIdentityPersonaFieldExpressions(identity.card),
    };

    if (includeId) {
      values['id'] = Variable<String>(identity.id);
    }

    return values;
  }
}

extension IdentityMapper on Identity {
  static Identity fromRow(QueryRow row) {
    final data = row.data;
    final id = row.read<String>('id');
    final did = row.read<String>('did');
    final displayName = row.read<String>('display_name');
    final isPrimary = row.read<bool>('is_primary');
    final profilePic = _emptyToNull(row.read<String?>('profile_pic'));
    final cardColor = _emptyToNull(row.read<String?>('card_color'));

    return Identity(
      id: id,
      did: did,
      isPrimary: isPrimary,
      card: ContactCard(
        id: id,
        did: did,
        type: ContactCardType.individual.value,
        displayName: displayName,
        personaFields: readPersonaFieldValuesFromRow(data),
        profilePic: profilePic,
        cardColor: cardColor,
      ),
    );
  }
}

String? _emptyToNull(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }

  return value;
}
