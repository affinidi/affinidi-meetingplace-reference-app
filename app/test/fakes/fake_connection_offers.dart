import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

import 'fake_identities.dart';

class FakeConnectionOffers {
  static ConnectionOffer get testOffer => ConnectionOffer(
        offerName: 'Test Offer',
        offerLink: 'https://meetingplace.world/test-offer',
        mnemonic: 'test-passphrase-123',
        publishOfferDid: 'did:peer:test123',
        mediatorDid: 'did:peer:mediator123',
        oobInvitationMessage:
            '{"@type":"https://didcomm.org/out-of-band/2.0/invitation"}',
        type: ConnectionOfferType.meetingPlaceInvitation,
        status: ConnectionOfferStatus.published,
        card: FakeIdentities.secondaryIdentity.card.toSdkContactCard(
          did: 'did:example:secondary-identity-id',
          type: 'identity',
        ),
        ownedByMe: false,
        createdAt: DateTime(2024, 1, 1),
        offerDescription: 'Test offer description',
        expiresAt: DateTime(2025, 12, 31),
        maximumUsage: 10,
      );

  static ConnectionOffer get expiredOffer => ConnectionOffer(
        offerName: 'Expired Offer',
        offerLink: 'https://meetingplace.world/expired-offer',
        mnemonic: 'expired-passphrase',
        publishOfferDid: 'did:peer:expired123',
        mediatorDid: 'did:peer:mediator123',
        oobInvitationMessage:
            '{"@type":"https://didcomm.org/out-of-band/2.0/invitation"}',
        type: ConnectionOfferType.meetingPlaceInvitation,
        status: ConnectionOfferStatus.published,
        card: FakeIdentities.primaryIdentity.card.toSdkContactCard(
          did: 'did:example:primary-identity-id',
          type: 'identity',
        ),
        ownedByMe: false,
        createdAt: DateTime(2023, 1, 1),
        offerDescription: 'This offer has expired',
        expiresAt: DateTime(2023, 12, 31),
      );

  static ConnectionOffer get groupOffer => ConnectionOffer(
        offerName: 'Group Chat Offer',
        offerLink: 'https://meetingplace.world/group-offer',
        mnemonic: 'group-chat-passphrase',
        publishOfferDid: 'did:peer:group123',
        mediatorDid: 'did:peer:mediator123',
        oobInvitationMessage:
            '{"@type":"https://didcomm.org/out-of-band/2.0/invitation"}',
        type: ConnectionOfferType.meetingPlaceInvitation,
        status: ConnectionOfferStatus.published,
        card: FakeIdentities.primaryIdentity.card.toSdkContactCard(
          did: 'did:example:primary-identity-id',
          type: 'identity',
        ),
        ownedByMe: false,
        createdAt: DateTime(2024, 6, 1),
        offerDescription: 'Join our group chat',
      );
}
