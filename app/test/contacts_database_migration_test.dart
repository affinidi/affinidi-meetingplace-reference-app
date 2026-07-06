import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/repositories/contacts_repository/contacts_repository_drift/contacts_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  group('ContactsDatabase migrations', () {
    test('v4 to v5: migrates individual contact_cards columns into '
        'contact_info_json', () async {
      final rawDb = sqlite3.openInMemory();
      // Set schema version to 4 (has notification_banner_dismissed,
      // no contact_info_json).
      rawDb.execute('PRAGMA user_version = 4');

      // contacts table is required because contact_cards has a FK to it.
      rawDb.execute('''
          CREATE TABLE contacts (
            id TEXT NOT NULL PRIMARY KEY,
            channel_did TEXT,
            channel_did_sha256 TEXT,
            date_added INTEGER NOT NULL,
            offer_link TEXT NOT NULL DEFAULT '',
            mediator_did TEXT NOT NULL DEFAULT '',
            type INTEGER NOT NULL DEFAULT 0,
            status INTEGER NOT NULL DEFAULT 0,
            origin INTEGER NOT NULL DEFAULT 0,
            category INTEGER NOT NULL DEFAULT 0,
            display_name TEXT,
            badge_update_in_progress INTEGER NOT NULL DEFAULT 0,
            badge_count INTEGER NOT NULL DEFAULT 0,
            current_message_seq_no INTEGER NOT NULL DEFAULT 0,
            has_been_opened INTEGER NOT NULL DEFAULT 0,
            last_keep_alive_message INTEGER,
            notification_banner_dismissed INTEGER NOT NULL DEFAULT 0
          )
        ''');
      rawDb.execute('''
          CREATE TABLE contact_cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            contact_id TEXT NOT NULL UNIQUE REFERENCES contacts(id) ON DELETE CASCADE,
            did TEXT NOT NULL DEFAULT '',
            type TEXT NOT NULL DEFAULT '',
            first_name TEXT NOT NULL DEFAULT '',
            last_name TEXT NOT NULL DEFAULT '',
            email TEXT NOT NULL DEFAULT '',
            mobile TEXT NOT NULL DEFAULT '',
            meetingplace_identity_card_color TEXT NOT NULL DEFAULT '',
            profile_pic TEXT
          )
        ''');

      // Seed a contacts row (required for FK).
      rawDb.execute('''
          INSERT INTO contacts (id, date_added, offer_link, mediator_did, type,
            status, origin, category)
          VALUES ('contact-1', 0, '', '', 0, 0, 1, 0)
        ''');

      // Seed a contact_cards row with old individual columns.
      rawDb.execute('''
          INSERT INTO contact_cards
            (contact_id, did, type, first_name, last_name, email, mobile,
             meetingplace_identity_card_color)
          VALUES
            ('contact-1', 'did:example:abc', 'peer',
             'Bob', 'Jones', 'bob@example.com', '+9876543210', '#00FF00')
        ''');

      final db = ContactsDatabase.withExecutor(NativeDatabase.opened(rawDb));
      addTearDown(db.close);

      // Trigger migration.
      final cards = await db.select(db.contactCards).get();
      expect(cards, hasLength(1));

      final card = cards.first;

      // Verify schema: new column present, old columns removed.
      final cols = await db
          .customSelect("PRAGMA table_info('contact_cards')")
          .get();
      final columnNames = cols.map((r) => r.data['name'] as String).toSet();

      expect(columnNames, contains('contact_info_json'));
      expect(columnNames, isNot(contains('first_name')));
      expect(columnNames, isNot(contains('last_name')));
      expect(columnNames, isNot(contains('email')));
      expect(columnNames, isNot(contains('mobile')));
      expect(columnNames, isNot(contains('meetingplace_identity_card_color')));

      // Verify data was correctly migrated into contact_info_json.
      final contactInfo =
          jsonDecode(card.contactInfoJson) as Map<String, dynamic>;

      // firstName → n.given
      expect(
        (contactInfo['n'] as Map<String, dynamic>)['given'],
        equals('Bob'),
      );
      // lastName → n.surname
      expect(
        (contactInfo['n'] as Map<String, dynamic>)['surname'],
        equals('Jones'),
      );
      // email → email.type.work
      expect(
        ((contactInfo['email'] as Map<String, dynamic>)['type']
            as Map<String, dynamic>)['work'],
        equals('bob@example.com'),
      );
      // mobile → tel.type.cell
      expect(
        ((contactInfo['tel'] as Map<String, dynamic>)['type']
            as Map<String, dynamic>)['cell'],
        equals('+9876543210'),
      );
      // card_color → x-meetingplace-identity-card-color
      expect(
        contactInfo['x-meetingplace-identity-card-color'],
        equals('#00FF00'),
      );
    });

    test('v5 to v6: adds missed_call_count column defaulting to 0', () async {
      final rawDb = sqlite3.openInMemory();
      rawDb.execute('PRAGMA user_version = 5');

      // v5 contacts schema: no missed_call_count yet.
      rawDb.execute('''
          CREATE TABLE contacts (
            id TEXT NOT NULL PRIMARY KEY,
            channel_did TEXT,
            channel_did_sha256 TEXT,
            date_added INTEGER NOT NULL,
            offer_link TEXT NOT NULL DEFAULT '',
            mediator_did TEXT NOT NULL DEFAULT '',
            type INTEGER NOT NULL DEFAULT 0,
            status INTEGER NOT NULL DEFAULT 0,
            origin INTEGER NOT NULL DEFAULT 0,
            category INTEGER NOT NULL DEFAULT 0,
            display_name TEXT,
            badge_update_in_progress INTEGER NOT NULL DEFAULT 0,
            badge_count INTEGER NOT NULL DEFAULT 0,
            current_message_seq_no INTEGER NOT NULL DEFAULT 0,
            has_been_opened INTEGER NOT NULL DEFAULT 0,
            last_keep_alive_message INTEGER,
            notification_banner_dismissed INTEGER NOT NULL DEFAULT 0
          )
        ''');
      // v5 contact_cards schema (already migrated to contact_info_json).
      rawDb.execute('''
          CREATE TABLE contact_cards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            contact_id TEXT NOT NULL UNIQUE REFERENCES contacts(id) ON DELETE CASCADE,
            did TEXT NOT NULL DEFAULT '',
            type TEXT NOT NULL DEFAULT '',
            contact_info_json TEXT NOT NULL DEFAULT '{}',
            profile_pic TEXT
          )
        ''');

      rawDb.execute('''
          INSERT INTO contacts (id, date_added, offer_link, mediator_did, type,
            status, origin, category, badge_count)
          VALUES ('contact-1', 0, '', '', 0, 0, 1, 0, 3)
        ''');

      final db = ContactsDatabase.withExecutor(NativeDatabase.opened(rawDb));
      addTearDown(db.close);

      // Trigger migration.
      final contacts = await db.select(db.contacts).get();
      expect(contacts, hasLength(1));

      final cols = await db.customSelect("PRAGMA table_info('contacts')").get();
      final columnNames = cols.map((r) => r.data['name'] as String).toSet();
      expect(columnNames, contains('missed_call_count'));

      // Existing rows default to 0; unrelated columns are preserved.
      expect(contacts.first.missedCallCount, equals(0));
      expect(contacts.first.badgeCount, equals(3));
    });
  });
}
