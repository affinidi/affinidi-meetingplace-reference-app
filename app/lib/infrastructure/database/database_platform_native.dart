import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../configuration/environment.dart';

/// Class with implementations specific to native platforms
class DatabasePlatform {
  /// Creates a database for native platform using SQLite
  ///
  /// [databaseName] - The database name
  /// it is required on native
  static Future<QueryExecutor> createDatabase({
    required String databaseName,
    required String passphrase,
    required Directory directory,
  }) async {
    final dbPath = p.join(directory.path, databaseName);

    final sqliteDb = sqlite3.open(dbPath);
    sqliteDb.execute("PRAGMA key = '$passphrase';");

    final cipherVersion = sqliteDb.select('PRAGMA cipher_version;');
    if (cipherVersion.isEmpty) {
      throw UnsupportedError('SQLCipher not available');
    }

    sqliteDb.select('SELECT count(*) FROM sqlite_master;');

    return NativeDatabase.opened(
      sqliteDb,
      logStatements: Environment.instance.isDatabaseLoggingEnabled,
    );
  }

  /// Creates an in-memory database for native platform using SQLite
  static Future<QueryExecutor> createInMemoryDatabase(
      {required String passphrase}) async {
    final sqliteDb = sqlite3.openInMemory();
    sqliteDb.execute("PRAGMA key = '$passphrase';");

    return NativeDatabase.opened(
      sqliteDb,
      logStatements: Environment.instance.isDatabaseLoggingEnabled,
    );
  }

  /// Gets the current platform info
  static Map<String, String> get info {
    return {
      'platform': 'native',
      'database': 'SQLite',
    };
  }
}

/// Opens a lazy database connection for the native platform.
///
/// This function creates and returns a [LazyDatabase] instance that
/// establishes a connection to the database when first accessed. The
/// connection is optimized for native platforms (iOS/Android) and uses
/// platform-specific database implementations.
///
/// Returns a [LazyDatabase] that will initialize the database connection
/// on first use, providing better performance and resource management.
///
/// Example:
/// ```dart
/// final database = openConnection();
/// // Database connection is established when first query is made
/// ```
LazyDatabase openConnection({
  required String databaseName,
  required String passphrase,
  bool inMemory = false,
  required Directory directory,
}) {
  return LazyDatabase(() async {
    if (inMemory) {
      final database = await DatabasePlatform.createInMemoryDatabase(
        passphrase: passphrase,
      );
      return database;
    }

    final database = await DatabasePlatform.createDatabase(
      databaseName: databaseName,
      passphrase: passphrase,
      directory: directory,
    );
    return database;
  });
}
