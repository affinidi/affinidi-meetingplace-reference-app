import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_environment.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'utils/app.dart';

Future<void> _openChat(
  WidgetTester tester, {
  required bool audioVideoCallsEnabled,
  bool isCallSupported = true,
  required Contact contact,
}) async {
  await navigateToChat(
    tester,
    contactId: contact.id,
    contacts: [contact],
    meetingPlaceCoreSDK: FakeMeetingPlaceSDK(
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

    group('and it is an individual chat', () {
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
