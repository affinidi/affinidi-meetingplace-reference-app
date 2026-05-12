import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../configuration/environment.dart';

/// Class with implementations specific to native platforms
class DatabasePlatform {
  static const _probeFileName = '.mpx_database_encryption_support_probe';
  static const _probeTableName = 'encryption_support_probe';
  static const _probeValue = 1;
  static bool _hasVerifiedEncryptionSupport = false;

  static UnsupportedError _encryptionSupportUnavailable() =>
      UnsupportedError('Database encryption support not available');

  static void _applyEncryptionPragmas(Database sqliteDb, String passphrase) {
    sqliteDb.execute("PRAGMA cipher = 'sqlcipher';");
    sqliteDb.execute('PRAGMA legacy = 4;');
    sqliteDb.execute("PRAGMA key = '${passphrase.replaceAll("'", "''")}';");
  }

  static void _ensureEncryptionSupport({
    required Directory directory,
    required String passphrase,
  }) {
    if (_hasVerifiedEncryptionSupport) {
      return;
    }

    _runEncryptionSupportProbe(directory: directory, passphrase: passphrase);
    _hasVerifiedEncryptionSupport = true;
  }

  static void _runEncryptionSupportProbe({
    required Directory directory,
    required String passphrase,
  }) {
    final probeFile = File(p.join(directory.path, _probeFileName));
    if (probeFile.existsSync()) {
      probeFile.deleteSync();
    }

    try {
      final probeDb = sqlite3.open(probeFile.path);
      try {
        _applyEncryptionPragmas(probeDb, passphrase);
        probeDb.execute(
          'CREATE TABLE $_probeTableName (value INTEGER NOT NULL);',
        );
        probeDb.execute(
          'INSERT INTO $_probeTableName (value) VALUES ($_probeValue);',
        );
      } finally {
        probeDb.close();
      }

      final validationDb = sqlite3.open(probeFile.path);
      try {
        _applyEncryptionPragmas(validationDb, passphrase);
        final rows = validationDb.select('SELECT value FROM $_probeTableName;');
        if (rows.length != 1 || rows.single.columnAt(0) != _probeValue) {
          throw _encryptionSupportUnavailable();
        }
      } on SqliteException {
        throw _encryptionSupportUnavailable();
      } finally {
        validationDb.close();
      }

      final wrongKeyDb = sqlite3.open(probeFile.path);
      try {
        _applyEncryptionPragmas(wrongKeyDb, '$passphrase.invalid');
        wrongKeyDb.select('SELECT value FROM $_probeTableName;');
        throw _encryptionSupportUnavailable();
      } on SqliteException {
        return;
      } finally {
        wrongKeyDb.close();
      }
    } finally {
      if (probeFile.existsSync()) {
        probeFile.deleteSync();
      }
    }
  }

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

    _ensureEncryptionSupport(directory: directory, passphrase: passphrase);

    final sqliteDb = sqlite3.open(dbPath);
    try {
      _applyEncryptionPragmas(sqliteDb, passphrase);
      sqliteDb.select('SELECT count(*) FROM sqlite_master;');

      return NativeDatabase.opened(
        sqliteDb,
        logStatements: Environment.instance.isDatabaseLoggingEnabled,
      );
    } catch (_) {
      sqliteDb.close();
      rethrow;
    }
  }

  /// Creates an in-memory database for native platform using SQLite
  ///
  /// In-memory databases do not support encryption (sqlite3mc limitation),
  /// so encryption configuration is skipped.
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
