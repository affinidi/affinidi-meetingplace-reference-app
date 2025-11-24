import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

import 'fakes/fake_camera_service.dart';
import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_image_picker.dart';
import 'utils/app.dart';

/// Helper function to navigate to chat screen
Future<void> navigateToChatScreen(
  WidgetTester tester, {
  required String contactId,
  bool isAuthenticated = true,
  bool alreadyOnboarded = true,
  MeetingPlaceChatSDK? chatSdk,
  ChatSDKWrapper? chatSdkWrapper,
  ImagePicker? imagePicker,
  FakeCameraService? cameraService,
}) async {
  final location = '/contacts/$contactId/chat';

  await tester.runAsync(() async {
    await navigateToLocation(
      tester,
      location,
      isAuthenticated: isAuthenticated,
      alreadyOnboarded: alreadyOnboarded,
      identities: [FakeIdentities.primaryIdentity],
      contacts: [FakeContacts.individualContact],
      meetingPlaceChatSDK: chatSdk,
      chatSdkWrapper: chatSdkWrapper,
      imagePicker: imagePicker,
      cameraService: cameraService,
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
        const incomingMessage = 'Hello from the other side!';
        final channel = FakeChannels.individualChannel;

        ChatSDKTestWrapper? wrapperInstance;

        await navigateToChatScreen(
          tester,
          contactId: contactId,
          chatSdkWrapper: (realSdk) {
            wrapperInstance = ChatSDKTestWrapper(realSdk);
            return wrapperInstance!;
          },
        );
        await tester.pumpAndSettle();

        await tester.runAsync(() async {
          wrapperInstance!.simulateIncomingTextMessage(
            text: incomingMessage,
            senderDid: channel.otherPartyPermanentChannelDid!,
            recipientDid: channel.permanentChannelDid!,
          );
          await Future<void>.delayed(const Duration(milliseconds: 500));
        });

        await tester.pumpAndSettle();

        expect(find.text(incomingMessage), findsOneWidget);
      });

      group('and user long press on the received message', () {
        testWidgets('should let user react to the message', (tester) async {
          const incomingMessage = 'Test message for reactions';
          final channel = FakeChannels.individualChannel;

          ChatSDKTestWrapper? wrapperInstance;

          await navigateToChatScreen(
            tester,
            contactId: contactId,
            chatSdkWrapper: (realSdk) {
              wrapperInstance = ChatSDKTestWrapper(realSdk);
              return wrapperInstance!;
            },
          );
          await tester.pumpAndSettle();

          await tester.runAsync(() async {
            wrapperInstance!.simulateIncomingTextMessage(
              text: incomingMessage,
              senderDid: channel.otherPartyPermanentChannelDid!,
              recipientDid: channel.permanentChannelDid!,
            );
            await Future<void>.delayed(const Duration(milliseconds: 500));
          });
          await tester.pumpAndSettle();

          expect(find.text(incomingMessage), findsOneWidget);

          await tester.longPress(find.text(incomingMessage));
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

      group('and pressing on balloons', () {
        testWidgets('should call sendEffect with balloons effect',
            (tester) async {
          final l10n = await getL10n();
          ChatSDKTestWrapper? wrapperInstance;

          await navigateToChatScreen(
            tester,
            contactId: contactId,
            chatSdkWrapper: (realSdk) {
              wrapperInstance = ChatSDKTestWrapper(realSdk);
              return wrapperInstance!;
            },
          );

          final addMediaButton = findAddMediaButton();
          await tester.tap(addMediaButton);
          await tester.pumpAndSettle();

          expect(find.text(l10n.generalBalloons), findsOneWidget);

          await tester.tap(find.text(l10n.generalBalloons));
          await tester.pumpAndSettle();

          expect(wrapperInstance!.sendEffectCalls, hasLength(1));
          final sendEffectCall = wrapperInstance!.sendEffectCalls.first;
          expect(sendEffectCall['effect'], Effect.balloons);
        });
      });

      group('and pressing on confetti', () {
        testWidgets('should call sendEffect with confetti effect',
            (tester) async {
          final l10n = await getL10n();
          ChatSDKTestWrapper? wrapperInstance;

          await navigateToChatScreen(
            tester,
            contactId: contactId,
            chatSdkWrapper: (realSdk) {
              wrapperInstance = ChatSDKTestWrapper(realSdk);
              return wrapperInstance!;
            },
          );

          final addMediaButton = findAddMediaButton();
          await tester.tap(addMediaButton);
          await tester.pumpAndSettle();

          expect(find.text(l10n.generalConfetti), findsOneWidget);

          await tester.tap(find.text(l10n.generalConfetti));
          await tester.pumpAndSettle();

          expect(wrapperInstance!.sendEffectCalls, hasLength(1));
          final sendEffectCall = wrapperInstance!.sendEffectCalls.first;
          expect(sendEffectCall['effect'], Effect.confetti);
        });
      });

      group('and pressing on photo', () {
        testWidgets('should send photo and return to chat screen',
            (tester) async {
          final l10n = await getL10n();
          final fakeImagePicker = FakeImagePicker.withDefaultImage();
          ChatSDKTestWrapper? wrapperInstance;

          await navigateToChatScreen(
            tester,
            contactId: contactId,
            imagePicker: fakeImagePicker,
            chatSdkWrapper: (realSdk) {
              wrapperInstance = ChatSDKTestWrapper(realSdk);
              return wrapperInstance!;
            },
          );

          final addMediaButton = findAddMediaButton();
          await tester.tap(addMediaButton);
          await tester.pumpAndSettle();

          expect(find.text(l10n.generalPhoto), findsOneWidget);

          await tester.tap(find.text(l10n.generalPhoto));
          await tester.pumpAndSettle();

          final submitButton =
              find.byKey(const Key('media_review_submit_button'));
          expect(submitButton, findsOneWidget);
          expect(find.byIcon(Icons.cancel_sharp), findsOneWidget);

          const photoMessage = 'Check out this photo!';
          final textInput = find.byKey(const Key('media_review_text_input'));
          expect(textInput, findsOneWidget);
          await tester.enterText(textInput, photoMessage);
          await tester.pump();

          await tester.runAsync(() async {
            await tester.tap(submitButton);
            await tester.pump();
          });

          await tester.pumpAndSettle();

          expect(wrapperInstance!.sendTextMessageCalls, hasLength(1));
          final sendCall = wrapperInstance!.sendTextMessageCalls.first;
          expect(sendCall['text'], photoMessage);
          expect(sendCall['attachments'], isNotNull);
          expect(sendCall['attachments'], isA<List<Attachment>>());
          expect(sendCall['attachments'] as List<Attachment>, hasLength(1));

          expect(find.text(contactName), findsOneWidget);
          expect(find.text(photoMessage), findsOneWidget);
          expect(find.byType(Image), findsWidgets);
        });
      });

      group('and pressing on camera', () {
        testWidgets('should send photo and return to chat screen',
            (tester) async {
          final l10n = await getL10n();
          final fakeImagePicker = FakeImagePicker.withDefaultImage();

          final fakeCameraService = FakeCameraService(
            isAvailable: true,
            mockImageBytes: FakeImagePicker.defaultImageBytes,
          );
          ChatSDKTestWrapper? wrapperInstance;

          await navigateToChatScreen(
            tester,
            contactId: contactId,
            imagePicker: fakeImagePicker,
            cameraService: fakeCameraService,
            chatSdkWrapper: (realSdk) {
              wrapperInstance = ChatSDKTestWrapper(realSdk);
              return wrapperInstance!;
            },
          );

          final addMediaButton = findAddMediaButton();
          await tester.tap(addMediaButton);
          await tester.pumpAndSettle();

          expect(find.text(l10n.generalCamera), findsOneWidget);

          await tester.tap(find.text(l10n.generalCamera));
          await tester.pump();

          expect(fakeCameraService.state.isAvailable, isTrue);

          await tester.pump(const Duration(seconds: 2));
          final captureButton = find.byKey(const Key('camera_capture_button'));
          expect(captureButton, findsOneWidget);
          await tester.pump(const Duration(seconds: 2));

          await tester.runAsync(() async {
            await tester.tap(captureButton);
            await tester.pump();
          });

          await tester.pumpAndSettle();

          final submitButton =
              find.byKey(const Key('media_review_submit_button'));
          expect(submitButton, findsOneWidget);

          const cameraMessage = 'Check out this photo!';
          final textInput = find.byKey(const Key('media_review_text_input'));
          expect(textInput, findsOneWidget);
          await tester.enterText(textInput, cameraMessage);
          await tester.pump();

          await tester.runAsync(() async {
            await tester.tap(submitButton);
            await tester.pump();
          });

          await tester.pumpAndSettle();

          expect(wrapperInstance!.sendTextMessageCalls, hasLength(1));
          final sendCall = wrapperInstance!.sendTextMessageCalls.first;
          expect(sendCall['text'], cameraMessage);
          expect(sendCall['attachments'], isNotNull);
          expect(sendCall['attachments'], isA<List<Attachment>>());
          expect(sendCall['attachments'] as List<Attachment>, hasLength(1));

          expect(find.text(contactName), findsOneWidget);
          expect(find.text(cameraMessage), findsOneWidget);
          expect(find.byType(Image), findsWidgets);
        });
      });
    });
  });
}
