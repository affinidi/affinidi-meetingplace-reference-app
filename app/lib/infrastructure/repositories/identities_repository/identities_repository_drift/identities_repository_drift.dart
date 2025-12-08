import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../domain/models/identity/identity.dart';
import '../../../../domain/repositories/identities_repository.dart';
import '../../../loggers/app_logger/app_logger.dart';
import '../../../providers/app_logger_provider.dart';
import 'identities_database.dart';

/// A provider that initializes and supplies the [IdentitiesRepositoryDrift].
///
/// - Depends on [identitiesDatabaseProvider] for database initialization.
/// - Uses [AppLogger] for logging operations.
/// - Keeps the repository alive across the app lifecycle.
Future<IdentitiesRepository> identitiesRepositoryDrift(Ref ref) async {
  final database = await ref.read(identitiesDatabaseProvider.future);

  final logger = ref.read(appLoggerProvider);
  return IdentitiesRepositoryDrift(
    db: database,
    logger: logger,
  );
}

/// A provider that initializes and supplies the [IdentitiesRepositoryDrift]
/// with an in-memory database.
///
/// - Depends on [identitiesInMemoryDatabaseProvider] for in-memory database.
/// - Uses [AppLogger] for logging operations.
/// - Keeps the repository alive across the app lifecycle.
Future<IdentitiesRepository> identitiesRepositoryInMemoryDrift(Ref ref) async {
  final database = await ref.read(identitiesInMemoryDatabaseProvider.future);

  final logger = ref.read(appLoggerProvider);
  return IdentitiesRepositoryDrift(
    db: database,
    logger: logger,
  );
}

/// Drift implementation of [IdentitiesRepository].
///
/// Provides CRUD operations on the [IdentitiesDatabase].
class IdentitiesRepositoryDrift implements IdentitiesRepository {
  IdentitiesRepositoryDrift({required this.db, required this.logger});
  final IdentitiesDatabase db;
  final AppLogger logger;

  @override
  Future<List<Identity>> listIdentities() async {
    final records = await db.select(db.identitiesTable).get();
    return records.map(IdentityMapper.fromRecord).toList();
  }

  @override
  Future<Identity> addIdentity(Identity identity) async {
    final record = identity.toRecord();
    await db.into(db.identitiesTable).insert(record);
    return identity;
  }

  @override
  Future<void> updateIdentity(Identity identity) async {
    final record = identity.toRecord();
    await db.update(db.identitiesTable).replace(record);
  }

  @override
  Future<void> deleteIdentity(String id) async {
    await (db.delete(db.identitiesTable)..where((tbl) => tbl.id.equals(id)))
        .go();
  }
}

/// Extension for mapping between [Identity] domain models and [IdentityRecord]
///  database rows.
extension IdentityMapper on Identity {
  /// Converts an [Identity] into an [IdentityRecord] for persistence.
  IdentityRecord toRecord() => IdentityRecord(
        id: id,
        did: did,
        isPrimary: isPrimary,
        displayName: card.displayName,
        firstName: card.firstName,
        lastName: card.lastName,
        email: card.email,
        mobile: card.mobile,
        profilePic: card.profilePic,
        cardColor: card.cardColor,
      );

  /// Creates an [Identity] domain model from a [IdentityRecord].
  static Identity fromRecord(IdentityRecord record) => Identity(
        id: record.id,
        did: record.did,
        isPrimary: record.isPrimary,
        card: ContactCard(
          id: record.id,
          displayName: record.displayName,
          firstName: record.firstName,
          lastName: record.lastName,
          email: record.email,
          mobile: record.mobile,
          profilePic: record.profilePic,
          cardColor: record.cardColor,
        ),
      );
}
