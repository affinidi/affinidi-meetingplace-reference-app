import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_environment.dart';
import 'fakes/fake_meeting_place_matrix_sdk.dart';
import 'utils/app.dart';

/// A Matrix chat SDK whose capabilities omit audio/video calling, matching a
/// transport (e.g. DIDComm) that has no call backend.
FakeChatSdk _chatSdkWithoutCalling() => FakeChatSdk(
  capabilities: const TransportCapabilities({
    ChatFeature.textMessaging,
    ChatFeature.imageAttachments,
    ChatFeature.reactions,
  }),
);

Future<void> _openChat(
  WidgetTester tester, {
  required bool audioVideoCallsEnabled,
  bool isCallSupported = true,
  FakeChatSdk? chatSdk,
  required Contact contact,
}) async {
  await navigateToChat(
    tester,
    contactId: contact.id,
    contacts: [contact],
    chatSdk: chatSdk,
    meetingPlaceCoreSDK: FakeMeetingPlaceMatrixSDK(
      channels: FakeChannels.allChannels,
      isCallSupported: isCallSupported,
    ),
    environment: FakeEnvironment(
      audioVideoCallsEnabled: audioVideoCallsEnabled,
    ),
  );
}

void main() {
  group('When audio video calls are disabled', () {
    final audioVideoCallsEnabled = false;

    group('and it is an individual chat', () {
      final contact = FakeContacts.individualContact;
      testWidgets('it hides audio and video call buttons', (tester) async {
        await _openChat(
          tester,
          audioVideoCallsEnabled: audioVideoCallsEnabled,
          contact: contact,
        );

        expect(find.byIcon(Icons.call), findsNothing);
        expect(find.byIcon(Icons.videocam), findsNothing);
      });
    });

    group('and it is a group chat', () {
      final contact = FakeContacts.groupContact;
      testWidgets('it hides audio and video call buttons', (tester) async {
        await _openChat(
          tester,
          audioVideoCallsEnabled: audioVideoCallsEnabled,
          contact: contact,
        );

        expect(find.byIcon(Icons.call), findsNothing);
        expect(find.byIcon(Icons.videocam), findsNothing);
      });
    });
  });

  group('When audio video calls are enabled', () {
    final audioVideoCallsEnabled = true;

    group('and the chat supports calling', () {
      final contact = FakeContacts.individualContact;

      testWidgets('it shows audio and video call buttons', (tester) async {
        await _openChat(
          tester,
          audioVideoCallsEnabled: audioVideoCallsEnabled,
          contact: contact,
        );

        expect(find.byIcon(Icons.call), findsOneWidget);
        expect(find.byIcon(Icons.videocam), findsOneWidget);
      });
    });

    group('and the chat does not support calling', () {
      final contact = FakeContacts.individualContact;

      testWidgets('it hides audio and video call buttons', (tester) async {
        await _openChat(
          tester,
          audioVideoCallsEnabled: audioVideoCallsEnabled,
          chatSdk: _chatSdkWithoutCalling(),
          contact: contact,
        );

        expect(find.byIcon(Icons.call), findsNothing);
        expect(find.byIcon(Icons.videocam), findsNothing);
      });
    });

    group('and the call backend is unavailable', () {
      final contact = FakeContacts.individualContact;

      testWidgets('it hides audio and video call buttons', (tester) async {
        await _openChat(
          tester,
          audioVideoCallsEnabled: audioVideoCallsEnabled,
          isCallSupported: false,
          contact: contact,
        );

        expect(find.byIcon(Icons.call), findsNothing);
        expect(find.byIcon(Icons.videocam), findsNothing);
      });
    });

    group('and it is a group chat', () {
      final contact = FakeContacts.groupContact;

      testWidgets('it hides audio and video call buttons', (tester) async {
        await _openChat(
          tester,
          audioVideoCallsEnabled: audioVideoCallsEnabled,
          contact: contact,
        );

        expect(find.byIcon(Icons.call), findsNothing);
        expect(find.byIcon(Icons.videocam), findsNothing);
      });
    });
  });
}
