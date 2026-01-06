import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

class FakeIdentities {
  static final primaryIdentity = Identity(
    id: 'primary-identity-id',
    did: '',
    card: ContactCard(
      id: 'primary-identity-id',
      did: 'did:key:primary-identity',
      type: ContactCardType.individual.value,
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
    card: ContactCard(
      id: 'secondary-identity-id',
      did: 'did:key:secondary-identity',
      type: ContactCardType.individual.value,
      firstName: 'Jane',
      displayName: 'Jane Doe',
    ),
    isPrimary: false,
  );
}
