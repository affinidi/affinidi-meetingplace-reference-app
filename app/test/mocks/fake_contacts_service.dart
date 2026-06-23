import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';

/// Fake [ContactsService] for testing.
///
/// Returns a fixed [ContactsServiceState] seeded with initial contacts.
class FakeContactsService extends ContactsService {
  FakeContactsService({this._contacts = const []});

  final List<Contact> _contacts;

  @override
  ContactsServiceState build() => ContactsServiceState(contacts: _contacts);
}
