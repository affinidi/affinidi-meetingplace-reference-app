import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as model;
import 'package:meeting_place_drift_repository/meeting_place_drift_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import 'applications_documents_directory_provider.dart';

part 'connection_offer_repository_provider.g.dart';

/// A provider that initializes and supplies the [ConnectionOfferDatabase].
///
/// - Creates a secure, encrypted database using a passphrase from secure
///   storage.
/// - Stores the database in the application documents directory.
/// - Closes the database when the provider is disposed.
/// - Enables logging based on environment configuration.
final _connectionOffersDatabaseProvider =
    FutureProvider<ConnectionOfferDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory =
      await ref.read(applicationDocumentsDirectoryProvider.future);
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = ConnectionOfferDatabase(
    databaseName: 'mpx_connections_db',
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
  );

  ref.onDispose(database.close);

  return database;
});

final _connectionOffersInMemoryDatabaseProvider =
    FutureProvider<ConnectionOfferDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory =
      await ref.read(applicationDocumentsDirectoryProvider.future);
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = ConnectionOfferDatabase(
    databaseName: 'mpx_connections_db',
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
    inMemory: true,
  );

  ref.onDispose(database.close);

  return database;
});

/// A provider that supplies the [ConnectionOfferRepositoryDrift] instance.
///
/// - Depends on [_connectionOffersDatabaseProvider] for database
///  initialization.
/// - Keeps the repository alive across the app lifecycle.
Future<model.ConnectionOfferRepository> connectionOfferRepositoryDrift(
    Ref ref) async {
  final database = await ref.read(_connectionOffersDatabaseProvider.future);
  return ConnectionOfferRepositoryDrift(
    database: database,
  );
}

Future<model.ConnectionOfferRepository> connectionOfferRepositoryInMemoryDrift(
    Ref ref) async {
  final database =
      await ref.read(_connectionOffersInMemoryDatabaseProvider.future);
  return ConnectionOfferRepositoryDrift(
    database: database,
  );
}

@Riverpod(keepAlive: true)
Future<model.ConnectionOfferRepository> connectionOfferRepository(
    Ref ref) async {
  throw UnimplementedError(
      '''Please configure the application by providing an ConnectionOfferRepository implementation in ProviderScope overrides.''');
}
