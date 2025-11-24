import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact_category.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact_origin.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact_status.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact_type.dart';

class FakeContacts {
  static final individualContact = Contact(
    id: 'individual-contact-id',
    channelDid: 'did:key:individual-channel',
    channelDidSha256: 'individual-channel-sha256',
    offerLink: 'individual-offer-link',
    vCard: VCard(values: {
      'FN': 'Alice Smith',
      'N': 'Smith;Alice;;;',
      'EMAIL': 'alice@example.com',
      'TEL': '+1234567891',
    }),
    otherPartyVCard: VCard(values: {
      'FN': 'Bob Johnson',
      'N': 'Johnson;Bob;;;',
      'EMAIL': 'bob@example.com',
      'TEL': '+1234567892',
    }),
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
    vCard: VCard(values: {
      'FN': 'Project Team',
      'N': 'Team;Project;;;',
    }),
    otherPartyVCard: VCard(values: {
      'FN': 'Team Admin',
      'N': 'Admin;Team;;;',
      'EMAIL': 'admin@example.com',
    }),
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
    vCard: VCard(values: {
      'FN': 'Charlie Brown',
      'N': 'Brown;Charlie;;;',
    }),
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
