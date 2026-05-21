import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_drift_repository/meeting_place_drift_repository.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart'
    as model;

import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import 'applications_documents_directory_provider.dart';

final _vrcDatabaseProvider = FutureProvider<VrcDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = VrcDatabase(
    databaseName: 'mpx_vrc_db',
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
  );

  ref.onDispose(database.close);

  return database;
});

final _vrcInMemoryDatabaseProvider = FutureProvider<VrcDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = VrcDatabase(
    databaseName: 'mpx_vrc_db',
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
    inMemory: true,
  );

  ref.onDispose(database.close);

  return database;
});

Future<model.VrcRepository> vrcRepositoryDrift(Ref ref) async {
  final database = await ref.read(_vrcDatabaseProvider.future);
  return VrcRepositoryDrift(database: database);
}

Future<model.VrcRepository> vrcRepositoryInMemoryDrift(Ref ref) async {
  final database = await ref.read(_vrcInMemoryDatabaseProvider.future);
  return VrcRepositoryDrift(database: database);
}

final vrcRepositoryProvider = FutureProvider<model.VrcRepository>((ref) async {
  return vrcRepositoryDrift(ref);
});
