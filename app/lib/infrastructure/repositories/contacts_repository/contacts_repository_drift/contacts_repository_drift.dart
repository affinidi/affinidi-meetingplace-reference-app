import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../domain/models/contacts/contact.dart' as model;
import '../../../../domain/repositories/contacts_repository.dart';
import '../../../exceptions/app_exception.dart';
import '../../../exceptions/app_exception_type.dart';
import 'contacts_database.dart' as db;

/// Drift implementation of [ContactsRepository].
///
/// - Persists contacts and their cards in the local [db.ContactsDatabase].
/// - Ensures operations like add and update run inside transactions.
Future<ContactsRepository> contactsRepositoryDrift(Ref ref) async {
  final database = await ref.read(db.contactsDatabaseProvider.future);
  return ContactsRepositoryDrift(database: database);
}

/// Creates an in-memory ContactsRepository using Drift.
///
/// Returns a [ContactsRepositoryDrift] instance backed by an in-memory
/// database for testing purposes.
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

      await _database.into(_database.contacts).insert(
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
            ),
          );

      final card = contact.card;
      await _database.into(_database.contactCards).insert(
            db.ContactCardsCompanion(
              contactId: Value(contactId),
              did: Value(card.did),
              type: Value(card.type),
              firstName: Value(card.firstName),
              lastName: Value(card.lastName ?? ''),
              email: Value(card.email ?? ''),
              mobile: Value(card.mobile ?? ''),
              profilePic: Value(card.profilePic ?? ''),
              meetingplaceIdentityCardColor: Value(card.cardColor ?? ''),
            ),
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
    final results = await Future.wait([
      (_database.select(_database.contacts)
            ..where((filter) => filter.id.equals(contactId)))
          .getSingleOrNull(),
      (_database.select(_database.contactCards)
            ..where((filter) => filter.contactId.equals(contactId)))
          .getSingleOrNull(),
    ]);

    final contact = results[0] as db.Contact?;
    if (contact == null) return null;

    final contactCard = results[1] as db.ContactCard?;
    if (contactCard == null) {
      throw AppException(
        'Contact card not found',
        code: AppExceptionType.missingContactCard.name,
      );
    }

    return _ContactMapper.fromDatabaseRecords(
      contact,
      contactCard,
    );
  }

  @override
  Future<void> deleteContact(model.Contact contact) async {
    await (_database.delete(_database.contacts)
          ..where((filter) => filter.id.equals(contact.id)))
        .go();
  }

  @override
  Future<List<model.Contact>> listContacts() async {
    final results = await _database.select(_database.contacts).join([
      leftOuterJoin(
        _database.contactCards,
        _database.contactCards.contactId.equalsExp(_database.contacts.id),
      ),
    ]).get();

    return results.map((result) {
      return _ContactMapper.fromDatabaseRecords(
        result.readTable(_database.contacts),
        result.readTable(_database.contactCards),
      );
    }).toList();
  }

  @override
  Future<void> updateContact(model.Contact contact) async {
    await _database.transaction(() async {
      await (_database.update(_database.contacts)
            ..where((c) => c.id.equals(contact.id)))
          .write(
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
        ),
      );

      final card = contact.card;
      await (_database.update(_database.contactCards)
            ..where((c) => c.contactId.equals(contact.id)))
          .write(
        db.ContactCardsCompanion(
          did: Value(card.did),
          type: Value(card.type),
          firstName: Value(card.firstName),
          lastName: Value(card.lastName ?? ''),
          email: Value(card.email ?? ''),
          mobile: Value(card.mobile ?? ''),
          profilePic: Value(card.profilePic ?? ''),
          meetingplaceIdentityCardColor: Value(card.cardColor ?? ''),
        ),
      );
    });
  }
}

class _ContactMapper {
  static model.Contact fromDatabaseRecords(
    db.Contact contact,
    db.ContactCard contactCard,
  ) {
    final domainCard = ContactCard(
      id: const Uuid().v4(),
      did: contactCard.did,
      type: contactCard.type,
      firstName: contactCard.firstName,
      displayName: [contactCard.firstName, contactCard.lastName]
          .where((s) => s.isNotEmpty)
          .join(' '),
      lastName: contactCard.lastName.isEmpty ? null : contactCard.lastName,
      email: contactCard.email.isEmpty ? null : contactCard.email,
      mobile: contactCard.mobile.isEmpty ? null : contactCard.mobile,
      profilePic:
          contactCard.profilePic.isEmpty ? null : contactCard.profilePic,
      cardColor: contactCard.meetingplaceIdentityCardColor.isEmpty
          ? null
          : contactCard.meetingplaceIdentityCardColor,
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
    );
  }
}
