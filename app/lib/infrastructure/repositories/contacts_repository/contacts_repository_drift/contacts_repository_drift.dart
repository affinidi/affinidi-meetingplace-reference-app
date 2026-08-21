import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:uuid/uuid.dart';

import '../../../../domain/models/contact_card/contact_card.dart';
import '../../../../domain/models/contacts/contact.dart' as model;
import '../../../../domain/repositories/contacts_repository.dart';
import '../../../exceptions/app_exception.dart';
import '../../../exceptions/app_exception_type.dart';
import '../../../extensions/contact_card_extensions.dart';
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
  ContactsRepositoryDrift({required this._database});

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
              missedCallCount: Value(contact.missedCallCount),
              pendingMissedCallAt: Value(contact.pendingMissedCallAt),
              pendingMissedCallId: Value(contact.pendingMissedCallId),
              pendingMissedCallMissId: Value(contact.pendingMissedCallMissId),
              lastCreditedMissId: Value(contact.lastCreditedMissId),
              supersededCallIds: Value(
                _ContactMapper._encodeSupersededCallIds(
                  contact.supersededCallIds,
                ),
              ),
              activeIncomingCallId: Value(contact.activeIncomingCallId),
              hasBeenOpened: Value(contact.hasBeenOpened),
              lastKeepAliveMessage: Value(contact.lastKeepAliveMessage),
              notificationBannerDismissed: Value(
                contact.notificationBannerDismissed,
              ),
            ),
          );

      final card = contact.card;
      await _database
          .into(_database.contactCards)
          .insert(_buildContactCardCompanion(card: card, contactId: contactId));

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
      (_database.select(
        _database.contacts,
      )..where((filter) => filter.id.equals(contactId))).getSingleOrNull(),
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

    return _ContactMapper.fromDatabaseRecords(contact, contactCard);
  }

  @override
  Future<void> deleteContact(model.Contact contact) async {
    await (_database.delete(
      _database.contacts,
    )..where((filter) => filter.id.equals(contact.id))).go();
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
          missedCallCount: Value(contact.missedCallCount),
          pendingMissedCallAt: Value(contact.pendingMissedCallAt),
          pendingMissedCallId: Value(contact.pendingMissedCallId),
          pendingMissedCallMissId: Value(contact.pendingMissedCallMissId),
          lastCreditedMissId: Value(contact.lastCreditedMissId),
          supersededCallIds: Value(
            _ContactMapper._encodeSupersededCallIds(contact.supersededCallIds),
          ),
          activeIncomingCallId: Value(contact.activeIncomingCallId),
          hasBeenOpened: Value(contact.hasBeenOpened),
          lastKeepAliveMessage: Value(contact.lastKeepAliveMessage),
          notificationBannerDismissed: Value(
            contact.notificationBannerDismissed,
          ),
        ),
      );

      final card = contact.card;
      await (_database.update(_database.contactCards)
            ..where((c) => c.contactId.equals(contact.id)))
          .write(_buildContactCardCompanion(card: card));
    });
  }
}

db.ContactCardsCompanion _buildContactCardCompanion({
  required ContactCard card,
  String? contactId,
}) {
  final contactInfo = Map<String, dynamic>.from(
    card.toSdkContactCard().contactInfo,
  )..remove('photo');

  return db.ContactCardsCompanion(
    contactId: contactId == null ? const Value.absent() : Value(contactId),
    did: Value(card.did),
    type: Value(card.type),
    contactInfoJson: Value(jsonEncode(contactInfo)),
    profilePic: Value(card.profilePic),
  );
}

class _ContactMapper {
  static String? _encodeSupersededCallIds(List<String> callIds) =>
      callIds.isEmpty ? null : jsonEncode(callIds);

  static List<String> _decodeSupersededCallIds(String? stored) {
    if (stored == null || stored.isEmpty) return const [];
    final decoded = jsonDecode(stored);
    if (decoded is! List) return const [];
    return decoded.whereType<String>().toList();
  }

  static model.Contact fromDatabaseRecords(
    db.Contact contact,
    db.ContactCard contactCard,
  ) {
    final decoded =
        jsonDecode(contactCard.contactInfoJson) as Map<String, dynamic>;
    final sdkCard = sdk.ContactCard(
      did: contactCard.did,
      type: contactCard.type,
      contactInfo: decoded,
    );
    final domainCard = ContactCardUtils.fromSdkContactCard(
      sdkCard,
    ).copyWith(profilePic: contactCard.profilePic);

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
      missedCallCount: contact.missedCallCount,
      pendingMissedCallAt: contact.pendingMissedCallAt,
      pendingMissedCallId: contact.pendingMissedCallId,
      pendingMissedCallMissId: contact.pendingMissedCallMissId,
      lastCreditedMissId: contact.lastCreditedMissId,
      supersededCallIds: _decodeSupersededCallIds(contact.supersededCallIds),
      activeIncomingCallId: contact.activeIncomingCallId,
      hasBeenOpened: contact.hasBeenOpened,
      channelDid: contact.channelDid,
      channelDidSha256: contact.channelDidSha256,
      displayName: contact.displayName,
      lastKeepAliveMessage: contact.lastKeepAliveMessage,
      notificationBannerDismissed: contact.notificationBannerDismissed,
    );
  }
}
