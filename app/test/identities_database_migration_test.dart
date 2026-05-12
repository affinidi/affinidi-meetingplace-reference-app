import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/identities_repository/identities_repository_drift/identities_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('IdentitiesDatabase migrations', () {
    test(
      'v1 to v3: adds did and contact_info_json columns, drops old columns',
      () async {
        final rawDb = sqlite3.openInMemory();
        // Set schema version to 1 (no did, no contact_info_json).
        rawDb.execute('PRAGMA user_version = 1');
        rawDb.execute('''
        CREATE TABLE identities_table (
          id TEXT NOT NULL PRIMARY KEY,
          display_name TEXT NOT NULL DEFAULT '',
          first_name TEXT NOT NULL DEFAULT '',
          last_name TEXT NOT NULL DEFAULT '',
          email TEXT NOT NULL DEFAULT '',
          mobile TEXT NOT NULL DEFAULT '',
          card_color TEXT NOT NULL DEFAULT '',
          profile_pic TEXT,
          is_primary INTEGER NOT NULL DEFAULT 0
        )
      ''');

        // Table is empty so the NOT NULL did column can be added
        // without a default.
        final db = IdentitiesDatabase.withExecutor(
          NativeDatabase.opened(rawDb),
        );
        addTearDown(db.close);

        // Accessing the database triggers the migration.
        await db.customSelect('SELECT 1').get();

        final cols = await db
            .customSelect("PRAGMA table_info('identities_table')")
            .get();
        final columnNames = cols.map((r) => r.data['name'] as String).toSet();

        expect(columnNames, contains('did'));
        expect(columnNames, contains('contact_info_json'));
        // Old individual columns are removed by the TableMigration in v3.
        expect(columnNames, isNot(contains('first_name')));
        expect(columnNames, isNot(contains('last_name')));
        expect(columnNames, isNot(contains('email')));
        expect(columnNames, isNot(contains('mobile')));
        expect(columnNames, isNot(contains('card_color')));
      },
    );

    test(
      'v2 to v3: migrates individual contact columns into contact_info_json',
      () async {
        final rawDb = sqlite3.openInMemory();
        // Set schema version to 2 (has did, no contact_info_json yet).
        rawDb.execute('PRAGMA user_version = 2');
        rawDb.execute('''
        CREATE TABLE identities_table (
          id TEXT NOT NULL PRIMARY KEY,
          did TEXT NOT NULL DEFAULT '',
          display_name TEXT NOT NULL DEFAULT '',
          first_name TEXT NOT NULL DEFAULT '',
          last_name TEXT NOT NULL DEFAULT '',
          email TEXT NOT NULL DEFAULT '',
          mobile TEXT NOT NULL DEFAULT '',
          card_color TEXT NOT NULL DEFAULT '',
          profile_pic TEXT,
          is_primary INTEGER NOT NULL DEFAULT 0
        )
      ''');
        rawDb.execute('''
        INSERT INTO identities_table
          (id, did, display_name, first_name, last_name, email, mobile, card_color, is_primary)
        VALUES
          ('id-1', 'did:example:123', 'Alice Smith', 'Alice', 'Smith',
           'alice@example.com', '+1234567890', '#FF0000', 0)
      ''');

        final db = IdentitiesDatabase.withExecutor(
          NativeDatabase.opened(rawDb),
        );
        addTearDown(db.close);

        final rows = await db.select(db.identitiesTable).get();
        expect(rows, hasLength(1));

        final row = rows.first;
        expect(row.did, equals('did:example:123'));

        final contactInfo =
            jsonDecode(row.contactInfoJson) as Map<String, dynamic>;

        // firstName → n.given
        expect(
          (contactInfo['n'] as Map<String, dynamic>)['given'],
          equals('Alice'),
        );
        // lastName → n.surname
        expect(
          (contactInfo['n'] as Map<String, dynamic>)['surname'],
          equals('Smith'),
        );
        // email → email.type.work
        expect(
          ((contactInfo['email'] as Map<String, dynamic>)['type']
              as Map<String, dynamic>)['work'],
          equals('alice@example.com'),
        );
        // mobile → tel.type.cell
        expect(
          ((contactInfo['tel'] as Map<String, dynamic>)['type']
              as Map<String, dynamic>)['cell'],
          equals('+1234567890'),
        );
        // card_color → x-meetingplace-identity-card-color
        expect(
          contactInfo['x-meetingplace-identity-card-color'],
          equals('#FF0000'),
        );
      },
    );
  });
}
