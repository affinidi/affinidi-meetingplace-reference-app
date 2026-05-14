import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_drift_repository/meeting_place_drift_repository.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import 'applications_documents_directory_provider.dart';

part 'r_cards_repository_provider.g.dart';

final _receivedRCardDatabaseProvider = FutureProvider<ReceivedRCardDatabase>((
  ref,
) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = ReceivedRCardDatabase(
    databaseName: 'mpx_received_rcards_db',
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
  );

  ref.onDispose(database.close);

  return database;
});

final _receivedRCardInMemoryDatabaseProvider =
    FutureProvider<ReceivedRCardDatabase>((ref) async {
      final secureStorage = await ref.read(secureStorageProvider.future);
      final passphrase = await secureStorage.provideDatabasePassphrase();
      final directory = await ref.read(
        applicationDocumentsDirectoryProvider.future,
      );
      final logStatements = ref
          .read(environmentProvider)
          .isDatabaseLoggingEnabled;

      final database = ReceivedRCardDatabase(
        databaseName: 'mpx_received_rcards_db',
        passphrase: passphrase,
        directory: directory,
        logStatements: logStatements,
        inMemory: true,
      );

      ref.onDispose(database.close);

      return database;
    });

/// Returns a [ReceivedRCardRepository] backed by an encrypted on-device
/// Drift database.  Used as the `overrideWith` target for
/// [rCardsRepositoryProvider] in the root [ProviderScope].
Future<ReceivedRCardRepository> rCardsRepositoryDrift(Ref ref) async {
  final database = await ref.read(_receivedRCardDatabaseProvider.future);
  return ReceivedRCardRepositoryDrift(database: database);
}

/// Returns a [ReceivedRCardRepository] backed by an in-memory Drift database.
///
/// Intended for tests and Storybook-style previews only.
Future<ReceivedRCardRepository> rCardsRepositoryInMemoryDrift(Ref ref) async {
  final database = await ref.read(
    _receivedRCardInMemoryDatabaseProvider.future,
  );
  return ReceivedRCardRepositoryDrift(database: database);
}

/// Provides the app-wide [ReceivedRCardRepository] instance.
///
/// The default implementation throws [UnimplementedError]. Override this
/// provider in the root [ProviderScope] with [rCardsRepositoryDrift].
@Riverpod(keepAlive: true)
Future<ReceivedRCardRepository> rCardsRepository(Ref ref) async {
  throw UnimplementedError(
    'Please configure the application by providing a ReceivedRCardRepository '
    'implementation in ProviderScope overrides.',
  );
}
