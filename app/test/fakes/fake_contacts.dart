import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact_category.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact_origin.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact_status.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact_type.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

class FakeContacts {
  static final individualContact = Contact(
    id: 'individual-contact-id',
    channelDid: 'did:key:individual-channel',
    channelDidSha256: 'individual-channel-sha256',
    offerLink: 'individual-offer-link',
    card: ContactCard(
      id: 'contact-card-id',
      did: 'did:key:individual-channel',
      type: ContactCardType.individual.value,
      firstName: 'Alice',
      displayName: 'Alice Smith',
      email: 'alice@example.com',
      mobile: '+1234567891',
    ),
    otherPartyCard: ContactCard(
      id: 'other-party-card-id',
      did: 'did:key:other-party',
      type: ContactCardType.individual.value,
      firstName: 'Bob',
      displayName: 'Bob Johnson',
      email: 'bob@example.com',
      mobile: '+1234567892',
    ),
    dateAdded: DateTime(2025, 1, 1),
    type: ContactType.individual,
    status: ContactStatus.active,
    mediatorDid: 'did:key:mediator',
    origin: ContactOrigin.individualOfferPublished,
    category: ContactCategory.person,
    displayName: 'Alice Smith',
    hasBeenOpened: true,
  );

  static final groupContact = Contact(
    id: 'group-contact-id',
    channelDid: 'did:key:group-channel',
    channelDidSha256: 'group-channel-sha256',
    offerLink: 'group-offer-link',
    card: ContactCard(
      id: 'group-contact-card-id',
      did: 'did:key:group-channel',
      type: ContactCardType.individual.value,
      firstName: 'Project',
      lastName: 'Team',
      displayName: 'Project Team',
    ),
    otherPartyCard: ContactCard(
      id: 'other-party-card-id',
      did: 'did:key:other-party',
      type: ContactCardType.individual.value,
      firstName: 'Team',
      lastName: 'Admin',
      displayName: 'Team Admin',
      email: 'admin@example.com',
    ),
    dateAdded: DateTime(2025, 1, 15),
    type: ContactType.group,
    status: ContactStatus.active,
    mediatorDid: 'did:key:mediator',
    origin: ContactOrigin.groupOfferPublished,
    category: ContactCategory.group,
    displayName: 'Project Team',
    hasBeenOpened: true,
    badgeCount: 3,
  );

  static final pendingContact = Contact(
    id: 'pending-contact-id',
    channelDid: 'did:key:pending-channel',
    channelDidSha256: 'pending-channel-sha256',
    offerLink: 'pending-offer-link',
    card: ContactCard(
      id: 'pending-contact-card-id',
      did: 'did:key:pending-channel',
      type: ContactCardType.individual.value,
      firstName: 'Charlie',
      lastName: 'Brown',
      displayName: 'Charlie Brown',
    ),
    dateAdded: DateTime(2025, 2, 1),
    type: ContactType.individual,
    status: ContactStatus.pendingApproval,
    mediatorDid: 'did:key:mediator',
    origin: ContactOrigin.individualOfferPublished,
    category: ContactCategory.person,
    displayName: 'Charlie Brown',
    hasBeenOpened: false,
  );
}
