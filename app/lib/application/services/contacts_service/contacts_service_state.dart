import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/models/contacts/contact.dart';

part 'contacts_service_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class ContactsServiceState with _$ContactsServiceState {
  const ContactsServiceState._();

  factory ContactsServiceState({
    @Default([]) List<Contact> contacts,
    String? errorMessage,
  }) = _ContactsServiceState;

  Contact? getContactById(String contactId) {
    return contacts.firstWhereOrNull((c) => c.id == contactId);
  }

  Contact? getContactByChannelDid(String did) {
    return contacts.firstWhereOrNull((c) => c.channelDid == did);
  }

  /// Returns the contact whose [Contact.card] DID matches [did].
  ///
  /// Used to look up a contact from an R-Card whose subject DID identifies
  /// the contact's card DID.
  Contact? getContactByCardDid(String did) {
    return contacts.firstWhereOrNull((c) => c.card.did == did);
  }
}
