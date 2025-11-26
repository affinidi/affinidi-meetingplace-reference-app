import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_image_picker.dart';
import 'utils/app.dart';

const _mockCameras = [
  CameraDescription(
    name: 'Mock Front Camera',
    lensDirection: CameraLensDirection.front,
    sensorOrientation: 90,
  ),
  CameraDescription(
    name: 'Mock Back Camera',
    lensDirection: CameraLensDirection.back,
    sensorOrientation: 90,
  ),
];

Future<void> navigateToChatScreen(
  WidgetTester tester, {
  required String contactId,
  ChatSDKWrapper? chatSdkWrapper,
  ImagePicker? imagePicker,
  List<CameraDescription>? mockCameras,
}) async {
  await tester.runAsync(() async {
    await navigateToLocation(
      tester,
      '/contacts/$contactId/chat',
      isAuthenticated: true,
      alreadyOnboarded: true,
      identities: [FakeIdentities.primaryIdentity],
      contacts: [FakeContacts.individualContact],
      chatSdkWrapper: chatSdkWrapper,
      imagePicker: imagePicker,
      mockCameras: mockCameras,
    );
    await tester.pumpAndSettle(const Duration(seconds: 10));
  });
}

Finder findChatMessageInput() => find.byKey(const Key('chat_message_input'));
Finder findSendButton() => find.byKey(const Key('chat_send_button'));
Finder findAddMediaButton() => find.byKey(const Key('chat_add_media_button'));

Future<void> enterChatMessage(WidgetTester tester, String message) async {
  await tester.enterText(findChatMessageInput(), message);
  await tester.pumpAndSettle();
}

Future<void> tapSendButton(WidgetTester tester) async {
  await tester.tap(findSendButton());
  await tester.pumpAndSettle();
}

Future<void> simulateIncomingMessage(
  WidgetTester tester,
  ChatSDKTestWrapper wrapper,
  String message,
) async {
  await tester.runAsync(() async {
    wrapper.simulateIncomingTextMessage(
      text: message,
      senderDid: FakeChannels.individualChannel.otherPartyPermanentChannelDid!,
      recipientDid: FakeChannels.individualChannel.permanentChannelDid!,
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
  });
  await tester.pumpAndSettle();
}

Future<void> submitMediaWithMessage(
  WidgetTester tester,
  String message,
) async {
  final textInput = find.byKey(const Key('media_review_text_input'));
  await tester.enterText(textInput, message);
  await tester.pump();

  await tester.runAsync(() async {
    await tester.tap(find.byKey(const Key('media_review_submit_button')));
    await tester.pump();
  });
  await tester.pumpAndSettle();
}

void main() {
  group('When opening an individual chat', () {
    final contactId = FakeContacts.individualContact.id;
    final contact = FakeContacts.individualContact;
    final contactName = contact.displayName ?? 'Contact';

    testWidgets('it shows the chat screen with correct title', (tester) async {
      await navigateToChatScreen(tester, contactId: contactId);

      expect(find.text(contactName), findsOneWidget);
    });

    testWidgets('it shows the message input field', (tester) async {
      await navigateToChatScreen(tester, contactId: contactId);

      final inputField = findChatMessageInput();
      expect(inputField, findsOneWidget);

      final textField = tester.widget<TextFormField>(inputField);
      expect(textField.enabled, isNot(false));
    });

    testWidgets('it shows the send button', (tester) async {
      await navigateToChatScreen(tester, contactId: contactId);

      final sendButton = findSendButton();
      expect(sendButton, findsOneWidget);
    });

    testWidgets('it shows the add media button', (tester) async {
      await navigateToChatScreen(tester, contactId: contactId);

      final addButton = findAddMediaButton();
      expect(addButton, findsOneWidget);
    });

    testWidgets('it shows the encryption notice', (tester) async {
      final l10n = await getL10n();

      await navigateToChatScreen(tester, contactId: contactId);

      expect(find.text(l10n.chatEncryptionNotice), findsOneWidget);
    });

    testWidgets('it allows typing in the message input', (tester) async {
      await navigateToChatScreen(tester, contactId: contactId);

      const testMessage = 'Hello, this is a test message!';

      await enterChatMessage(tester, testMessage);

      final inputField = findChatMessageInput();
      final textField = tester.widget<TextFormField>(inputField);
      expect(textField.controller?.text, testMessage);
    });

    testWidgets('it shows contact presence status', (tester) async {
      await navigateToChatScreen(tester, contactId: contactId);

      expect(find.text(contactName), findsOneWidget);
    });

    group('and contact has an avatar', () {
      testWidgets('it shows the contact avatar', (tester) async {
        await navigateToChatScreen(tester, contactId: contactId);

        final contactAvatarKey = const Key('chat_contact_avatar');
        expect(find.byKey(contactAvatarKey), findsOneWidget);
      });
    });

    group('and entering a message', () {
      testWidgets('it has the send button available', (tester) async {
        await navigateToChatScreen(tester, contactId: contactId);

        const testMessage = 'Test message';

        await enterChatMessage(tester, testMessage);

        final sendButton = findSendButton();
        expect(sendButton, findsOneWidget);
      });
    });

    group('and message list is empty', () {
      testWidgets('it shows only the encryption notice', (tester) async {
        final l10n = await getL10n();

        await navigateToChatScreen(tester, contactId: contactId);

        expect(find.text(l10n.chatEncryptionNotice), findsOneWidget);
      });
    });

    group('and sending a message', () {
      testWidgets('it appears on the screen', (tester) async {
        await navigateToChatScreen(tester, contactId: contactId);

        const testMessage = 'Hello, this is my test message!';

        await enterChatMessage(tester, testMessage);
        await tapSendButton(tester);
        await tester.pumpAndSettle();

        expect(find.text(testMessage), findsOneWidget);
      });

      testWidgets('the input field is cleared after sending', (tester) async {
        await navigateToChatScreen(tester, contactId: contactId);

        const testMessage = 'Another test message';

        await enterChatMessage(tester, testMessage);
        await tapSendButton(tester);
        await tester.pumpAndSettle();

        final inputField = findChatMessageInput();
        final textField = tester.widget<TextFormField>(inputField);
        expect(textField.controller?.text, isEmpty);
      });
    });

    group('and receiving a message', () {
      testWidgets('an incoming message appears on the screen', (tester) async {
        const message = 'Hello from the other side!';
        ChatSDKTestWrapper? wrapper;

        await navigateToChatScreen(
          tester,
          contactId: contactId,
          chatSdkWrapper: (realSdk) => wrapper = ChatSDKTestWrapper(realSdk),
        );

        await simulateIncomingMessage(tester, wrapper!, message);
        expect(find.text(message), findsOneWidget);
      });

      group('and user long press on the received message', () {
        testWidgets('should let user react to the message', (tester) async {
          const message = 'Test message for reactions';
          ChatSDKTestWrapper? wrapper;

          await navigateToChatScreen(
            tester,
            contactId: contactId,
            chatSdkWrapper: (realSdk) => wrapper = ChatSDKTestWrapper(realSdk),
          );

          await simulateIncomingMessage(tester, wrapper!, message);

          await tester.longPress(find.text(message));
          await tester.pumpAndSettle();

          expect(find.text('👍'), findsWidgets);
          expect(find.text('👎'), findsWidgets);

          await tester.tap(find.text('👍').first);
          await tester.pumpAndSettle();

          expect(find.text('👍'), findsWidgets);
          expect(find.text('👎'), findsNothing);
        });
      });
    });

    group('and clicking the add media button', () {
      testWidgets('should show a menu with media and effects options',
          (tester) async {
        final l10n = await getL10n();

        await navigateToChatScreen(tester, contactId: contactId);

        final addMediaButton = findAddMediaButton();
        expect(addMediaButton, findsOneWidget);

        await tester.tap(addMediaButton);
        await tester.pumpAndSettle();

        expect(find.text(l10n.generalCamera), findsOneWidget);
        expect(find.text(l10n.generalPhoto), findsOneWidget);
        expect(find.text(l10n.generalBalloons), findsOneWidget);
        expect(find.text(l10n.generalConfetti), findsOneWidget);
      });

      for (final effect in [Effect.balloons, Effect.confetti]) {
        group('and pressing on ${effect.name}', () {
          testWidgets('should call sendEffect with ${effect.name} effect',
              (tester) async {
            final l10n = await getL10n();
            final effectLabel = effect == Effect.balloons
                ? l10n.generalBalloons
                : l10n.generalConfetti;
            ChatSDKTestWrapper? wrapper;

            await navigateToChatScreen(
              tester,
              contactId: contactId,
              chatSdkWrapper: (realSdk) =>
                  wrapper = ChatSDKTestWrapper(realSdk),
            );

            await tester.tap(findAddMediaButton());
            await tester.pumpAndSettle();

            await tester.tap(find.text(effectLabel));
            await tester.pumpAndSettle();

            expect(wrapper!.sendEffectCalls, hasLength(1));
            expect(wrapper!.sendEffectCalls.first['effect'], effect);
          });
        });
      }

      group('and pressing on photo', () {
        testWidgets('should send photo and return to chat screen',
            (tester) async {
          final l10n = await getL10n();
          const message = 'Check out this photo!';
          ChatSDKTestWrapper? wrapper;

          await navigateToChatScreen(
            tester,
            contactId: contactId,
            imagePicker: FakeImagePicker.withDefaultImage(),
            chatSdkWrapper: (realSdk) => wrapper = ChatSDKTestWrapper(realSdk),
          );

          await tester.tap(findAddMediaButton());
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.generalPhoto));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('media_review_submit_button')),
              findsOneWidget);
          expect(find.byIcon(Icons.cancel_sharp), findsOneWidget);

          await submitMediaWithMessage(tester, message);

          expect(wrapper!.sendTextMessageCalls, hasLength(1));
          final sendCall = wrapper!.sendTextMessageCalls.first;
          expect(sendCall['text'], message);
          expect(sendCall['attachments'], isA<List<Attachment>>());
          expect((sendCall['attachments'] as List).length, 1);

          expect(find.text(contactName), findsOneWidget);
          expect(find.text(message), findsOneWidget);
          expect(find.byType(Image), findsWidgets);
        });
      });

      group('and pressing on camera', () {
        testWidgets('should send photo and return to chat screen',
            (tester) async {
          final l10n = await getL10n();
          const message = 'Check out this photo!';
          ChatSDKTestWrapper? wrapper;

          await navigateToChatScreen(
            tester,
            contactId: contactId,
            imagePicker: FakeImagePicker.withDefaultImage(),
            mockCameras: _mockCameras,
            chatSdkWrapper: (realSdk) => wrapper = ChatSDKTestWrapper(realSdk),
          );

          await tester.tap(findAddMediaButton());
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.generalCamera));
          await tester.pumpAndSettle();

          final captureButton = find.byKey(const Key('camera_capture_button'));
          expect(captureButton, findsOneWidget);
          await tester.pumpAndSettle();

          await tester.tap(captureButton);
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('media_review_submit_button')),
              findsOneWidget);

          await submitMediaWithMessage(tester, message);

          expect(wrapper!.sendTextMessageCalls, hasLength(1));
          final sendCall = wrapper!.sendTextMessageCalls.first;
          expect(sendCall['text'], message);
          expect(sendCall['attachments'], isA<List<Attachment>>());
          expect((sendCall['attachments'] as List).length, 1);

          expect(find.text(contactName), findsOneWidget);
          expect(find.text(message), findsOneWidget);
          expect(find.byType(Image), findsWidgets);
        });
      });
    });
  });
}
