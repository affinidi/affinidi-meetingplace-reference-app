import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlite;
import '../../application/services/settings_service/settings_service.dart';
import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import 'applications_documents_directory_provider.dart';

/// Resolved on-disk media cache settings for a single Matrix account database,
/// passed straight to [MatrixSdkDatabase.init].
typedef MatrixMediaCacheConfig = ({
  int maxFileSize,
  Uri? fileStorageLocation,
  Duration? deleteFilesAfterDuration,
});

/// Builds the Matrix on-disk media cache configuration for [safeDatabaseName].
///
/// The cache directory is namespaced per account database so local Matrix
/// accounts never share downloaded media. On web there is no filesystem, so
/// the disk cache is disabled (the SDK refetches media from the homeserver
/// each session) instead of crashing on [Directory].
@visibleForTesting
MatrixMediaCacheConfig matrixMediaCacheConfig({
  required Directory documentsDirectory,
  required String safeDatabaseName,
  required int maxCacheBytes,
  required Duration cacheTtl,
  bool isWeb = kIsWeb,
}) {
  if (isWeb) {
    return (
      maxFileSize: 0,
      fileStorageLocation: null,
      deleteFilesAfterDuration: null,
    );
  }
  final mediaCacheDir = Directory(
    p.join(documentsDirectory.path, 'matrix_media_$safeDatabaseName'),
  );
  return (
    maxFileSize: maxCacheBytes,
    fileStorageLocation: mediaCacheDir.uri,
    deleteFilesAfterDuration: cacheTtl,
  );
}

/// A provider that creates and supplies the [MatrixConfig] instance.
///
/// This provider:
/// - Reads the Matrix homeserver URL from the environment
///   (`MATRIX_HOMESERVER` compile-time variable)
/// - Configures the SQLite database factory to store Matrix databases
///   in the application documents directory
/// - Enables the Matrix on-disk media cache so downloaded attachments persist
///   across chat sessions and app restarts (requires both a
///   `fileStorageLocation` and a non-zero `maxFileSize`)
final matrixConfigProvider = FutureProvider<MatrixConfig>((ref) async {
  final environment = ref.read(environmentProvider);
  final settingsState = ref.read(settingsServiceProvider);
  final homeserver = ref.read(environmentProvider).matrixHomeserver;
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );

  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final deviceId = await secureStorage.provideDeviceId();

  final maxCacheBytes = environment.matrixMediaMaxCacheBytes;
  final cacheTtl = environment.matrixMediaCacheTtl;

  return MatrixConfig(
    mediatorDid: settingsState.selectedMediatorDid,
    controlPlaneDid: environment.controlPlaneDid,
    homeserver: Uri.parse(homeserver),
    deviceId: deviceId,
    databaseFactory: CallbackMatrixDatabaseFactory(
      openDatabase: (context) async {
        final safeDatabaseName = p
            .basename(context.databaseName)
            .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
        final db = await sqlite.openDatabase(
          p.join(directory.path, 'matrix_$safeDatabaseName.sqlite'),
          password: passphrase,
        );

        final cacheConfig = matrixMediaCacheConfig(
          documentsDirectory: directory,
          safeDatabaseName: safeDatabaseName,
          maxCacheBytes: maxCacheBytes,
          cacheTtl: cacheTtl,
        );
        final location = cacheConfig.fileStorageLocation;
        if (location != null) {
          await Directory.fromUri(location).create(recursive: true);
        }

        return MatrixSdkDatabase.init(
          context.databaseName,
          database: db,
          maxFileSize: cacheConfig.maxFileSize,
          fileStorageLocation: cacheConfig.fileStorageLocation,
          deleteFilesAfterDuration: cacheConfig.deleteFilesAfterDuration,
        );
      },
    ),
  );
});

