import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as model;
import 'package:meeting_place_drift_repository/meeting_place_drift_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import 'applications_documents_directory_provider.dart';

part 'identity_repository_provider.g.dart';

final _identityDatabaseProvider = FutureProvider<IdentityDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory =
      await ref.read(applicationDocumentsDirectoryProvider.future);
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = IdentityDatabase(
    databaseName: 'mpx_identity_db',
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
  );

  ref.onDispose(database.close);

  return database;
});

final _identityInMemoryDatabaseProvider =
    FutureProvider<IdentityDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory =
      await ref.read(applicationDocumentsDirectoryProvider.future);
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = IdentityDatabase(
    databaseName: 'mpx_identity_db',
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
    inMemory: true,
  );

  ref.onDispose(database.close);

  return database;
});

Future<model.IdentityRepository> identityRepositoryDrift(Ref ref) async {
  final database = await ref.read(_identityDatabaseProvider.future);
  return IdentityRepositoryDrift(database: database);
}

Future<model.IdentityRepository> identityRepositoryInMemoryDrift(
  Ref ref,
) async {
  final database = await ref.read(_identityInMemoryDatabaseProvider.future);
  return IdentityRepositoryDrift(database: database);
}

@Riverpod(keepAlive: true)
Future<model.IdentityRepository> identityRepository(Ref ref) async {
  throw UnimplementedError(
      '''Please configure the application by providing an IdentityRepository implementation in ProviderScope overrides.''');
}
