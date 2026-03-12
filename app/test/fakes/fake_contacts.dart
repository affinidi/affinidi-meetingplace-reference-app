import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/identity_field.dart';
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
    card: _contactCard(
      id: 'contact-card-id',
      did: 'did:key:individual-channel',
      firstName: 'Alice',
      displayName: 'Display Alice',
      email: 'alice@example.com',
      mobile: '+1234567891',
    ),
    otherPartyCard: _contactCard(
      id: 'other-party-card-id',
      did: 'did:key:other-party',
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

  static final groupContact = Contact(
    id: 'group-contact-id',
    channelDid: 'did:key:group-channel',
    channelDidSha256: 'group-channel-sha256',
    offerLink: 'group-offer-link',
    card: _contactCard(
      id: 'group-contact-card-id',
      did: 'did:key:group-channel',
      firstName: 'Project',
      lastName: 'Team',
      displayName: 'Display Project',
    ),
    otherPartyCard: _contactCard(
      id: 'other-party-card-id',
      did: 'did:key:other-party',
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
    card: _contactCard(
      id: 'pending-contact-card-id',
      did: 'did:key:pending-channel',
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
    card: _contactCard(
      id: 'new-contact-card-id',
      did: 'did:key:new-contact-channel',
      firstName: 'Emma',
      lastName: 'Wilson',
      displayName: 'Display Emma',
      email: 'emma@example.com',
    ),
    otherPartyCard: _contactCard(
      id: 'new-contact-other-party-card-id',
      did: 'did:key:new-contact-other-party',
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
    card: _contactCard(
      id: 'oob-contact-card-id',
      did: 'did:key:oob-channel',
      firstName: 'Diana',
      lastName: 'Prince',
      displayName: 'Display Diana',
      email: 'diana@example.com',
    ),
    otherPartyCard: _contactCard(
      id: 'oob-other-party-card-id',
      did: 'did:key:oob-other-party',
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
    card: _contactCard(
      id: 'oob-contact-dismissed-card-id',
      did: 'did:key:oob-channel-dismissed',
      firstName: 'Steve',
      lastName: 'Rogers',
      displayName: 'Display Steve',
      email: 'steve@example.com',
    ),
    otherPartyCard: _contactCard(
      id: 'oob-dismissed-other-party-card-id',
      did: 'did:key:oob-dismissed-other-party',
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
