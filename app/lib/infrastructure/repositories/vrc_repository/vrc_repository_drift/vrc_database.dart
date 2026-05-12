import 'dart:io';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../database/database_platform.dart';
import '../../../providers/applications_documents_directory_provider.dart';
import '../../../secure_storage/secure_storage.dart';
import 'vrc_table.dart';

part 'vrc_database.g.dart';

@DriftDatabase(tables: [VrcTable])
class VrcDatabase extends _$VrcDatabase {
  VrcDatabase({
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

final vrcDatabaseProvider = FutureProvider<VrcDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );

  final database = VrcDatabase(
    databaseName: 'mpx_vrc_db',
    passphrase: passphrase,
    inMemory: false,
    directory: directory,
  );

  ref.onDispose(database.close);

  return database;
});

final vrcInMemoryDatabaseProvider = FutureProvider<VrcDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );

  final database = VrcDatabase(
    databaseName: 'mpx_vrc_db',
    passphrase: passphrase,
    inMemory: true,
    directory: directory,
  );

  ref.onDispose(database.close);

  return database;
});
