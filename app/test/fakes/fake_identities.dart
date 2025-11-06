import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';

class FakeIdentities {
  static const primaryIdentity = Identity(
    id: 'primary-identity-id',
    card: ContactCard(
      id: 'primary-identity-id',
      firstName: 'John',
      displayName: 'John Doe',
      email: 'john.doe@example.com',
      mobile: '+1234567890',
    ),
    isPrimary: true,
  );

  static const secondaryIdentity = Identity(
    id: 'secondary-identity-id',
    card: ContactCard(
        id: 'secondary-identity-id',
        firstName: 'Jane',
        displayName: 'Jane Doe'),
    isPrimary: false,
  );
}
