import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/identity_field.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

class FakeIdentities {
  static final primaryIdentity = Identity(
    id: 'primary-identity-id',
    did: '',
    card: _contactCard(
      id: 'primary-identity-id',
      did: 'did:key:primary-identity',
      firstName: 'John',
      displayName: 'John Doe',
      email: 'john.doe@example.com',
      mobile: '+1234567890',
    ),
    isPrimary: true,
  );

  static final secondaryIdentity = Identity(
    id: 'secondary-identity-id',
    did: '',
    card: _contactCard(
      id: 'secondary-identity-id',
      did: 'did:key:secondary-identity',
      firstName: 'Jane',
      displayName: 'Jane Doe',
    ),
    isPrimary: false,
  );
}

ContactCard _contactCard({
  required String id,
  required String did,
  required String firstName,
  required String displayName,
  String? lastName,
  String? email,
  String? mobile,
}) {
  final personaFields = <String, String>{firstNameField.key: firstName};

  if (lastName != null) {
    personaFields[lastNameField.key] = lastName;
  }
  if (email != null) {
    personaFields[emailField.key] = email;
  }
  if (mobile != null) {
    personaFields[mobileField.key] = mobile;
  }

  return ContactCard(
    id: id,
    did: did,
    type: ContactCardType.individual.value,
    displayName: displayName,
    personaFields: personaFields,
  );
}
