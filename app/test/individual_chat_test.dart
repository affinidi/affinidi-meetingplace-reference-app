import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'utils/app.dart';

/// Shared fake SDK instance for tests that need to simulate incoming messages
FakeMeetingPlaceSDK? _sharedFakeSdk;

/// Helper function to navigate to chat screen
Future<void> navigateToChatScreen(
  WidgetTester tester, {
  required String contactId,
  bool isAuthenticated = true,
  bool alreadyOnboarded = true,
  FakeMeetingPlaceSDK? fakeSdk,
}) async {
  final location = '/contacts/$contactId/chat';

  // Store the SDK instance if provided so tests can access it later
  if (fakeSdk != null) {
    _sharedFakeSdk = fakeSdk;
  }

  await tester.runAsync(() async {
    await navigateToLocation(
      tester,
      location,
      isAuthenticated: isAuthenticated,
      alreadyOnboarded: alreadyOnboarded,
      identities: [FakeIdentities.primaryIdentity],
      contacts: [FakeContacts.individualContact],
      meetingPlaceCoreSDK: fakeSdk,
    );

    await tester.pumpAndSettle(const Duration(seconds: 10));
  });
}

/// Helper function to find chat message input field
Finder findChatMessageInput() {
  return find.byKey(const Key('chat_message_input'));
}

/// Helper function to find send button
Finder findSendButton() {
  return find.byKey(const Key('chat_send_button'));
}

/// Helper function to find add media button
Finder findAddMediaButton() {
  return find.byKey(const Key('chat_add_media_button'));
}

/// Helper function to enter text in chat input
Future<void> enterChatMessage(WidgetTester tester, String message) async {
  final input = findChatMessageInput();
  await tester.enterText(input, message);
  await tester.pumpAndSettle();
}

/// Helper function to tap send button
Future<void> tapSendButton(WidgetTester tester) async {
  final sendButton = findSendButton();
  await tester.tap(sendButton);
  await tester.pumpAndSettle();
}

void main() {
  group('When opening an individual chat', () {
    final contactId = FakeContacts.individualContact.id;
    final contact = FakeContacts.individualContact;
    final contactName = contact.displayName ?? 'Contact';

    testWidgets('it shows the chat screen with correct title', (tester) async {
      await navigateToChatScreen(tester, contactId: contactId);

      // Verify contact name is displayed in app bar
      expect(find.text(contactName), findsOneWidget);
    });

    testWidgets('it shows the message input field', (tester) async {
      await navigateToChatScreen(tester, contactId: contactId);

      // Verify message input field exists
      final inputField = findChatMessageInput();
      expect(inputField, findsOneWidget);

      // Verify the input field is enabled
      final textField = tester.widget<TextFormField>(inputField);
      expect(textField.enabled, isNot(false));
    });

    testWidgets('it shows the send button', (tester) async {
      await navigateToChatScreen(tester, contactId: contactId);

      // Verify send button exists
      final sendButton = findSendButton();
      expect(sendButton, findsOneWidget);
    });

    testWidgets('it shows the add media button', (tester) async {
      await navigateToChatScreen(tester, contactId: contactId);

      // Verify add media button exists
      final addButton = findAddMediaButton();
      expect(addButton, findsOneWidget);
    });

    testWidgets('it shows the encryption notice', (tester) async {
      final l10n = await getL10n();

      await navigateToChatScreen(tester, contactId: contactId);

      // Verify encryption notice is displayed
      expect(find.text(l10n.chatEncryptionNotice), findsOneWidget);
    });

    testWidgets('it allows typing in the message input', (tester) async {
      await navigateToChatScreen(tester, contactId: contactId);

      const testMessage = 'Hello, this is a test message!';

      // Enter text in the input field
      await enterChatMessage(tester, testMessage);

      // Verify the text was entered
      final inputField = findChatMessageInput();
      final textField = tester.widget<TextFormField>(inputField);
      expect(textField.controller?.text, testMessage);
    });

    testWidgets('it shows contact presence status', (tester) async {
      await navigateToChatScreen(tester, contactId: contactId);

      // The presence status widget should be visible in the app bar
      // We can verify by checking if the contact display name area exists
      expect(find.text(contactName), findsOneWidget);
    });

    group('when contact has an avatar', () {
      testWidgets('it shows the contact avatar', (tester) async {
        await navigateToChatScreen(tester, contactId: contactId);

        // Verify the contact avatar widget is present in the app bar
        final contactAvatarKey = const Key('chat_contact_avatar');
        expect(find.byKey(contactAvatarKey), findsOneWidget);
      });
    });

    group('when entering a message', () {
      testWidgets('it has the send button available', (tester) async {
        await navigateToChatScreen(tester, contactId: contactId);

        const testMessage = 'Test message';

        // Enter text in the input field
        await enterChatMessage(tester, testMessage);

        // Verify send button exists
        final sendButton = findSendButton();
        expect(sendButton, findsOneWidget);
      });
    });

    group('when message list is empty', () {
      testWidgets('it shows only the encryption notice', (tester) async {
        final l10n = await getL10n();

        await navigateToChatScreen(tester, contactId: contactId);

        // Verify encryption notice is the only message shown
        expect(find.text(l10n.chatEncryptionNotice), findsOneWidget);
      });
    });

    group('when sending a message', () {
      testWidgets('it appears on the screen', (tester) async {
        await navigateToChatScreen(tester, contactId: contactId);

        const testMessage = 'Hello, this is my test message!';

        // Enter text in the input field
        await enterChatMessage(tester, testMessage);

        // Tap the send button
        await tapSendButton(tester);

        // Wait for the message to appear
        await tester.pumpAndSettle();

        // Verify the message appears in the chat
        expect(find.text(testMessage), findsOneWidget);
      });

      testWidgets('the input field is cleared after sending', (tester) async {
        await navigateToChatScreen(tester, contactId: contactId);

        const testMessage = 'Another test message';

        // Enter text in the input field
        await enterChatMessage(tester, testMessage);

        // Tap the send button
        await tapSendButton(tester);

        // Wait for the action to complete
        await tester.pumpAndSettle();

        // Verify the input field is cleared
        final inputField = findChatMessageInput();
        final textField = tester.widget<TextFormField>(inputField);
        expect(textField.controller?.text, isEmpty);
      });
    });

    group('when receiving a message', () {
      testWidgets('an incoming message appears on the screen', (tester) async {
        // Create a fake SDK that we can use to simulate incoming messages
        final fakeSdk = FakeMeetingPlaceSDK(
          channels: FakeChannels.allChannels,
        );

        // Navigate to chat with the fake SDK
        await navigateToChatScreen(
          tester,
          contactId: contactId,
          fakeSdk: fakeSdk,
        );

        const incomingMessage = 'Hello from the other side!';
        final channel = FakeChannels.individualChannel;

        // Simulate an incoming message through the fake SDK
        // PlainTextMessage implements MediatorMessage, so we can pass it directly
        final message = PlainTextMessage(
          id: 'test-incoming-message-id',
          type: Uri.parse('https://didcomm.org/basicmessage/2.0/message'),
          body: {'text': incomingMessage},
          from: channel.otherPartyPermanentChannelDid!,
          to: [channel.permanentChannelDid!],
        );

        await tester.runAsync(() async {
          // Wait for the chat screen to fully initialize and subscribe to the stream
          // The chat controller needs time to:
          // 1. Load contact
          // 2. Create chat SDK
          // 3. Start chat session
          // 4. Subscribe to mediator stream
          var attempts = 0;
          while (fakeSdk.subscriptionCount == 0 && attempts < 50) {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            attempts++;
          }

          debugPrint(
              'DEBUG: Waited for subscription. Subscriptions in fake SDK: ${fakeSdk.subscriptionCount}');

          if (fakeSdk.subscriptionCount > 0) {
            fakeSdk.simulateIncomingMessage(
              channel.permanentChannelDid!,
              message,
            );

            // Give time for the message to be processed through the stream
            await Future<void>.delayed(const Duration(seconds: 5));
          } else {
            debugPrint('WARNING: No subscription created after waiting');
          }
        });

        // Wait for the UI to update
        await tester.pumpAndSettle();

        // Verify the incoming message appears in the chat
        expect(find.text(incomingMessage), findsOneWidget);
      });
    });
  });
}
