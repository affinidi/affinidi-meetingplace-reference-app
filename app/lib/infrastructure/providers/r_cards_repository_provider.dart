import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';
import 'package:meeting_place_drift_repository/meeting_place_drift_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import 'applications_documents_directory_provider.dart';
part 'r_cards_repository_provider.g.dart';

final _receivedRCardDatabaseProvider = FutureProvider<RCardDatabase>((
  ref,
) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = RCardDatabase(
    databaseName: 'mpx_received_rcards_db',
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
  );

  ref.onDispose(database.close);

  return database;
});

final _receivedRCardInMemoryDatabaseProvider = FutureProvider<RCardDatabase>((
  ref,
) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = RCardDatabase(
    databaseName: 'mpx_received_rcards_db',
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
    inMemory: true,
  );

  ref.onDispose(database.close);

  return database;
});

/// Returns a [RCardRepository] backed by an encrypted on-device
/// Drift database.  Used as the `overrideWith` target for
/// [rCardsRepositoryProvider] in the root [ProviderScope].
Future<RCardRepository> rCardsRepositoryDrift(Ref ref) async {
  final database = await ref.read(_receivedRCardDatabaseProvider.future);
  return RCardRepositoryDrift(database: database);
}

/// Returns a [RCardRepository] backed by an in-memory Drift database.
///
/// Intended for tests and Storybook-style previews only.
Future<RCardRepository> rCardsRepositoryInMemoryDrift(Ref ref) async {
  final database = await ref.read(
    _receivedRCardInMemoryDatabaseProvider.future,
  );
  return RCardRepositoryDrift(database: database);
}

/// Provides the app-wide [RCardRepository] instance.
///
/// The default implementation throws [UnimplementedError]. Override this
/// provider in the root [ProviderScope] with [rCardsRepositoryDrift].
@Riverpod(keepAlive: true)
Future<RCardRepository> rCardsRepository(Ref ref) async {
  throw UnimplementedError(
    'Please configure the application by providing a RCardRepository '
    'implementation in ProviderScope overrides.',
  );
}
