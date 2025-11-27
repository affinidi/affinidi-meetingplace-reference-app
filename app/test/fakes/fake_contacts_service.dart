import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';

class FakeContactsService extends ContactsService {
  FakeContactsService(this._contacts);

  final List<Contact> _contacts;

  @override
  ContactsServiceState build() {
    return ContactsServiceState(contacts: _contacts);
  }

  @override
  Future<void> ensureInitialized() async {
    // Already initialized with fake contacts
  }

  @override
  Future<void> fetchContacts() async {
    state = state.copyWith(contacts: _contacts);
  }

  @override
  Future<void> addContact(Contact contact) async {
    final updatedContacts = [...state.contacts, contact];
    state = state.copyWith(contacts: updatedContacts);
  }

  @override
  Future<void> updateContact(Contact contact) async {
    final updatedContacts =
        state.contacts.map((c) => c.id == contact.id ? contact : c).toList();
    state = state.copyWith(contacts: updatedContacts);
  }

  @override
  Future<void> deleteContacts(List<Contact> contacts) async {
    final contactIds = contacts.map((c) => c.id).toSet();
    final updatedContacts =
        state.contacts.where((c) => !contactIds.contains(c.id)).toList();
    state = state.copyWith(contacts: updatedContacts);
  }

  @override
  void updateContactVcard(String contactDid, VCard vCard) {
    final updatedContacts = state.contacts.map((c) {
      if (c.channelDid == contactDid) {
        return c.copyWith(otherPartyVCard: vCard);
      }
      return c;
    }).toList();
    state = state.copyWith(contacts: updatedContacts);
  }

  @override
  Future<void> updateContactLastKeepAliveMessage(
      String channelDid, DateTime dateTime) async {
    final updatedContacts = state.contacts.map((c) {
      if (c.channelDid == channelDid) {
        return c.copyWith(lastKeepAliveMessage: dateTime);
      }
      return c;
    }).toList();
    state = state.copyWith(contacts: updatedContacts);
  }

  @override
  Future<void> updateContactSequenceNumber(
      String channelDid, int sequenceNumber) async {
    final updatedContacts = state.contacts.map((c) {
      if (c.channelDid == channelDid) {
        return c.copyWith(currentMessageSeqNo: sequenceNumber);
      }
      return c;
    }).toList();
    state = state.copyWith(contacts: updatedContacts);
  }
}
