import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:permission_handler/permission_handler.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_image_picker.dart';
import 'fakes/fake_secure_storage.dart';
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
  MeetingPlaceChatSDK? meetingPlaceChatSDK,
  ImagePicker? imagePicker,
  List<CameraDescription>? mockCameras,
  FakeSecureStorage? secureStorage,
  PermissionStatus? cameraPermissionStatus,
}) async {
  await navigateToLocation(
    tester,
    '/contacts/$contactId/chat',
    isAuthenticated: true,
    alreadyOnboarded: true,
    identities: [FakeIdentities.primaryIdentity],
    contacts: [FakeContacts.individualContact],
    meetingPlaceChatSDK: meetingPlaceChatSDK,
    imagePicker: imagePicker,
    mockCameras: mockCameras,
    secureStorage: secureStorage,
    cameraPermissionStatus: cameraPermissionStatus,
  );
  await tester.pumpAndSettle();
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
}

Future<void> simulateIncomingMessage(
  WidgetTester tester,
  FakeChatSdk meetingPlaceChatSDK,
  String message,
) async {
  meetingPlaceChatSDK.simulateIncomingTextMessage(
    text: message,
    recipientDid: FakeChannels.individualChannel.permanentChannelDid!,
  );
  await tester.pumpAndSettle();
}

Future<void> submitMediaWithMessage(
  WidgetTester tester,
  String message,
) async {
  final textInput = find.byKey(const Key('media_review_text_input'));
  await tester.enterText(textInput, message);
  await tester.pumpAndSettle();

  await tester.tap(find.byKey(const Key('media_review_submit_button')));
  await tester.pumpAndSettle();
}

Future<void> verifyMessageWithAttachmentSent(
  WidgetTester tester,
  FakeChatSdk meetingPlaceChatSDK,
  String message,
  String contactName,
) async {
  expect(meetingPlaceChatSDK.sendTextMessageCalls, hasLength(1));
  final sendCall = meetingPlaceChatSDK.sendTextMessageCalls.first;
  expect(sendCall['text'], message);
  expect(sendCall['attachments'], isA<List<Attachment>>());
  expect((sendCall['attachments'] as List).length, 1);

  final attachments = sendCall['attachments'] as List<Attachment>;
  meetingPlaceChatSDK.simulateIncomingTextMessage(
    text: message,
    recipientDid: FakeChannels.individualChannel.permanentChannelDid!,
    attachments: attachments,
  );
  await tester.pumpAndSettle();

  expect(find.text(contactName), findsOneWidget);
  expect(find.text(message), findsOneWidget);
  expect(find.byType(Image), findsWidgets);
}

void main() {
  group('When opening an individual chat', () {
    final contactId = FakeContacts.individualContact.id;
    final contact = FakeContacts.individualContact;
    final contactName = contact.displayName ?? 'Contact';
    final meetingPlaceChatSDK = FakeChatSdk();

    testWidgets('it shows the chat screen with correct title', (tester) async {
      await navigateToChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );

      expect(find.text(contactName), findsOneWidget);
    });

    testWidgets('it shows the message input field', (tester) async {
      await navigateToChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );

      final inputField = findChatMessageInput();
      expect(inputField, findsOneWidget);

      final textField = tester.widget<TextFormField>(inputField);
      expect(textField.enabled, isNot(false));
    });

    testWidgets('it shows the send button', (tester) async {
      await navigateToChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );

      final sendButton = findSendButton();
      expect(sendButton, findsOneWidget);
    });

    testWidgets('it shows the add media button', (tester) async {
      await navigateToChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );
      final addButton = findAddMediaButton();
      expect(addButton, findsOneWidget);
    });

    testWidgets('it shows the encryption notice', (tester) async {
      final l10n = await getL10n();

      await navigateToChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );
      expect(find.text(l10n.chatEncryptionNotice), findsOneWidget);
    });

    testWidgets('it allows typing in the message input', (tester) async {
      await navigateToChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );
      const testMessage = 'Hello, this is a test message!';

      await enterChatMessage(tester, testMessage);

      final inputField = findChatMessageInput();
      final textField = tester.widget<TextFormField>(inputField);
      expect(textField.controller?.text, testMessage);
    });

    testWidgets('it shows contact presence status', (tester) async {
      await navigateToChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );
      expect(find.text(contactName), findsOneWidget);
    });

    group('and there is an unsent message', () {
      testWidgets('it shows the unsent message in the text field',
          (tester) async {
        const unsentMessage = 'Draft message';
        final secureStorage = FakeSecureStorage();
        await secureStorage.saveUnsentMessages({contactId: unsentMessage});

        await navigateToChatScreen(
          tester,
          contactId: contactId,
          meetingPlaceChatSDK: meetingPlaceChatSDK,
          secureStorage: secureStorage,
        );

        final inputField = findChatMessageInput();
        final textField = tester.widget<TextFormField>(inputField);
        expect(textField.controller?.text, unsentMessage);
      });
    });

    group('and contact has an avatar', () {
      testWidgets('it shows the contact avatar', (tester) async {
        await navigateToChatScreen(
          tester,
          contactId: contactId,
          meetingPlaceChatSDK: meetingPlaceChatSDK,
        );
        final contactAvatarKey = const Key('chat_contact_avatar');
        expect(find.byKey(contactAvatarKey), findsOneWidget);
      });
    });

    group('and entering a message', () {
      testWidgets('it has the send button available', (tester) async {
        await navigateToChatScreen(
          tester,
          contactId: contactId,
          meetingPlaceChatSDK: meetingPlaceChatSDK,
        );
        const testMessage = 'Test message';

        await enterChatMessage(tester, testMessage);

        final sendButton = findSendButton();
        expect(sendButton, findsOneWidget);
      });
    });

    group('and message list is empty', () {
      testWidgets('it shows only the encryption notice', (tester) async {
        final l10n = await getL10n();

        await navigateToChatScreen(
          tester,
          contactId: contactId,
          meetingPlaceChatSDK: meetingPlaceChatSDK,
        );
        expect(find.text(l10n.chatEncryptionNotice), findsOneWidget);
      });
    });

    group('and sending a message', () {
      final meetingPlaceChatSDK = FakeChatSdk();

      testWidgets('it appears on the screen', (tester) async {
        await navigateToChatScreen(
          tester,
          contactId: contactId,
          meetingPlaceChatSDK: meetingPlaceChatSDK,
        );
        const testMessage = 'Hello, this is my test message!';

        await enterChatMessage(tester, testMessage);
        await tapSendButton(tester);
        await tester.pumpAndSettle();

        expect(meetingPlaceChatSDK.sendTextMessageCalls, hasLength(1));
        final sendCall = meetingPlaceChatSDK.sendTextMessageCalls.first;
        expect(sendCall['text'], testMessage);
        expect(sendCall['attachments'], isNull);

        // Simulate the message appearing in the UI
        meetingPlaceChatSDK.simulateIncomingTextMessage(
          text: testMessage,
          recipientDid: FakeChannels.individualChannel.permanentChannelDid!,
        );
        await tester.pumpAndSettle();

        expect(find.text(testMessage), findsOneWidget);
      });

      testWidgets('the input field is cleared after sending', (tester) async {
        await navigateToChatScreen(
          tester,
          contactId: contactId,
          meetingPlaceChatSDK: meetingPlaceChatSDK,
        );
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
      final meetingPlaceChatSDK = FakeChatSdk();
      const message = 'Hello from the other side!';

      testWidgets('an incoming message appears on the screen', (tester) async {
        await navigateToChatScreen(
          tester,
          contactId: contactId,
          meetingPlaceChatSDK: meetingPlaceChatSDK,
        );

        await simulateIncomingMessage(tester, meetingPlaceChatSDK, message);
        expect(find.text(message), findsOneWidget);
      });

      group('and user long press on the received message', () {
        testWidgets('should let user react to the message', (tester) async {
          await navigateToChatScreen(
            tester,
            contactId: contactId,
            meetingPlaceChatSDK: meetingPlaceChatSDK,
          );

          await simulateIncomingMessage(tester, meetingPlaceChatSDK, message);

          await tester.longPress(find.text(message));
          await tester.pumpAndSettle();

          expect(find.text('👍'), findsWidgets);
          expect(find.text('👎'), findsWidgets);

          expect(find.text(message), findsOneWidget);

          await tester.tap(find.text('👍').first);
          await tester.pumpAndSettle();

          expect(meetingPlaceChatSDK.reactOnMessageCalls, hasLength(1));
          final reactionCall = meetingPlaceChatSDK.reactOnMessageCalls.first;
          expect(reactionCall['reaction'], '👍');
          expect(reactionCall['message'], isA<Message>());
        });
      });
    });

    group('and clicking the add media button', () {
      testWidgets('should show a menu with media and effects options',
          (tester) async {
        final l10n = await getL10n();

        await navigateToChatScreen(
          tester,
          contactId: contactId,
          meetingPlaceChatSDK: meetingPlaceChatSDK,
        );
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
            final meetingPlaceChatSDK = FakeChatSdk();

            await navigateToChatScreen(
              tester,
              contactId: contactId,
              meetingPlaceChatSDK: meetingPlaceChatSDK,
            );

            await tester.tap(findAddMediaButton());
            await tester.pumpAndSettle();

            await tester.tap(find.text(effectLabel));
            await tester.pumpAndSettle();

            expect(meetingPlaceChatSDK.sendEffectCalls, hasLength(1));
            expect(meetingPlaceChatSDK.sendEffectCalls.first['effect'], effect);
          });
        });
      }

      group('and pressing on photo', () {
        testWidgets('should send photo and return to chat screen',
            (tester) async {
          final l10n = await getL10n();
          const message = 'Check out this photo!';
          final meetingPlaceChatSDK = FakeChatSdk();

          await navigateToChatScreen(
            tester,
            contactId: contactId,
            imagePicker: FakeImagePicker.withDefaultImage(),
            meetingPlaceChatSDK: meetingPlaceChatSDK,
          );

          await tester.tap(findAddMediaButton());
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.generalPhoto));
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('media_review_submit_button')),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.cancel_sharp), findsOneWidget);

          await submitMediaWithMessage(tester, message);
          await tester.pumpAndSettle();

          await verifyMessageWithAttachmentSent(
            tester,
            meetingPlaceChatSDK,
            message,
            contactName,
          );
        });
      });

      group('and pressing on camera', () {
        testWidgets('should send photo and return to chat screen',
            (tester) async {
          final l10n = await getL10n();
          const message = 'Check out this photo!';
          final meetingPlaceChatSDK = FakeChatSdk();

          await navigateToChatScreen(
            tester,
            contactId: contactId,
            imagePicker: FakeImagePicker.withDefaultImage(),
            mockCameras: _mockCameras,
            meetingPlaceChatSDK: meetingPlaceChatSDK,
            cameraPermissionStatus: PermissionStatus.granted,
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

          expect(
            find.byKey(const Key('media_review_submit_button')),
            findsOneWidget,
          );

          await submitMediaWithMessage(tester, message);
          await tester.pumpAndSettle();

          await verifyMessageWithAttachmentSent(
            tester,
            meetingPlaceChatSDK,
            message,
            contactName,
          );
        });

        testWidgets('should show error when camera permission is denied',
            (tester) async {
          final l10n = await getL10n();
          final meetingPlaceChatSDK = FakeChatSdk();

          await navigateToChatScreen(
            tester,
            contactId: contactId,
            imagePicker: FakeImagePicker.withDefaultImage(),
            mockCameras: _mockCameras,
            meetingPlaceChatSDK: meetingPlaceChatSDK,
            cameraPermissionStatus: PermissionStatus.denied,
          );

          await tester.tap(findAddMediaButton());
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.generalCamera));
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('camera_capture_button')),
            findsNothing,
          );
          expect(
            find.text(l10n.cameraAccessDenied),
            findsOneWidget,
          );
          expect(
            find.text(l10n.cameraOpenSettings),
            findsOneWidget,
          );
          expect(find.text(l10n.generalRetry), findsOneWidget);
        });
      });
    });
  });
}
