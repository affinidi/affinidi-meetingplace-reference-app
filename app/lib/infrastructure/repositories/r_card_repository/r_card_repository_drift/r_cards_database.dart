import 'dart:io';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../database/database_platform.dart';
import '../../../providers/applications_documents_directory_provider.dart';
import '../../../secure_storage/secure_storage.dart';

part 'r_cards_database.g.dart';

/// Drift table for persisted R-Cards.
///
/// The primary key is [subjectDid] — each remote party has at most one
/// stored R-Card. The [version] column is incremented on every content
/// change to support idempotent upserts.
@DataClassName('RCardRow')
class RCards extends Table {
  TextColumn get subjectDid => text()();
  TextColumn get vcBlob => text()();
  TextColumn get issuerDid => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get issuanceDate => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get threadId => text().nullable()();
  TextColumn get contactChannelDid => text().nullable()();
  DateTimeColumn get receivedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {subjectDid};
}

/// Drift database that manages persisted R-Card rows.
@DriftDatabase(tables: [RCards])
class RCardsDatabase extends _$RCardsDatabase {
  /// Creates a new encrypted R-Cards database.
  RCardsDatabase({
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
  );
}

/// Provides the encrypted [RCardsDatabase] for normal on-device use.
///
/// The database file is created in the application documents directory and
/// encrypted with a passphrase retrieved from [secureStorageProvider].
final rCardsDatabaseProvider = FutureProvider<RCardsDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );

  final database = RCardsDatabase(
    databaseName: 'mpx_rcards_db',
    passphrase: passphrase,
    inMemory: false,
    directory: directory,
  );

  ref.onDispose(database.close);

  return database;
});

/// Provides an in-memory [RCardsDatabase] for testing.
final rCardsInMemoryDatabaseProvider = FutureProvider<RCardsDatabase>((
  ref,
) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );

  final database = RCardsDatabase(
    databaseName: 'mpx_rcards_db',
    passphrase: passphrase,
    inMemory: true,
    directory: directory,
  );

  ref.onDispose(database.close);

  return database;
});
