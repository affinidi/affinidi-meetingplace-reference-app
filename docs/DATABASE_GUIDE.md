# Database Guide

This guide explains how to add new fields to a Drift database and how to write
migration tests. The same pattern applies to all databases in this app:

| Database | File | Current schema version |
|---|---|---|
| `ContactsDatabase` | `contacts_repository_drift/contacts_database.dart` | 5 |
| `IdentitiesDatabase` | `identities_repository_drift/identities_database.dart` | 3 |
| `MediatorsDatabase` | `mediators_repository_drift/mediators_database.dart` | 1 |

---

## Adding a new database

Follow the pattern used by the existing databases.

### 1. Create a table class

Create a new `<name>_database.dart` file inside a
`<name>_repository_drift/` folder. Define a `Table` subclass for each table
you need:

```dart
@DataClassName('Widget')
class Widgets extends Table {
  TextColumn get id =>
      text().clientDefault(const Uuid().v4)();
  TextColumn get label => text()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 2. Create the database class

Annotate the class with `@DriftDatabase`, list your tables, extend
`_$<ClassName>`, and wire up `openConnection` (the shared encrypted helper
from `infrastructure/database/database_platform.dart`):

```dart
@DriftDatabase(tables: [Widgets])
class WidgetsDatabase extends _$WidgetsDatabase {
  WidgetsDatabase({
    required String databaseName,
    required String passphrase,
    required bool inMemory,
    required Directory directory,
  }) : super(
         openConnection(
           databaseName: databaseName,
           passphrase: passphrase,
           inMemory: inMemory,
           directory: directory,
         ),
       );

  /// For use in tests only.
  @visibleForTesting
  WidgetsDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
```

Start at `schemaVersion => 1`. There is no need for an `onUpgrade` block
until the second migration.

### 3. Add a Riverpod provider

At the bottom of the same file, expose the database via a `FutureProvider`:

```dart
final widgetsDatabaseProvider = FutureProvider<WidgetsDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory =
      await ref.read(applicationDocumentsDirectoryProvider.future);

  final database = WidgetsDatabase(
    databaseName: 'mpx_widgets_db',
    passphrase: passphrase,
    inMemory: false,
    directory: directory,
  );

  ref.onDispose(database.close);
  return database;
});
```

Use a unique `databaseName` string (prefixed with `mpx_` by convention).

### 4. Generate Drift code

```bash
melos gen
```

This produces the `<name>_database.g.dart` part file containing the
generated `_$<ClassName>` base class.

### 5. Update this guide

Add a row to the database table at the top of this file.

---

## Adding a new column

### 1. Add the column to the table class

Open the relevant `*_database.dart` file and add a getter to the `Table`
subclass:

```dart
// Example: adding an optional "nickname" text column to ContactCards.
TextColumn get nickname => text().nullable()();
```

### 2. Bump `schemaVersion`

Increment the integer returned by `schemaVersion` in the `GeneratedDatabase`
subclass:

```dart
@override
int get schemaVersion => 6; // was 5
```

### 3. Add a migration block

Inside `MigrationStrategy.onUpgrade`, add a new `if (from < N)` block — where
`N` is the new schema version. Never reuse or modify an existing `from < N`
block, because devices already on that version would skip it.

```dart
if (from < 6) {
  await migrator.addColumn(contactCards, contactCards.nickname);
}
```

For non-nullable columns without a Dart-level `clientDefault`, supply a SQL
default via `customStatement`:

```dart
if (from < 6) {
  await customStatement(
    'ALTER TABLE contact_cards ADD COLUMN nickname TEXT NOT NULL DEFAULT ""',
  );
}
```

### 4. Re-generate Drift code

```bash
melos gen
```

---

## Writing a migration test

Each database exposes a `withExecutor` constructor (annotated
`@visibleForTesting`) that accepts a raw `QueryExecutor`. This lets tests
supply a pre-seeded, in-memory SQLite database and assert that the migration
transforms it correctly — without touching the file system or encryption.

### Pattern

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/
    contacts_repository/contacts_repository_drift/contacts_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('ContactsDatabase migrations', () {
    test('vN-1 to vN: <what changes>', () async {
      // 1. Open a raw SQLite in-memory database.
      final rawDb = sqlite3.openInMemory();

      // 2. Set user_version to the OLD schema version.
      rawDb.execute('PRAGMA user_version = <old_version>');

      // 3. Create the tables as they existed at <old_version>.
      rawDb.execute('''
        CREATE TABLE my_table (
          id TEXT NOT NULL PRIMARY KEY,
          old_column TEXT NOT NULL DEFAULT ''
          -- do NOT include the new column here
        )
      ''');

      // 4. Optionally seed rows to verify data migration.
      rawDb.execute('''
        INSERT INTO my_table (id, old_column) VALUES ('row-1', 'value')
      ''');

      // 5. Wrap with the typed database — this triggers onUpgrade.
      final db = ContactsDatabase.withExecutor(NativeDatabase.opened(rawDb));
      addTearDown(db.close);

      // 6. Query via the typed API to trigger migration.
      final rows = await db.select(db.myTable).get();

      // 7. Assert schema changes.
      final cols = await db
          .customSelect("PRAGMA table_info('my_table')")
          .get();
      final columnNames = cols.map((r) => r.data['name'] as String).toSet();
      expect(columnNames, contains('new_column'));
      expect(columnNames, isNot(contains('old_column')));

      // 8. Assert data was migrated correctly.
      expect(rows.first.newColumn, equals('expected_value'));
    });
  });
}
```

### Key rules

- **One test per version boundary.** Cover every distinct upgrade path
  (e.g. v1→v3, v2→v3) when multiple migrations were introduced for the same
  schema version.
- **Seed the OLD schema.** The raw `CREATE TABLE` statement must reflect the
  table structure _before_ the migration, not the current Drift schema.
- **Set `PRAGMA user_version`** before wrapping with the typed database, or
  Drift will treat the database as new and skip `onUpgrade`.
- **Use `addTearDown(db.close)`** to release the in-memory database after
  each test.
- **Test files** live in `app/test/` and follow the naming convention
  `<name>_database_migration_test.dart`.
