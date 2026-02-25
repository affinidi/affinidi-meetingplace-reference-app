import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_drift_repository/meeting_place_drift_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import 'applications_documents_directory_provider.dart';

part 'chat_repository_provider.g.dart';

typedef _ChatDbConfig = ({
  String passphrase,
  Directory directory,
  bool logStatements,
});

/// Resolves the shared database configuration (passphrase, directory, log
/// flag) from secure storage. Results are shared between the on-disk and
/// in-memory database providers to avoid duplicate secure-storage reads.
final _chatDbConfigProvider = FutureProvider<_ChatDbConfig>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory =
      await ref.read(applicationDocumentsDirectoryProvider.future);
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;
  return (
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
  );
});

/// Opens the encrypted on-disk [ChatItemsDatabase] eagerly (non-lazy).
///
/// - Uses [ChatItemsDatabase.create] which opens SQLCipher immediately,
///   so there is no deferred first-query latency.
/// - Closes the database when the provider is disposed.
final _chatDatabaseProvider = FutureProvider<ChatItemsDatabase>((ref) async {
  final config = await ref.read(_chatDbConfigProvider.future);
  final database = await ChatItemsDatabase.create(
    databaseName: 'mpx_chat_items_db',
    passphrase: config.passphrase,
    directory: config.directory,
    logStatements: config.logStatements,
  );
  ref.onDispose(database.close);
  return database;
});

/// Opens an encrypted in-memory [ChatItemsDatabase] eagerly (non-lazy).
///
/// Used in tests and development environments where persistence is not needed.
/// Closes the database when the provider is disposed.
final _chatInMemoryDatabaseProvider =
    FutureProvider<ChatItemsDatabase>((ref) async {
  final config = await ref.read(_chatDbConfigProvider.future);
  final database = await ChatItemsDatabase.createInMemory(
    passphrase: config.passphrase,
    logStatements: config.logStatements,
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
