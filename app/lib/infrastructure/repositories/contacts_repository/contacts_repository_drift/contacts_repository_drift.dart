import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../domain/models/contacts/contact.dart' as model;
import '../../../../domain/repositories/contacts_repository.dart';
import '../../../../presentation/config/persona_field_config.identity_fields.g.dart';
import '../../../database/drift_sql.dart';
import '../../../exceptions/app_exception.dart';
import '../../../exceptions/app_exception_type.dart';
import '../../../extensions/contact_card_extensions.dart';
import 'contacts_database.dart' as db;

Future<ContactsRepository> contactsRepositoryDrift(Ref ref) async {
  final database = await ref.read(db.contactsDatabaseProvider.future);
  return ContactsRepositoryDrift(database: database);
}

Future<ContactsRepository> contactsRepositoryInMemoryDrift(Ref ref) async {
  final database = await ref.read(db.contactsInMemoryDatabaseProvider.future);
  return ContactsRepositoryDrift(database: database);
}

class ContactsRepositoryDrift implements ContactsRepository {
  ContactsRepositoryDrift({required db.ContactsDatabase database})
    : _database = database;

  final db.ContactsDatabase _database;

  @override
  Future<model.Contact> addContact(model.Contact contact) async {
    late model.Contact addedEntry;

    await _database.transaction(() async {
      final contactId = contact.id.isEmpty ? const Uuid().v4() : contact.id;

      await _database
          .into(_database.contacts)
          .insert(
            db.ContactsCompanion(
              id: Value(contactId),
              channelDid: Value(contact.channelDid),
              channelDidSha256: Value(contact.channelDidSha256),
              dateAdded: Value(contact.dateAdded),
              offerLink: Value(contact.offerLink),
              mediatorDid: Value(contact.mediatorDid),
              type: Value(contact.type),
              status: Value(contact.status),
              origin: Value(contact.origin),
              category: Value(contact.category),
              displayName: Value(contact.displayName),
              badgeUpdateInProgress: Value(contact.badgeUpdateInProgress),
              badgeCount: Value(contact.badgeCount),
              currentMessageSeqNo: Value(contact.currentMessageSeqNo),
              hasBeenOpened: Value(contact.hasBeenOpened),
              lastKeepAliveMessage: Value(contact.lastKeepAliveMessage),
              notificationBannerDismissed: Value(
                contact.notificationBannerDismissed,
              ),
            ),
          );

      final cardValues = _contactCardValues(
        card: contact.card,
        contactId: contactId,
      );
      await _database.customInsert(
        buildInsertSql(
          tableName: 'contact_cards',
          columnNames: cardValues.keys,
        ),
        variables: variablesFromExpressions(cardValues),
        updates: {_database.contactCards},
      );

      final newContact = await _getContactById(contactId);
      if (newContact == null) {
        throw AppException(
          'Contact not found',
          code: AppExceptionType.missingContact.name,
        );
      }

      addedEntry = newContact;
    });

    return addedEntry;
  }

  Future<model.Contact?> _getContactById(String contactId) async {
    final contact = await (_database.select(
      _database.contacts,
    )..where((filter) => filter.id.equals(contactId))).getSingleOrNull();
    if (contact == null) return null;

    final cardRow = await _database
        .customSelect(
          'SELECT * FROM contact_cards WHERE contact_id = ?',
          variables: [Variable<String>(contactId)],
        )
        .getSingleOrNull();
    if (cardRow == null) {
      throw AppException(
        'Contact card not found',
        code: AppExceptionType.missingContactCard.name,
      );
    }

    return _ContactMapper.fromDatabaseRecords(contact, cardRow);
  }

  @override
  Future<void> deleteContact(model.Contact contact) async {
    await (_database.delete(
      _database.contacts,
    )..where((filter) => filter.id.equals(contact.id))).go();
  }

  @override
  Future<List<model.Contact>> listContacts() async {
    final contacts = await _database.select(_database.contacts).get();
    final contactCardRows = await _database
        .customSelect('SELECT * FROM contact_cards')
        .get();
    final cardsByContactId = {
      for (final row in contactCardRows) row.read<String>('contact_id'): row,
    };

    return contacts.map((contact) {
      final cardRow = cardsByContactId[contact.id];
      if (cardRow == null) {
        throw AppException(
          'Contact card not found',
          code: AppExceptionType.missingContactCard.name,
        );
      }

      return _ContactMapper.fromDatabaseRecords(contact, cardRow);
    }).toList();
  }

  @override
  Future<void> updateContact(model.Contact contact) async {
    await _database.transaction(() async {
      await (_database.update(
        _database.contacts,
      )..where((c) => c.id.equals(contact.id))).write(
        db.ContactsCompanion(
          channelDid: Value(contact.channelDid),
          channelDidSha256: Value(contact.channelDidSha256),
          displayName: Value(contact.displayName),
          dateAdded: Value(contact.dateAdded),
          offerLink: Value(contact.offerLink),
          mediatorDid: Value(contact.mediatorDid),
          type: Value(contact.type),
          status: Value(contact.status),
          origin: Value(contact.origin),
          category: Value(contact.category),
          badgeUpdateInProgress: Value(contact.badgeUpdateInProgress),
          badgeCount: Value(contact.badgeCount),
          currentMessageSeqNo: Value(contact.currentMessageSeqNo),
          hasBeenOpened: Value(contact.hasBeenOpened),
          lastKeepAliveMessage: Value(contact.lastKeepAliveMessage),
          notificationBannerDismissed: Value(
            contact.notificationBannerDismissed,
          ),
        ),
      );

      final cardValues = _contactCardValues(
        card: contact.card,
        contactId: contact.id,
        includeContactId: false,
      );
      await _database.customUpdate(
        buildUpdateSql(
          tableName: 'contact_cards',
          columnNames: cardValues.keys,
          whereClause: 'contact_id = ?',
        ),
        variables: [
          ...variablesFromExpressions(cardValues),
          Variable<String>(contact.id),
        ],
        updates: {_database.contactCards},
        updateKind: UpdateKind.update,
      );
    });
  }

  Map<String, Expression> _contactCardValues({
    required ContactCard card,
    required String contactId,
    bool includeContactId = true,
  }) {
    final values = <String, Expression>{
      'did': Variable<String>(card.did),
      'type': Variable<String>(card.type),
      'profile_pic': Variable<String>(card.profilePic ?? ''),
      'meetingplace_identity_card_color': Variable<String>(
        card.cardColor ?? '',
      ),
      ...buildContactCardPersonaFieldExpressions(card),
    };

    if (includeContactId) {
      values['contact_id'] = Variable<String>(contactId);
    }

    return values;
  }
}

class _ContactMapper {
  static model.Contact fromDatabaseRecords(
    db.Contact contact,
    QueryRow cardRow,
  ) {
    final personaFields = readPersonaFieldValuesFromRow(cardRow.data);
    final profilePic = emptyToNull(cardRow.read<String>('profile_pic'));
    final cardColor = emptyToNull(
      cardRow.read<String>('meetingplace_identity_card_color'),
    );

    final domainCard = ContactCard(
      id: cardRow.read<int>('id').toString(),
      did: cardRow.read<String>('did'),
      type: cardRow.read<String>('type'),
      displayName: ContactCardUtils.fullNameFromPersonaFields(personaFields),
      personaFields: personaFields,
      profilePic: profilePic,
      cardColor: cardColor,
    );

    return model.Contact(
      id: contact.id,
      offerLink: contact.offerLink,
      card: domainCard,
      dateAdded: contact.dateAdded,
      type: contact.type,
      status: contact.status,
      mediatorDid: contact.mediatorDid,
      origin: contact.origin,
      category: contact.category,
      badgeCount: contact.badgeCount,
      badgeUpdateInProgress: contact.badgeUpdateInProgress,
      currentMessageSeqNo: contact.currentMessageSeqNo,
      hasBeenOpened: contact.hasBeenOpened,
      channelDid: contact.channelDid,
      channelDidSha256: contact.channelDidSha256,
      displayName: contact.displayName,
      lastKeepAliveMessage: contact.lastKeepAliveMessage,
      notificationBannerDismissed: contact.notificationBannerDismissed,
    );
  }
}
