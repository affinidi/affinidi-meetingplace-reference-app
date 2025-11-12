import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as model;
import 'package:meeting_place_drift_repository/meeting_place_drift_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import 'applications_documents_directory_provider.dart';

part 'channel_repository_provider.g.dart';

/// A provider that initializes and supplies the [ChannelDatabase].
///
/// - Creates a secure, encrypted database using a passphrase
///  from secure storage.
/// - Stores the database in the application documents directory.
/// - Closes the database when the provider is disposed.
final _channelDatabaseProvider = FutureProvider<ChannelDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory =
      await ref.read(applicationDocumentsDirectoryProvider.future);
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = ChannelDatabase(
    databaseName: 'mpx_channel_db',
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
  );

  ref.onDispose(database.close);

  return database;
});

final _channelInMemoryDatabaseProvider =
    FutureProvider<ChannelDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory =
      await ref.read(applicationDocumentsDirectoryProvider.future);
  final logStatements = ref.read(environmentProvider).isDatabaseLoggingEnabled;

  final database = ChannelDatabase(
    databaseName: 'mpx_channel_db',
    passphrase: passphrase,
    directory: directory,
    logStatements: logStatements,
    inMemory: true,
  );

  ref.onDispose(database.close);

  return database;
});

/// A provider that supplies the [ChannelRepositoryDrift] instance.
///
/// - Depends on [_channelDatabaseProvider] for database initialization.
/// - Keeps the repository alive across the app lifecycle.
Future<model.ChannelRepository> channelRepositoryDrift(Ref ref) async {
  final database = await ref.read(_channelDatabaseProvider.future);
  return ChannelRepositoryDrift(database: database);
}

Future<model.ChannelRepository> channelRepositoryInMemoryDrift(Ref ref) async {
  final database = await ref.read(_channelInMemoryDatabaseProvider.future);
  return ChannelRepositoryDrift(database: database);
}

@Riverpod(keepAlive: true)
Future<model.ChannelRepository> channelRepository(Ref ref) async {
  throw UnimplementedError(
      '''Please configure the application by providing an ChannelRepository implementation in ProviderScope overrides.''');
}
