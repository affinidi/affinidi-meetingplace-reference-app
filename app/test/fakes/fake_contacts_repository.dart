import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/domain/repositories/contacts_repository.dart';

class FakeContactsRepository implements ContactsRepository {
  FakeContactsRepository({List<Contact> contacts = const []})
    : contacts = List<Contact>.from(contacts);

  final List<Contact> contacts;

  /// When set, [updateContact] throws for calls matching this predicate,
  /// simulating a persistence failure. Defaults to never throwing; a test sets
  /// it to exercise a failed write and clears it to let writes succeed again.
  bool Function(Contact contact)? failUpdateWhen;

  @override
  Future<Contact> addContact(Contact contact) async {
    contacts.add(contact);
    return contact;
  }

  @override
  Future<void> deleteContact(Contact contact) async {
    contacts.removeWhere((c) => c.id == contact.id);
  }

  @override
  Future<List<Contact>> listContacts() async => List<Contact>.from(contacts);

  @override
  Future<void> updateContact(Contact contact) async {
    if (failUpdateWhen?.call(contact) ?? false) {
      throw Exception('simulated updateContact failure');
    }
    contacts.removeWhere((c) => c.id == contact.id);
    contacts.add(contact);
  }
}
