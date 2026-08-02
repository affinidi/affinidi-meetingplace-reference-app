import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
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
      displayName: 'Display Alice',
      email: 'alice@example.com',
      mobile: '+1234567891',
    ),
    otherPartyCard: ContactCard(
      id: 'other-party-card-id',
      did: 'did:key:other-party',
      type: ContactCardType.individual.value,
      firstName: 'Bob',
      displayName: 'Display Bob',
      email: 'bob@example.com',
      mobile: '+1234567892',
    ),
    dateAdded: DateTime(2025, 1, 1),
    type: ContactType.individual,
    status: ContactStatus.active,
    mediatorDid: 'did:key:mediator',
    origin: ContactOrigin.individualOfferPublished,
    category: ContactCategory.person,
    displayName: 'Display Alice',
    hasBeenOpened: true,
  );

  static final agentContact = Contact(
    id: 'agent-contact-id',
    channelDid: 'did:key:individual-channel',
    channelDidSha256: 'individual-channel-sha256',
    offerLink: 'agent-offer-link',
    card: const ContactCard(
      id: 'agent-contact-card-id',
      did: 'did:key:individual-channel',
      type: 'ai-agent',
      firstName: 'Personal AI',
      displayName: 'Personal AI',
    ),
    otherPartyCard: const ContactCard(
      id: 'agent-other-party-card-id',
      did: 'did:key:other-party',
      type: 'ai-agent',
      firstName: 'Personal AI',
      displayName: 'Personal AI',
    ),
    dateAdded: DateTime(2025, 1, 2),
    type: ContactType.individual,
    status: ContactStatus.active,
    mediatorDid: 'did:key:mediator',
    origin: ContactOrigin.individualOfferPublished,
    category: ContactCategory.robot,
    displayName: 'Personal AI',
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
      displayName: 'Display Project',
    ),
    otherPartyCard: ContactCard(
      id: 'other-party-card-id',
      did: 'did:key:other-party',
      type: ContactCardType.individual.value,
      firstName: 'Team',
      lastName: 'Admin',
      displayName: 'Display Team',
      email: 'admin@example.com',
    ),
    dateAdded: DateTime(2025, 1, 15),
    type: ContactType.group,
    status: ContactStatus.active,
    mediatorDid: 'did:key:mediator',
    origin: ContactOrigin.groupOfferPublished,
    category: ContactCategory.group,
    displayName: 'Display Project',
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
      displayName: 'Display Charlie',
    ),
    dateAdded: DateTime(2025, 2, 1),
    type: ContactType.individual,
    status: ContactStatus.pendingApproval,
    mediatorDid: 'did:key:mediator',
    origin: ContactOrigin.individualOfferPublished,
    category: ContactCategory.person,
    displayName: 'Display Charlie',
    hasBeenOpened: false,
  );

  static final newContactWithMessage = Contact(
    id: 'new-contact-with-message-id',
    channelDid: 'did:key:new-contact-channel',
    channelDidSha256: 'new-contact-channel-sha256',
    offerLink: 'new-contact-offer-link',
    card: ContactCard(
      id: 'new-contact-card-id',
      did: 'did:key:new-contact-channel',
      type: ContactCardType.individual.value,
      firstName: 'Emma',
      lastName: 'Wilson',
      displayName: 'Display Emma',
      email: 'emma@example.com',
    ),
    otherPartyCard: ContactCard(
      id: 'new-contact-other-party-card-id',
      did: 'did:key:new-contact-other-party',
      type: ContactCardType.individual.value,
      firstName: 'Emma',
      lastName: 'Wilson',
      displayName: 'Display Emma',
      email: 'emma@example.com',
    ),
    dateAdded: DateTime(2025, 2, 20),
    type: ContactType.individual,
    status: ContactStatus.active,
    mediatorDid: 'did:key:mediator',
    origin: ContactOrigin.individualOfferPublished,
    category: ContactCategory.person,
    displayName: 'Display Emma',
    hasBeenOpened: false,
    badgeCount: 1,
  );

  static final oobContact = Contact(
    id: 'oob-contact-id',
    channelDid: 'did:key:oob-channel',
    channelDidSha256: 'oob-channel-sha256',
    offerLink: 'oob-offer-link',
    card: ContactCard(
      id: 'oob-contact-card-id',
      did: 'did:key:oob-channel',
      type: ContactCardType.individual.value,
      firstName: 'Diana',
      lastName: 'Prince',
      displayName: 'Display Diana',
      email: 'diana@example.com',
    ),
    otherPartyCard: ContactCard(
      id: 'oob-other-party-card-id',
      did: 'did:key:oob-other-party',
      type: ContactCardType.individual.value,
      firstName: 'Diana',
      lastName: 'Prince',
      displayName: 'Display Diana',
      email: 'diana@example.com',
    ),
    dateAdded: DateTime(2025, 2, 10),
    type: ContactType.individual,
    status: ContactStatus.active,
    mediatorDid: 'did:key:mediator',
    origin: ContactOrigin.directInteractive,
    category: ContactCategory.person,
    displayName: 'Display Diana',
    hasBeenOpened: true,
    badgeCount: 0,
  );

  static final oobContactDismissed = Contact(
    id: 'oob-contact-dismissed-id',
    channelDid: 'did:key:oob-channel-dismissed',
    channelDidSha256: 'oob-channel-dismissed-sha256',
    offerLink: 'oob-offer-dismissed-link',
    card: ContactCard(
      id: 'oob-contact-dismissed-card-id',
      did: 'did:key:oob-channel-dismissed',
      type: ContactCardType.individual.value,
      firstName: 'Steve',
      lastName: 'Rogers',
      displayName: 'Display Steve',
      email: 'steve@example.com',
    ),
    otherPartyCard: ContactCard(
      id: 'oob-dismissed-other-party-card-id',
      did: 'did:key:oob-dismissed-other-party',
      type: ContactCardType.individual.value,
      firstName: 'Steve',
      lastName: 'Rogers',
      displayName: 'Display Steve',
      email: 'steve@example.com',
    ),
    dateAdded: DateTime(2025, 2, 11),
    type: ContactType.individual,
    status: ContactStatus.active,
    mediatorDid: 'did:key:mediator',
    origin: ContactOrigin.directInteractive,
    category: ContactCategory.person,
    displayName: 'Display Steve',
    hasBeenOpened: true,
    badgeCount: 0,
    notificationBannerDismissed: true,
  );

  static Contact newIndividualContact({
    required String id,
    required String channelDid,
  }) => Contact(
    id: id,
    channelDid: channelDid,
    channelDidSha256: individualContact.channelDidSha256,
    offerLink: individualContact.offerLink,
    card: individualContact.card,
    dateAdded: individualContact.dateAdded,
    type: individualContact.type,
    status: individualContact.status,
    mediatorDid: individualContact.mediatorDid,
    origin: individualContact.origin,
    category: individualContact.category,
    otherPartyCard: individualContact.otherPartyCard,
    displayName: individualContact.displayName,
    badgeUpdateInProgress: individualContact.badgeUpdateInProgress,
    badgeCount: individualContact.badgeCount,
    currentMessageSeqNo: individualContact.currentMessageSeqNo,
    hasBeenOpened: individualContact.hasBeenOpened,
    lastKeepAliveMessage: individualContact.lastKeepAliveMessage,
    notificationBannerDismissed: individualContact.notificationBannerDismissed,
  );

  /// A contact where channelDid and card.did are different.
  ///
  /// Represents the auto-exchange R-Card path: the R-Card issuerDid is the
  /// sender's identity DID (matching card.did), not the channel DID.
  static final autoExchangeContact = Contact(
    id: 'auto-exchange-contact-id',
    channelDid: 'did:key:auto-exchange-channel',
    channelDidSha256: 'auto-exchange-channel-sha256',
    offerLink: 'auto-exchange-offer-link',
    card: ContactCard(
      id: 'auto-exchange-card-id',
      did: 'did:key:auto-exchange-identity',
      type: ContactCardType.individual.value,
      firstName: 'Bob',
      lastName: 'Auto',
      displayName: 'Display Bob Auto',
    ),
    otherPartyCard: ContactCard(
      id: 'auto-exchange-other-party-card-id',
      did: 'did:key:auto-exchange-channel',
      type: ContactCardType.individual.value,
      firstName: 'Alice',
      displayName: 'Display Alice Auto',
    ),
    dateAdded: DateTime(2025, 3, 1),
    type: ContactType.individual,
    status: ContactStatus.active,
    mediatorDid: 'did:key:mediator',
    origin: ContactOrigin.individualOfferPublished,
    category: ContactCategory.person,
    displayName: 'Display Bob Auto',
    hasBeenOpened: true,
  );

  static sdk.ContactCard get sdkContactCard {
    final card = individualContact.card;
    return sdk.ContactCard(
      did: card.did,
      type: card.type,
      contactInfo: {
        'n': {
          'given': card.firstName,
          'surname': card.lastName ?? '',
          'displayName': card.displayName,
        },
        'email': {
          'type': {'work': card.email ?? ''},
        },
        'tel': {
          'type': {'cell': card.mobile ?? ''},
        },
        'photo': card.profilePic ?? '',
        'x-meetingplace-identity-card-color': card.cardColor ?? '',
      },
    );
  }
}
