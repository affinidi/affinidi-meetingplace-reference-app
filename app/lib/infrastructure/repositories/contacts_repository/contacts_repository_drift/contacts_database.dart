import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/models/contact_card/contact_card_field_definition.dart';
import '../../../../domain/models/contacts/contact_category.dart';
import '../../../../domain/models/contacts/contact_origin.dart';
import '../../../../domain/models/contacts/contact_status.dart';
import '../../../../domain/models/contacts/contact_type.dart';
import '../../../database/database_platform.dart';
import '../../../extensions/map_path_extensions.dart';
import '../../../providers/applications_documents_directory_provider.dart';
import '../../../secure_storage/secure_storage.dart';

part 'contacts_database.g.dart';

/// Drift database for managing contacts and their associated cards.
///
/// Includes [Contacts] (main contact records) and [ContactCards]
///  (profile info).
/// Enforces foreign key constraints and supports encrypted storage.
@DriftDatabase(tables: [Contacts, ContactCards])
class ContactsDatabase extends _$ContactsDatabase {
  /// Creates a new encrypted contacts database.
  ///
  /// [databaseName] - File name of the database.
  /// [passphrase] - Encryption key for securing the database.
  ContactsDatabase({
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

  /// Creates a [ContactsDatabase] backed by the given [executor].
  ///
  /// Intended for use in tests only.
  @visibleForTesting
  ContactsDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        final result = await customSelect('PRAGMA table_info(contacts)').get();

        final hasBeenOpenedExists = result.any(
          (row) => row.data['name'] == 'has_been_opened',
        );

        if (!hasBeenOpenedExists) {
          await customStatement(
            'ALTER TABLE contacts ADD COLUMN has_been_opened INTEGER NOT '
            'NULL DEFAULT 0 CHECK (has_been_opened IN (0, 1))',
          );
        }
      }

      //this migration removes the column unsentMessage and chatInProgress
      if (from < 3) {
        await migrator.alterTable(
          // ignore: experimental_member_use
          TableMigration(
            contacts,
            columnTransformer: {
              contacts.id: contacts.id,
              contacts.channelDid: contacts.channelDid,
              contacts.channelDidSha256: contacts.channelDidSha256,
              contacts.dateAdded: contacts.dateAdded,
              contacts.offerLink: contacts.offerLink,
              contacts.mediatorDid: contacts.mediatorDid,
              contacts.type: contacts.type,
              contacts.status: contacts.status,
              contacts.origin: contacts.origin,
              contacts.category: contacts.category,
              contacts.displayName: contacts.displayName,
              contacts.badgeUpdateInProgress: contacts.badgeUpdateInProgress,
              contacts.badgeCount: contacts.badgeCount,
              contacts.currentMessageSeqNo: contacts.currentMessageSeqNo,
              contacts.hasBeenOpened: contacts.hasBeenOpened,
              contacts.lastKeepAliveMessage: contacts.lastKeepAliveMessage,
            },
          ),
        );
      }
      if (from < 4) {
        final result = await customSelect('PRAGMA table_info(contacts)').get();

        final notificationBannerDismissedExists = result.any(
          (row) => row.data['name'] == 'notification_banner_dismissed',
        );

        if (!notificationBannerDismissedExists) {
          await customStatement(
            'ALTER TABLE contacts ADD COLUMN notification_banner_dismissed'
            ' INTEGER NOT NULL DEFAULT 0 CHECK'
            ' (notification_banner_dismissed IN (0, 1))',
          );

          await customStatement(
            'UPDATE contacts SET notification_banner_dismissed = 1'
            ' WHERE origin != 1',
          );
        }
      }

      // Replaces individual columns with a single contact_info_json column.
      if (from < 5) {
        await migrator.addColumn(contactCards, contactCards.contactInfoJson);

        final rows = await customSelect(
          'SELECT id, first_name, last_name, email, mobile,'
          ' meetingplace_identity_card_color FROM contact_cards',
        ).get();

        for (final row in rows) {
          final contactInfoMap = <String, dynamic>{};
          contactInfoMap.setPathValue(
            ContactCardFieldDefinitions.byKey(
              ContactCardFieldKey.firstName,
            ).jsonPath,
            row.data['first_name'] as String? ?? '',
          );
          contactInfoMap.setPathValue(
            ContactCardFieldDefinitions.byKey(
              ContactCardFieldKey.lastName,
            ).jsonPath,
            row.data['last_name'] as String? ?? '',
          );
          contactInfoMap.setPathValue(
            ContactCardFieldDefinitions.byKey(
              ContactCardFieldKey.email,
            ).jsonPath,
            row.data['email'] as String? ?? '',
          );
          contactInfoMap.setPathValue(
            ContactCardFieldDefinitions.byKey(
              ContactCardFieldKey.mobile,
            ).jsonPath,
            row.data['mobile'] as String? ?? '',
          );
          contactInfoMap.setPathValue(const [
            'x-meetingplace-identity-card-color',
          ], row.data['meetingplace_identity_card_color'] as String? ?? '');
          final contactInfo = jsonEncode(contactInfoMap);

          await (update(
            contactCards,
          )..where((c) => c.id.equals(row.data['id'] as int))).write(
            ContactCardsCompanion(contactInfoJson: Value(contactInfo)),
          );
        }

        await migrator.alterTable(
          // ignore: experimental_member_use
          TableMigration(
            contactCards,
            columnTransformer: {
              contactCards.id: contactCards.id,
              contactCards.contactId: contactCards.contactId,
              contactCards.did: contactCards.did,
              contactCards.type: contactCards.type,
              contactCards.contactInfoJson: contactCards.contactInfoJson,
              contactCards.profilePic: contactCards.profilePic,
            },
          ),
        );
      }

      // Adds missed_call_count to track unread missed calls in the badge
      // separately from the seqNo-derived unread message count.
      if (from < 6) {
        final result = await customSelect('PRAGMA table_info(contacts)').get();
        final missedCallCountExists = result.any(
          (row) => row.data['name'] == 'missed_call_count',
        );
        if (!missedCallCountExists) {
          await customStatement(
            'ALTER TABLE contacts ADD COLUMN missed_call_count INTEGER NOT'
            ' NULL DEFAULT 0',
          );
        }
      }

      // Adds pending_missed_call_at so a missed incoming call can be reconciled
      // to its chat item on the next chat open, surviving an app restart.
      if (from < 7) {
        final result = await customSelect('PRAGMA table_info(contacts)').get();
        final pendingMissedCallAtExists = result.any(
          (row) => row.data['name'] == 'pending_missed_call_at',
        );
        if (!pendingMissedCallAtExists) {
          await customStatement(
            'ALTER TABLE contacts ADD COLUMN pending_missed_call_at INTEGER',
          );
        }
      }

      if (from < 8) {
        final result = await customSelect('PRAGMA table_info(contacts)').get();
        final pendingMissedCallIdExists = result.any(
          (row) => row.data['name'] == 'pending_missed_call_id',
        );
        if (!pendingMissedCallIdExists) {
          await customStatement(
            'ALTER TABLE contacts ADD COLUMN pending_missed_call_id TEXT',
          );
        }
      }

      // Adds active_incoming_call_id so crash-recovery replay can reconstruct
      // the missed-call marker when the app dies while the banner is visible.
      if (from < 9) {
        final result = await customSelect('PRAGMA table_info(contacts)').get();
        final activeIncomingCallIdExists = result.any(
          (row) => row.data['name'] == 'active_incoming_call_id',
        );
        if (!activeIncomingCallIdExists) {
          await customStatement(
            'ALTER TABLE contacts ADD COLUMN active_incoming_call_id TEXT',
          );
        }
      }

      // Adds pending_missed_call_miss_id (badge dedup key) and
      // last_credited_miss_id (the episode already credited) so a missed-call
      // badge credit that failed at record time can be replayed on
      // reconciliation surviving a restart, while "owed" stays derived
      // (pending_missed_call_miss_id != last_credited_miss_id) and
      // credited-ness is monotonic, so a re-heal can never double-credit.
      if (from < 10) {
        final result = await customSelect('PRAGMA table_info(contacts)').get();
        final pendingMissedCallMissIdExists = result.any(
          (row) => row.data['name'] == 'pending_missed_call_miss_id',
        );
        if (!pendingMissedCallMissIdExists) {
          await customStatement(
            'ALTER TABLE contacts ADD COLUMN pending_missed_call_miss_id TEXT',
          );
        }
        final lastCreditedMissIdExists = result.any(
          (row) => row.data['name'] == 'last_credited_miss_id',
        );
        if (!lastCreditedMissIdExists) {
          await customStatement(
            'ALTER TABLE contacts ADD COLUMN last_credited_miss_id TEXT',
          );
        }
      }
    },
  );
}

/// Main contacts table.
@DataClassName('Contact')
class Contacts extends Table {
  TextColumn get id => text().clientDefault(const Uuid().v4)();
  TextColumn get channelDid => text().nullable()();
  TextColumn get channelDidSha256 => text().nullable()();
  DateTimeColumn get dateAdded => dateTime().clientDefault(clock.now)();
  TextColumn get offerLink => text()();
  TextColumn get mediatorDid => text()();
  IntColumn get type => integer().map(const _ContactTypeConverter())();
  IntColumn get status => integer().map(const _ContactStatusConverter())();
  IntColumn get origin => integer().map(const _ContactOriginConverter())();
  IntColumn get category => integer().map(const _ContactCategoryConverter())();
  TextColumn get displayName => text().nullable()();
  BoolColumn get badgeUpdateInProgress =>
      boolean().clientDefault(() => false)();
  IntColumn get badgeCount => integer().clientDefault(() => 0)();
  IntColumn get currentMessageSeqNo => integer().clientDefault(() => 0)();
  IntColumn get missedCallCount => integer().clientDefault(() => 0)();
  DateTimeColumn get pendingMissedCallAt => dateTime().nullable()();
  TextColumn get pendingMissedCallId => text().nullable()();
  TextColumn get pendingMissedCallMissId => text().nullable()();
  TextColumn get lastCreditedMissId => text().nullable()();
  TextColumn get activeIncomingCallId => text().nullable()();
  BoolColumn get hasBeenOpened => boolean().clientDefault(() => false)();
  DateTimeColumn get lastKeepAliveMessage => dateTime().nullable()();
  BoolColumn get notificationBannerDismissed =>
      boolean().clientDefault(() => false)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Contact cards table linked to [Contacts].
///
/// Stores additional profile details such as first/last name, email,
/// mobile number, and profile picture.
@DataClassName('ContactCard')
class ContactCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contactId => text().customConstraint(
    'REFERENCES contacts(id) ON DELETE CASCADE UNIQUE NOT NULL',
  )();
  TextColumn get did => text()();
  TextColumn get type => text()();
  TextColumn get contactInfoJson => text().withDefault(const Constant('{}'))();
  TextColumn get profilePic => text().nullable()();
}

/// Converts between [ContactType] enum and its int representation.
class _ContactTypeConverter extends TypeConverter<ContactType, int> {
  const _ContactTypeConverter();

  @override
  ContactType fromSql(int fromDb) {
    return ContactType.values.firstWhere((type) => type.value == fromDb);
  }

  @override
  int toSql(ContactType value) {
    return value.value;
  }
}

/// Converts between [ContactStatus] enum and its int representation.
class _ContactStatusConverter extends TypeConverter<ContactStatus, int> {
  const _ContactStatusConverter();

  @override
  ContactStatus fromSql(int fromDb) {
    return ContactStatus.values.firstWhere((type) => type.value == fromDb);
  }

  @override
  int toSql(ContactStatus value) {
    return value.value;
  }
}

/// Converts between [ContactOrigin] enum and its int representation.
class _ContactOriginConverter extends TypeConverter<ContactOrigin, int> {
  const _ContactOriginConverter();

  @override
  ContactOrigin fromSql(int fromDb) {
    return ContactOrigin.values.firstWhere((type) => type.value == fromDb);
  }

  @override
  int toSql(ContactOrigin value) {
    return value.value;
  }
}

/// Converts between [ContactCategory] enum and its int representation.
class _ContactCategoryConverter extends TypeConverter<ContactCategory, int> {
  const _ContactCategoryConverter();

  @override
  ContactCategory fromSql(int fromDb) {
    return ContactCategory.values.firstWhere((type) => type.value == fromDb);
  }

  @override
  int toSql(ContactCategory value) {
    return value.value;
  }
}

/// A provider that initializes and supplies the [ContactsDatabase].
///
/// - Retrieves an encryption passphrase from [secureStorageProvider].
/// - Creates and opens the encrypted database.
/// - Closes the database when the provider is disposed.
final contactsDatabaseProvider = FutureProvider<ContactsDatabase>((ref) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );

  final database = ContactsDatabase(
    databaseName: 'mpx_contacts_db',
    passphrase: passphrase,
    inMemory: false,
    directory: directory,
  );

  ref.onDispose(database.close);

  return database;
});

/// A provider that initializes and supplies an in-memory [ContactsDatabase].
///
/// - Retrieves an encryption passphrase from [secureStorageProvider].
/// - Creates and opens the encrypted database in memory.
/// - Closes the database when the provider is disposed.
final contactsInMemoryDatabaseProvider = FutureProvider<ContactsDatabase>((
  ref,
) async {
  final secureStorage = await ref.read(secureStorageProvider.future);
  final passphrase = await secureStorage.provideDatabasePassphrase();
  final directory = await ref.read(
    applicationDocumentsDirectoryProvider.future,
  );

  final database = ContactsDatabase(
    databaseName: 'mpx_contacts_db',
    passphrase: passphrase,
    inMemory: true,
    directory: directory,
  );

  ref.onDispose(database.close);

  return database;
});
