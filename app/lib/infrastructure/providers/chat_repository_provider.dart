import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_drift_repository/meeting_place_drift_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import 'applications_documents_directory_provider.dart';

part 'chat_repository_provider.g.dart';

/// A provider that initializes and supplies the [ChatItemsDatabase].
///
/// - Creates a secure, encrypted database using a passphrase
///  from secure storage.
/// - Stores the database in the application documents directory.
/// - Closes the database when the provider is disposed.
final _chatDatabaseProvider = FutureProvider<ChatItemsDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory =
      await ref.read(applicationDocumentsDirectoryProvider.future);
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = ChatItemsDatabase(
    databaseName: 'mpx_chat_items_db',
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
  );

  ref.onDispose(database.close);

  return database;
});

final _chatInMemoryDatabaseProvider =
    FutureProvider<ChatItemsDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory =
      await ref.read(applicationDocumentsDirectoryProvider.future);
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = ChatItemsDatabase(
    databaseName: 'mpx_chat_items_db',
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
    inMemory: true,
  );

  ref.onDispose(database.close);

  return database;
});

/// A provider that supplies the [ChatRepository] instance.
///
/// - Depends on [_chatDatabaseProvider] for database initialization.
/// - Keeps the repository alive across the app lifecycle.
Future<ChatRepository> chatRepositoryDrift(Ref ref) async {
  final database = await ref.read(_chatDatabaseProvider.future);
  return ChatItemsRepositoryDrift(database: database);
}

Future<ChatRepository> chatRepositoryInMemoryDrift(Ref ref) async {
  final database = await ref.read(_chatInMemoryDatabaseProvider.future);
  return ChatItemsRepositoryDrift(database: database);
}

@Riverpod(keepAlive: true)
Future<ChatRepository> chatRepository(Ref ref) async {
  throw UnimplementedError(
    '''Please configure the application by providing an ChatRepository implementation in ProviderScope overrides.''',
  );
}
