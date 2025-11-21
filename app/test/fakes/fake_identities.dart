import 'package:meeting_place_core/meeting_place_core.dart';

class FakeIdentities {
  static const primaryIdentity = Identity(
    id: 'primary-identity-id',
    did: 'did:example:primary-identity-id',
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
    did: 'did:example:secondary-identity-id',
    card: ContactCard(
      id: 'secondary-identity-id',
      firstName: 'Jane',
      displayName: 'Jane Doe',
    ),
    isPrimary: false,
  );
}
