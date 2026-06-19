import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';
import 'package:mpx_flutter_reference_app/presentation/painting/cached_base64_image.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/images/default_profile_image.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/profile_circle_avatar.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'utils/app.dart';

// 1x1 transparent PNG, used to give a contact card a decodable profile picture.
const _photoBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
    '+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

const _voiceAvatarKey = Key('voice_sender_avatar');

ChatAttachment _voiceAttachment() => ChatAttachment(
  mediaType: 'audio/mp4',
  filename: 'voice.m4a',
  format: sdk.AttachmentFormat.hostedMedia.value,
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

sdk.Channel _individualChannelWithMyCard(sdk.ContactCard myCard) {
  final contact = FakeContacts.individualContact;
  return sdk.Channel(
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
  );
}

sdk.Group _groupWithMember({
  required String memberDid,
  required sdk.ContactCard memberCard,
}) {
  return sdk.Group(
    id: 'group-id',
    did: 'group-did',
    offerLink: FakeContacts.groupContact.offerLink,
    members: [
      sdk.GroupMember(
        did: memberDid,
        dateAdded: DateTime(2025, 1, 1),
        status: sdk.GroupMemberStatus.approved,
        membershipType: sdk.GroupMembershipType.member,
        contactCard: memberCard,
        publicKey: 'fake-public-key',
      ),
    ],
    created: DateTime(2025, 1, 1),
    publicKey: 'fake-public-key',
  );
}

sdk.ContactCard _sdkCardWithPhoto(String did) => sdk.ContactCard(
  did: did,
  type: ContactCardType.individual.value,
  contactInfo: {
    'n': {'given': 'Member', 'surname': 'One', 'displayName': 'Member One'},
    'photo': _photoBase64,
  },
);

void main() {
  group('Voice message sender avatar', () {
    testWidgets('received 1:1 voice shows the sender contact photo', (
      tester,
    ) async {
      final contact = FakeContacts.individualContact.copyWith(
        card: FakeContacts.individualContact.card.copyWith(
          profilePic: _photoBase64,
        ),
      );
      final chatSdk = FakeChatSdk();

      await navigateToChat(
        tester,
        contactId: contact.id,
        chatSdk: chatSdk,
        contacts: [contact],
      );

      chatSdk.simulateIncomingTextMessage(
        text: '',
        recipientDid: contact.channelDid!,
        attachments: [_voiceAttachment()],
      );
      await tester.pumpAndSettle();

      expect(_voiceAvatar(tester).image, isA<CachedBase64Image>());
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

    testWidgets('sent voice shows my own profile photo', (tester) async {
      final contact = FakeContacts.individualContact;
      final myCard = contact.card
          .copyWith(profilePic: _photoBase64)
          .toSdkContactCard();
      final coreSdk = FakeMeetingPlaceSDK(
        channels: {contact.channelDid!: _individualChannelWithMyCard(myCard)},
      );
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

      expect(_voiceAvatar(tester).image, isA<CachedBase64Image>());
    });

    testWidgets('received group voice shows the matched member photo', (
      tester,
    ) async {
      const memberDid = 'did:key:photo-member';
      final groupContact = FakeContacts.groupContact;
      final coreSdk = FakeMeetingPlaceSDK(channels: FakeChannels.allChannels)
        ..setMockGroup(
          _groupWithMember(
            memberDid: memberDid,
            memberCard: _sdkCardWithPhoto(memberDid),
          ),
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
        senderDid: memberDid,
      );
      await tester.pumpAndSettle();

      expect(_voiceAvatar(tester).image, isA<CachedBase64Image>());
    });

    testWidgets('received group voice falls back to the icon '
        'for an unknown sender', (tester) async {
      const memberDid = 'did:key:photo-member';
      final groupContact = FakeContacts.groupContact;
      final coreSdk = FakeMeetingPlaceSDK(channels: FakeChannels.allChannels)
        ..setMockGroup(
          _groupWithMember(
            memberDid: memberDid,
            memberCard: _sdkCardWithPhoto(memberDid),
          ),
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
