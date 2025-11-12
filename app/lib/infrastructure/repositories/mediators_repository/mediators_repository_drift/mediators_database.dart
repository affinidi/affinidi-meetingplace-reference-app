import 'dart:io';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/models/mediator/mediator_status.dart';
import '../../../../domain/models/mediator/mediator_type.dart';
import '../../../configuration/environment.dart';
import '../../../database/database_platform.dart';
import '../../../providers/applications_documents_directory_provider.dart';
import '../../../secure_storage/secure_storage.dart';

part 'mediators_database.g.dart';

/// Drift database for storing mediator records.
///
/// This database manages a single table: [Mediators].
/// It ensures that foreign keys are enabled and inserts default mediators
/// (from environment configuration) if they don't already exist.
@DriftDatabase(
  tables: [
    Mediators,
  ],
)
class MediatorsDatabase extends _$MediatorsDatabase {
  MediatorsDatabase({
    required String databaseName,
    required String passphrase,
    required bool inMemory,
    required Directory directory,
    required Map<String, String> defaultMediators,
  })  : _defaultMediators = defaultMediators,
        super(openConnection(
          databaseName: databaseName,
          passphrase: passphrase,
          inMemory: inMemory,
          directory: directory,
        ));

  final Map<String, String> _defaultMediators;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          for (final entry in _defaultMediators.entries) {
            final existing = await (select(mediators)
                  ..where((tbl) => tbl.mediatorDid.equals(entry.key)))
                .getSingleOrNull();

            if (existing == null) {
              await into(mediators).insert(
                MediatorsCompanion.insert(
                  mediatorDid: entry.key,
                  mediatorName: entry.value,
                  type: MediatorType.local,
                  status: MediatorStatus.active,
                ),
              );
            }
          }
        },
      );
}

/// Drift table definition for [Mediator] entities.
///
/// Stores mediator information such as name, DID, and type.
@DataClassName('Mediator')
class Mediators extends Table {
  TextColumn get id => text().clientDefault(const Uuid().v4)();
  TextColumn get mediatorName => text()();
  TextColumn get mediatorDid => text()();
  IntColumn get type => integer().map(const _MediatorTypeConverter())();
  IntColumn get status => integer().map(const _MediatorStatusConverter())();
  TextColumn get createdTime =>
      text().clientDefault(() => DateTime.now().toIso8601String())();

  @override
  Set<Column> get primaryKey => {id};
}

/// Handles conversion between [MediatorType] enum and integer for storage.
class _MediatorTypeConverter extends TypeConverter<MediatorType, int> {
  const _MediatorTypeConverter();

  @override
  MediatorType fromSql(int fromDb) {
    return MediatorType.values.firstWhere((type) => type.value == fromDb);
  }

  @override
  int toSql(MediatorType value) {
    return value.value;
  }
}

/// Handles conversion between [MediatorStatus] enum and integer for storage.
class _MediatorStatusConverter extends TypeConverter<MediatorStatus, int> {
  const _MediatorStatusConverter();

  @override
  MediatorStatus fromSql(int fromDb) {
    return MediatorStatus.values.firstWhere((status) => status.value == fromDb);
  }

  @override
  int toSql(MediatorStatus value) {
    return value.value;
  }
}

/// Provider that exposes a [MediatorsDatabase] instance.
///
/// Opens the encrypted database with a passphrase from [SecureStorage].
/// The database is automatically closed when the provider is disposed.
final mediatorsDatabaseProvider =
    FutureProvider<MediatorsDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory =
      await ref.read(applicationDocumentsDirectoryProvider.future);
  final defaultMediators = ref.read(environmentProvider).defaultMediators;

  final database = MediatorsDatabase(
    databaseName: 'mpx_mediators_db',
    passphrase: passphrase,
    inMemory: false,
    directory: directory,
    defaultMediators: defaultMediators,
  );

  ref.onDispose(database.close);

  return database;
});

/// Provider that exposes an in-memory [MediatorsDatabase] instance.
///
/// Opens an encrypted in-memory database with a passphrase from
/// [SecureStorage]. The database is automatically closed when the provider
/// is disposed. Useful for testing or temporary data storage.
final mediatorsInMemoryDatabaseProvider =
    FutureProvider<MediatorsDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory =
      await ref.read(applicationDocumentsDirectoryProvider.future);

  final database = MediatorsDatabase(
    databaseName: 'mpx_mediators_db',
    passphrase: passphrase,
    inMemory: true,
    directory: directory,
    defaultMediators: ref.read(environmentProvider).defaultMediators,
  );

  ref.onDispose(database.close);

  return database;
});
