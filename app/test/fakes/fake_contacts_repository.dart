import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/domain/repositories/contacts_repository.dart';

class FakeContactsRepository implements ContactsRepository {
  FakeContactsRepository({List<Contact> contacts = const []})
    : contacts = List<Contact>.from(contacts);

  final List<Contact> contacts;

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
    contacts.removeWhere((c) => c.id == contact.id);
    contacts.add(contact);
  }
}
