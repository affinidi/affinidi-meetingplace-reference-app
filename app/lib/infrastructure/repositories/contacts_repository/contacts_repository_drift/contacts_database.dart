import 'dart:io';

import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../../domain/models/contacts/contact_category.dart';
import '../../../../domain/models/contacts/contact_origin.dart';
import '../../../../domain/models/contacts/contact_status.dart';
import '../../../../domain/models/contacts/contact_type.dart';
import '../../../database/database_platform.dart';
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

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

@DataClassName('ContactCard')
class ContactCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get contactId => text().customConstraint(
    'REFERENCES contacts(id) ON DELETE CASCADE UNIQUE NOT NULL',
  )();
  TextColumn get did => text()();
  TextColumn get type => text()();
  TextColumn get contactInfoJson => text().withDefault(const Constant('{}'))();
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
  BoolColumn get hasBeenOpened => boolean().clientDefault(() => false)();
  DateTimeColumn get lastKeepAliveMessage => dateTime().nullable()();
  BoolColumn get notificationBannerDismissed =>
      boolean().clientDefault(() => false)();

  @override
  Set<Column> get primaryKey => {id};
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
