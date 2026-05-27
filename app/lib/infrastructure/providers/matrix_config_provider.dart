import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlite;

import '../configuration/environment.dart';
import '../secure_storage/secure_storage.dart';
import 'applications_documents_directory_provider.dart';

/// A provider that creates and supplies the [MatrixConfig] instance.
///
/// This provider:
/// - Reads the Matrix homeserver URL from the environment
///   (`MATRIX_HOMESERVER` compile-time variable)
/// - Configures the SQLite database factory to store Matrix databases
///   in the application documents directory
final matrixConfigProvider = FutureProvider<MatrixConfig>((ref) async {
  final environment = ref.read(environmentProvider);
  final homeserver = environment.matrixHomeserver;
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );

  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();

  return MatrixConfig(
    homeserver: Uri.parse(homeserver),
    databaseFactory: CallbackMatrixDatabaseFactory(
      openDatabase: (context) async {
        final safeDatabaseName = p
            .basename(context.databaseName)
            .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
        final db = await sqlite.openDatabase(
          p.join(directory.path, 'matrix_$safeDatabaseName.sqlite'),
          password: passphrase,
        );
        return db;
      },
    ),
  );
});
