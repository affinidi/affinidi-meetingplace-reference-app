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
    final escapedPassphrase = passphrase.replaceAll("'", "''");

    final sqliteDb = sqlite3.open(dbPath);

    // PRAGMA cipher is sqlite3mc-specific and replaces the old
    // PRAGMA cipher_version check that only worked with SQLCipher.
    final cipherCheck = sqliteDb.select('PRAGMA cipher;');
    if (cipherCheck.isEmpty) {
      sqliteDb.dispose();
      throw UnsupportedError('Database encryption support not available');
    }

    // Try default sqlite3mc cipher first — used for new databases and
    // databases already created with the current sqlite3mc build.
    try {
      sqliteDb.execute("PRAGMA key = '$escapedPassphrase';");
      sqliteDb.select('SELECT count(*) FROM sqlite_master;');
      return NativeDatabase.opened(
        sqliteDb,
        logStatements: Environment.instance.isDatabaseLoggingEnabled,
      );
    } on SqliteException {
      sqliteDb.dispose();
    }

    // Default cipher failed — database was created with SQLCipher.
    // Reopen in compatibility mode (legacy only for migration).
    final legacyDb = sqlite3.open(dbPath);
    try {
      legacyDb.execute("PRAGMA cipher = 'sqlcipher';");
      legacyDb.execute('PRAGMA legacy = 4;');
      legacyDb.execute("PRAGMA key = '$escapedPassphrase';");
      legacyDb.select('SELECT count(*) FROM sqlite_master;');
      return NativeDatabase.opened(
        legacyDb,
        logStatements: Environment.instance.isDatabaseLoggingEnabled,
      );
    } catch (_) {
      legacyDb.dispose();
      rethrow;
    }
  }

  /// Creates an in-memory database for native platform using SQLite
  static Future<QueryExecutor> createInMemoryDatabase() async {
    final sqliteDb = sqlite3.openInMemory();

    return NativeDatabase.opened(
      sqliteDb,
      logStatements: Environment.instance.isDatabaseLoggingEnabled,
    );
  }

  /// Gets the current platform info
  static Map<String, String> get info {
    return {'platform': 'native', 'database': 'SQLite'};
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
      final database = await DatabasePlatform.createInMemoryDatabase();
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
