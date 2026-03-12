import 'dart:io';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../domain/models/contact_card/identity_field.dart';
import '../../../database/database_platform.dart';
import '../../../providers/applications_documents_directory_provider.dart';
import '../../../secure_storage/secure_storage.dart';
import 'identities_table.dart';

part 'identities_database.g.dart';

/// Drift database for managing identities.
///
/// - Uses encrypted storage with a passphrase.
/// - Contains the [IdentitiesTable].
/// - Provides schema versioning for migrations.
@DriftDatabase(tables: [IdentitiesTable])
class IdentitiesDatabase extends _$IdentitiesDatabase {
  /// Creates a new [IdentitiesDatabase] instance.
  ///
  /// [databaseName] - The file name of the database.
  /// [passphrase] - The encryption key used to secure the database.
  IdentitiesDatabase({
    required String databaseName,
    required String passphrase,
    required bool inMemory,
    required Directory directory,
  }) : super(
         openConnection(
           databaseName: databaseName,
           passphrase: passphrase,
           inMemory: inMemory,
           directory: directory,
         ),
       );

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _syncIdentityColumns();
    },
    onUpgrade: (migrator, from, to) async {
      await _syncIdentityColumns();
    },
  );

  Future<void> _syncIdentityColumns() async {
    await _addColumnIfMissing(
      tableName: 'identities_table',
      columnName: 'did',
      alterTableSql: "did TEXT NOT NULL DEFAULT ''",
    );

    for (final field in identityFields) {
      await _addColumnIfMissing(
        tableName: 'identities_table',
        columnName: field.columnName,
        alterTableSql: field.identityAlterTableSql,
      );
    }
  }

  Future<void> _addColumnIfMissing({
    required String tableName,
    required String columnName,
    required String alterTableSql,
  }) async {
    final existingColumns = await customSelect(
      'PRAGMA table_info($tableName)',
    ).get();
    final hasColumn = existingColumns.any(
      (row) => row.data['name'] == columnName,
    );

    if (hasColumn) {
      return;
    }

    await customStatement('ALTER TABLE $tableName ADD COLUMN $alterTableSql');
  }
}

/// A provider that initializes and supplies the [IdentitiesDatabase].
///
/// - Retrieves an encryption passphrase from [secureStorageProvider].
/// - Creates and opens the encrypted identities database.
/// - Closes the database when the provider is disposed.
final identitiesDatabaseProvider = FutureProvider<IdentitiesDatabase>((
  ref,
) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );

  final database = IdentitiesDatabase(
    databaseName: 'mpx_identities_db',
    passphrase: passphrase,
    inMemory: false,
    directory: directory,
  );

  ref.onDispose(database.close);

  return database;
});

/// A provider that initializes and supplies the [IdentitiesDatabase].
///
/// - Retrieves an encryption passphrase from [secureStorageProvider].
/// - Creates and opens the encrypted identities database.
/// - Closes the database when the provider is disposed.
final identitiesInMemoryDatabaseProvider = FutureProvider<IdentitiesDatabase>((
  ref,
) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );

  final database = IdentitiesDatabase(
    databaseName: 'mpx_identities_db',
    passphrase: passphrase,
    inMemory: true,
    directory: directory,
  );

  ref.onDispose(database.close);

  return database;
});
