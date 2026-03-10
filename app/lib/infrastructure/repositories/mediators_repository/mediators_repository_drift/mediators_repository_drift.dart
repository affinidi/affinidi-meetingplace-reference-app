import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/mediator/mediator.dart' as model;
import '../../../../domain/models/mediator/mediator_status.dart';
import '../../../../domain/models/mediator/mediator_type.dart';
import '../../../../domain/repositories/mediators_repository.dart';
import '../../../exceptions/app_exception.dart';
import '../../../exceptions/app_exception_type.dart';
import 'mediators_database.dart' as db;

/// Provides a [MediatorsRepositoryDrift] instance backed by Drift database.
Future<MediatorsRepositoryDrift> mediatorsRepositoryDrift(Ref ref) async {
  final database = await ref.read(db.mediatorsDatabaseProvider.future);
  return MediatorsRepositoryDrift(database: database);
}

/// Provides a [MediatorsRepositoryDrift] instance backed by an in-memory
/// Drift database.
Future<MediatorsRepositoryDrift> mediatorsRepositoryInMemoryDrift(
  Ref ref,
) async {
  final database = await ref.read(db.mediatorsInMemoryDatabaseProvider.future);
  return MediatorsRepositoryDrift(database: database);
}

/// Drift implementation of [MediatorsRepository].
class MediatorsRepositoryDrift implements MediatorsRepository {
  MediatorsRepositoryDrift({required db.MediatorsDatabase database})
    : _database = database;

  final db.MediatorsDatabase _database;

  /// Retrieves all **custom** mediators stored in the database.
  ///
  /// Custom mediators are those added by the user at runtime
  /// (with type [MediatorType.custom]).
  @override
  Future<List<model.Mediator>> listCustomMediators() async {
    final results = await (_database.select(
      _database.mediators,
    )..where((table) => table.type.equalsValue(MediatorType.custom))).get();
    return results.map(_MediatorMapper.fromDatabaseRecord).toList();
  }

  /// Retrieves **all mediators** regardless of type.
  ///
  /// This includes both [MediatorType.local] and [MediatorType.custom] and
  /// both active and deleted Mediators.
  @override
  Future<List<model.Mediator>> listMediators() async {
    final results = await _database.select(_database.mediators).get();
    return results.map(_MediatorMapper.fromDatabaseRecord).toList();
  }

  /// Adds a **custom mediator** to the database.
  ///
  /// - The [name] must be provided by the caller and will be stored as the
  ///   human-friendly label of the mediator.
  /// - Only one instance of the same did that is not deleted can be exis.
  ///  If a mediator with the same [did] already exists, the underlying
  ///  database will enforce uniqueness and an [AppException] will be thrown.
  ///
  /// [name] - Human-friendly label for the mediator.
  /// [did]  - Unique DID identifier of the mediator.
  @override
  Future<void> addCustomMediator({
    required String name,
    required String did,
  }) async {
    // Check for existing mediator with same DID and isDeleted == false
    final isMediatorExists =
        await (_database.select(_database.mediators)..where(
              (table) =>
                  table.mediatorDid.equals(did) &
                  table.status.equals(MediatorStatus.active.value),
            ))
            .getSingleOrNull();

    if (isMediatorExists != null) {
      throw AppException(
        'Mediator with the same DID already exists.',
        code: AppExceptionType.mediatorAlreadyExists.name,
      );
    }

    await _database
        .into(_database.mediators)
        .insert(
          db.MediatorsCompanion.insert(
            mediatorDid: did,
            mediatorName: name,
            type: MediatorType.custom,
            status: MediatorStatus.active,
          ),
          mode: InsertMode.insert,
        );
  }

  /// Soft-deletes a **custom mediator** identified by [did].
  ///
  /// - Instead of removing the record from the database, this method sets
  ///   isDeleted to `true`, preserving historical data.
  /// - Default mediators ([MediatorType.local]) remain untouched.
  @override
  Future<void> removeMediator(String did) async {
    await (_database.update(_database.mediators)..where(
          (table) => Expression.and([
            table.mediatorDid.equals(did),
            table.type.equals(MediatorType.custom.value),
          ]),
        ))
        .write(
          const db.MediatorsCompanion(status: Value(MediatorStatus.deleted)),
        );
  }

  /// Rename a custom mediator identified by its DID.
  ///
  /// Updates the mediator's name in the database
  /// while ensuring only custom mediators can be renamed.
  ///
  /// [did] - The DID of the mediator to rename.
  /// [newName] - The new human-friendly name to assign.
  @override
  Future<void> renameCustomMediator({
    required String did,
    required String newName,
  }) async {
    await (_database.update(_database.mediators)..where(
          (table) => Expression.and([
            table.mediatorDid.equals(did),
            table.status.equals(MediatorStatus.active.value),
            table.type.equals(MediatorType.custom.value),
          ]),
        ))
        .write(db.MediatorsCompanion(mediatorName: Value(newName)));
  }
}

/// Maps Drift database records to [model.Mediator] domain objects.
class _MediatorMapper {
  static model.Mediator fromDatabaseRecord(db.Mediator record) {
    return model.Mediator(
      id: record.id,
      mediatorName: record.mediatorName,
      mediatorDid: record.mediatorDid,
      type: record.type,
      status: record.status,
      createdTime: DateTime.parse(record.createdTime),
    );
  }
}
