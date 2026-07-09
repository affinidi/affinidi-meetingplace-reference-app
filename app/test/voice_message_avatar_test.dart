import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/audio_attachments_plugin/audio_attachments_plugin.dart';
import 'package:mpx_flutter_reference_app/presentation/painting/cached_base64_image.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/images/default_profile_image.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/profile_circle_avatar.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_meeting_place_matrix_sdk.dart';
import 'utils/app.dart';

// Four distinct, decodable 1x1 PNGs so each test can assert that the avatar
// shows the photo of the EXPECTED source, not merely some base64 image.
const _myPhoto =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR42mP4'
    'z8AAAAMBAQD3A0FDAAAAAElFTkSuQmCC';
const _contactPhoto =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR42mNg'
    '+M8AAAICAQBF9FLUAAAAAElFTkSuQmCC';
const _memberPhoto =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR42mNg'
    'YPgPAAEDAQA2dBFAAAAAAElFTkSuQmCC';
const _otherMemberPhoto =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR42mP4'
    '/58BAAT/Af9jgNErAAAAAElFTkSuQmCC';
// A stale own card stored on the channel, distinct from the live identity
// photo, so a test can prove `myCard` comes from the live identity.
const _stalePhoto =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR42mP4'
    'z/AfAAQAAf8c9+lcAAAAAElFTkSuQmCC';

const _voiceAvatarKey = Key('voice_sender_avatar');

ChatAttachment _voiceAttachment() => ChatAttachment(
  id: 'voice-avatar-attachment',
  mediaType: 'audio/mp4',
  filename: 'voice.m4a',
  format: AudioAttachmentsPlugin.pluginName,
  data: ChatAttachmentData(links: [Uri.parse('mxc://fake-homeserver/voice')]),
  metadata: VoiceMessageMetadata(
    durationMs: 11000,
    waveform: [0, 35, 100],
  ).toMetadata(),
);

ProfileCircleAvatar _voiceAvatar(WidgetTester tester) {
  final finder = find.byKey(_voiceAvatarKey);
  expect(finder, findsOneWidget);
  return tester.widget<ProfileCircleAvatar>(finder);
}

/// The base64 of the photo actually shown in the voice avatar, failing the test
/// if the avatar is not rendering a base64 profile picture.
String _voiceAvatarPhoto(WidgetTester tester) {
  final image = _voiceAvatar(tester).image;
  expect(
    image,
    isA<CachedBase64Image>(),
    reason: 'voice avatar should render a base64 profile picture',
  );
  return (image! as CachedBase64Image).base64String;
}

Contact _contactWithPhoto(String base64) =>
    FakeContacts.individualContact.copyWith(
      card: FakeContacts.individualContact.card.copyWith(profilePic: base64),
    );

/// Core SDK whose individual channel reports MY own contact card carrying
/// [base64], so `myCard` is distinct from the contact card.
FakeMeetingPlaceMatrixSDK _coreSdkWithMyPhoto(String base64) {
  final contact = FakeContacts.individualContact;
  final myCard = contact.card.copyWith(profilePic: base64).toSdkContactCard();
  return FakeMeetingPlaceMatrixSDK(
    channels: {
      contact.channelDid!: sdk.Channel(
        permanentChannelDid: contact.channelDid!,
        otherPartyPermanentChannelDid: contact.channelDid!,
        offerLink: contact.offerLink,
        contactCard: myCard,
        otherPartyContactCard: contact.otherPartyCard?.toSdkContactCard(),
        otherPartyNotificationToken: 'fake-notification-token',
        seqNo: 0,
        type: sdk.ChannelType.individual,
        publishOfferDid: 'did:key:individual-offer',
        mediatorDid: contact.mediatorDid,
        status: sdk.ChannelStatus.inaugurated,
        isConnectionInitiator: true,
      ),
    },
  );
}

/// A copy of the primary identity whose card carries [base64], representing the
/// live (just-updated) own profile photo.
Identity _identityWithPhoto(String base64) =>
    FakeIdentities.primaryIdentity.copyWith(
      card: FakeIdentities.primaryIdentity.card.copyWith(profilePic: base64),
    );

/// Core SDK whose individual channel links to identity [externalRef] but still
/// stores [staleBase64] as its own contact card, so a test can prove `myCard`
/// is resolved from the live identity rather than the stale channel snapshot.
FakeMeetingPlaceMatrixSDK _coreSdkLinkedToIdentity({
  required String externalRef,
  required String staleBase64,
}) {
  final contact = FakeContacts.individualContact;
  final staleCard = contact.card
      .copyWith(profilePic: staleBase64)
      .toSdkContactCard();
  return FakeMeetingPlaceMatrixSDK(
    channels: {
      contact.channelDid!: sdk.Channel(
        permanentChannelDid: contact.channelDid!,
        otherPartyPermanentChannelDid: contact.channelDid!,
        offerLink: contact.offerLink,
        contactCard: staleCard,
        otherPartyContactCard: contact.otherPartyCard?.toSdkContactCard(),
        otherPartyNotificationToken: 'fake-notification-token',
        seqNo: 0,
        type: sdk.ChannelType.individual,
        publishOfferDid: 'did:key:individual-offer',
        mediatorDid: contact.mediatorDid,
        status: sdk.ChannelStatus.inaugurated,
        isConnectionInitiator: true,
        externalRef: externalRef,
      ),
    },
  );
}

sdk.GroupMember _member(String did, String photoBase64) => sdk.GroupMember(
  did: did,
  dateAdded: DateTime(2025, 1, 1),
  status: sdk.GroupMemberStatus.approved,
  membershipType: sdk.GroupMembershipType.member,
  contactCard: sdk.ContactCard(
    did: did,
    type: ContactCardType.individual.value,
    contactInfo: {
      'n': {'given': 'Member', 'surname': did, 'displayName': did},
      'photo': photoBase64,
    },
  ),
  publicKey: 'public-key-$did',
);

sdk.Group _groupWith(List<sdk.GroupMember> members) => sdk.Group(
  id: 'group-id',
  did: 'group-did',
  offerLink: FakeContacts.groupContact.offerLink,
  members: members,
  created: DateTime(2025, 1, 1),
  publicKey: 'fake-public-key',
);

void main() {
  group('Voice message sender avatar', () {
    testWidgets('received 1:1 voice shows the contact photo, not my own', (
      tester,
    ) async {
      final contact = _contactWithPhoto(_contactPhoto);
      // myCard carries a different photo to prove the received avatar comes
      // from the contact card, not from my own card.
      final coreSdk = _coreSdkWithMyPhoto(_myPhoto);
      final chatSdk = FakeChatSdk();

      await navigateToChat(
        tester,
        contactId: contact.id,
        chatSdk: chatSdk,
        contacts: [contact],
        meetingPlaceCoreSDK: coreSdk,
      );

      chatSdk.simulateIncomingTextMessage(
        text: '',
        recipientDid: contact.channelDid!,
        attachments: [_voiceAttachment()],
      );
      await tester.pumpAndSettle();

      expect(_voiceAvatarPhoto(tester), _contactPhoto);
    });

    testWidgets('received 1:1 voice falls back to the default image '
        'when the contact has no photo', (tester) async {
      final chatSdk = FakeChatSdk();

      await navigateToChat(
        tester,
        contactId: FakeContacts.individualContact.id,
        chatSdk: chatSdk,
        contacts: [FakeContacts.individualContact],
      );

      chatSdk.simulateIncomingTextMessage(
        text: '',
        recipientDid: FakeContacts.individualContact.channelDid!,
        attachments: [_voiceAttachment()],
      );
      await tester.pumpAndSettle();

      expect(_voiceAvatar(tester).image, equals(defaultProfileImage));
    });

    testWidgets('sent voice shows my own photo, not the contact photo', (
      tester,
    ) async {
      // The contact card carries a different photo to prove the sent avatar
      // comes from my own card.
      final contact = _contactWithPhoto(_contactPhoto);
      final coreSdk = _coreSdkWithMyPhoto(_myPhoto);
      final chatSdk = FakeChatSdk();

      await navigateToChat(
        tester,
        contactId: contact.id,
        chatSdk: chatSdk,
        contacts: [contact],
        meetingPlaceCoreSDK: coreSdk,
      );

      chatSdk.simulateIncomingTextMessage(
        text: '',
        recipientDid: contact.channelDid!,
        attachments: [_voiceAttachment()],
        isFromMe: true,
      );
      await tester.pumpAndSettle();

      expect(_voiceAvatarPhoto(tester), _myPhoto);
    });

    testWidgets('sent voice shows my live identity photo even when the '
        'channel still holds an old card', (tester) async {
      // Repro: the profile photo was changed after the channel was created, so
      // the channel's stored own card is stale. The avatar must reflect the
      // live identity immediately, without an app restart.
      final coreSdk = _coreSdkLinkedToIdentity(
        externalRef: FakeIdentities.primaryIdentity.id,
        staleBase64: _stalePhoto,
      );
      final chatSdk = FakeChatSdk();

      await navigateToChat(
        tester,
        contactId: FakeContacts.individualContact.id,
        chatSdk: chatSdk,
        contacts: [FakeContacts.individualContact],
        identities: [_identityWithPhoto(_myPhoto)],
        meetingPlaceCoreSDK: coreSdk,
      );

      chatSdk.simulateIncomingTextMessage(
        text: '',
        recipientDid: FakeContacts.individualContact.channelDid!,
        attachments: [_voiceAttachment()],
        isFromMe: true,
      );
      await tester.pumpAndSettle();

      expect(_voiceAvatarPhoto(tester), _myPhoto);
    });

    testWidgets('received group voice shows the matched member photo, '
        'not another member', (tester) async {
      const senderDid = 'did:key:photo-member';
      const otherMemberDid = 'did:key:other-member';
      final groupContact = FakeContacts.groupContact;
      // The matched member is listed second so the test fails if the code
      // picks the first member instead of matching by sender DID.
      final coreSdk =
          FakeMeetingPlaceMatrixSDK(channels: FakeChannels.allChannels)
            ..setMockGroup(
              _groupWith([
                _member(otherMemberDid, _otherMemberPhoto),
                _member(senderDid, _memberPhoto),
              ]),
            );
      final chatSdk = FakeChatSdk();

      await navigateToChat(
        tester,
        contactId: groupContact.id,
        chatSdk: chatSdk,
        contacts: [groupContact],
        meetingPlaceCoreSDK: coreSdk,
      );

      chatSdk.simulateIncomingTextMessage(
        text: '',
        recipientDid: groupContact.channelDid!,
        attachments: [_voiceAttachment()],
        senderDid: senderDid,
      );
      await tester.pumpAndSettle();

      expect(_voiceAvatarPhoto(tester), _memberPhoto);
    });

    testWidgets('received group voice falls back to the icon '
        'for an unknown sender', (tester) async {
      final groupContact = FakeContacts.groupContact;
      final coreSdk =
          FakeMeetingPlaceMatrixSDK(channels: FakeChannels.allChannels)
            ..setMockGroup(
              _groupWith([_member('did:key:photo-member', _memberPhoto)]),
            );
      final chatSdk = FakeChatSdk();

      await navigateToChat(
        tester,
        contactId: groupContact.id,
        chatSdk: chatSdk,
        contacts: [groupContact],
        meetingPlaceCoreSDK: coreSdk,
      );

      chatSdk.simulateIncomingTextMessage(
        text: '',
        recipientDid: groupContact.channelDid!,
        attachments: [_voiceAttachment()],
        senderDid: 'did:key:unknown-sender',
      );
      await tester.pumpAndSettle();

      expect(_voiceAvatar(tester).image, isNull);
    });
  });
}
