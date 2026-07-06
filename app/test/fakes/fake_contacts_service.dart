import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'fake_contacts.dart';

class FakeContactsService extends ContactsService {
  FakeContactsService({List<Contact>? contacts})
    : contacts =
          contacts ??
          [
            FakeContacts.individualContact,
            FakeContacts.groupContact,
            FakeContacts.pendingContact,
            FakeContacts.newContactWithMessage,
            FakeContacts.oobContact,
            FakeContacts.oobContactDismissed,
          ];

  String? resetBadgeCalledWith;
  List<Contact> contacts;

  List<Map<String, dynamic>> addContactCalls = [];
  List<Map<String, dynamic>> updateContactCalls = [];
  List<Map<String, dynamic>> resetBadgeCalls = [];
  List<String> incrementMissedCallBadgeCalls = [];

  void setContacts(List<Contact> newContacts) {
    contacts = List<Contact>.from(newContacts);
  }

  void resetCallTracking() {
    addContactCalls.clear();
    updateContactCalls.clear();
    resetBadgeCalls.clear();
    incrementMissedCallBadgeCalls.clear();
    resetBadgeCalledWith = null;
  }

  @override
  Future<void> incrementMissedCallBadge(String channelDid) async {
    incrementMissedCallBadgeCalls.add(channelDid);
  }

  @override
  Future<void> resetContactBadgeCount(String channelDid) async {
    resetBadgeCalledWith = channelDid;
    resetBadgeCalls.add({'channelDid': channelDid});
    final contact = contacts.firstWhere(
      (c) => c.channelDid == channelDid,
      orElse: () =>
          FakeContacts.individualContact.copyWith(channelDid: channelDid),
    );
    contacts.removeWhere((c) => c.channelDid == channelDid);
    contacts.add(contact.copyWith(badgeCount: 0, hasBeenOpened: true));
  }

  @override
  Future<void> fetchContacts() async {
    contacts = [
      FakeContacts.individualContact,
      FakeContacts.groupContact,
      FakeContacts.pendingContact,
      FakeContacts.newContactWithMessage,
      FakeContacts.oobContact,
      FakeContacts.oobContactDismissed,
    ];
  }

  @override
  Future<void> addContact(Contact contact) async {
    addContactCalls.add({'contact': contact});
    contacts.add(contact);
  }

  @override
  Future<void> updateContact(Contact contact) async {
    updateContactCalls.add({'contact': contact});
    contacts.removeWhere((c) => c.id == contact.id);
    contacts.add(contact);
  }

  @override
  ContactsServiceState build() {
    return ContactsServiceState(contacts: contacts);
  }

  Contact? getContactByChannelDid(String channelDid) {
    try {
      return contacts.firstWhere((c) => c.channelDid == channelDid);
    } catch (_) {
      return null;
    }
  }
}
