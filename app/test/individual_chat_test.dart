import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:permission_handler/permission_handler.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_connectivity.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_image_picker.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'fakes/fake_secure_storage.dart';
import 'utils/app.dart';

Finder findChatMessageInput() => find.byKey(const Key('chat_message_input'));
Finder findSendButton() => find.byKey(const Key('chat_send_button'));
Finder findAddMediaButton() => find.byKey(const Key('chat_add_media_button'));
Finder findGifButton() => find.byKey(const Key('chat_gif_button'));

const _lateIncomingCallRetryInterval = Duration(milliseconds: 250);
const _lateIncomingCallRetryCount = 8;

Future<void> enterChatMessage(WidgetTester tester, String message) async {
  await tester.enterText(findChatMessageInput(), message);
  await tester.pumpAndSettle();
}

Future<void> tapSendButton(WidgetTester tester) async {
  await tester.tap(findSendButton());
}

Future<void> pumpMentionDebounce(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pumpAndSettle();
}

Future<void> simulateIncomingMessage(
  WidgetTester tester,
  FakeChatSdk chatSdk,
  String message,
) async {
  chatSdk.simulateIncomingTextMessage(
    text: message,
    recipientDid: FakeChannels.individualChannel.permanentChannelDid!,
  );
  await tester.pumpAndSettle();
}

Future<void> submitMediaWithMessage(WidgetTester tester, String message) async {
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
  expect(sendCall['attachments'], isA<List<ChatAttachment>>());
  expect((sendCall['attachments'] as List).length, 1);

  final attachments = sendCall['attachments'] as List<ChatAttachment>;
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
    final chatSdk = FakeChatSdk();

    testWidgets('it shows the chat screen with correct title', (tester) async {
      await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);

      expect(find.text(contactName), findsOneWidget);
    });

    testWidgets('it shows the message input field', (tester) async {
      await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);

      final inputField = findChatMessageInput();
      expect(inputField, findsOneWidget);

      final textField = tester.widget<TextFormField>(inputField);
      expect(textField.enabled, isNot(false));
    });

    testWidgets('it shows the send button', (tester) async {
      await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);

      final sendButton = findSendButton();
      expect(sendButton, findsOneWidget);
    });

    testWidgets('it shows the add media button', (tester) async {
      await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);

      final addButton = findAddMediaButton();
      expect(addButton, findsOneWidget);
    });

    testWidgets('it shows the encryption notice', (tester) async {
      final l10n = await getL10n();

      await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
      expect(find.text(l10n.chatEncryptionNotice), findsOneWidget);
    });

    testWidgets('it allows typing in the message input', (tester) async {
      await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
      const testMessage = 'Hello, this is a test message!';

      await enterChatMessage(tester, testMessage);

      final inputField = findChatMessageInput();
      final textField = tester.widget<TextFormField>(inputField);
      expect(textField.controller?.text, testMessage);
    });

    testWidgets('it shows contact presence status', (tester) async {
      await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
      expect(find.text(contactName), findsOneWidget);
    });

    testWidgets('exiting chat with a pending session update does not throw', (
      tester,
    ) async {
      await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);

      chatSdk.simulateIncomingTextMessage(
        text: 'Pending update while exiting',
        recipientDid: FakeChannels.individualChannel.permanentChannelDid!,
      );

      final context = tester.element(findChatMessageInput());
      Navigator.of(context).pop();

      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(findChatMessageInput(), findsNothing);
    });

    group('and there is an unsent message', () {
      testWidgets('it shows the unsent message in the text field', (
        tester,
      ) async {
        const unsentMessage = 'Draft message';
        final secureStorage = FakeSecureStorage();
        await secureStorage.saveUnsentMessages({contactId: unsentMessage});

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          secureStorage: secureStorage,
        );

        final inputField = findChatMessageInput();
        final textField = tester.widget<TextFormField>(inputField);
        expect(textField.controller?.text, unsentMessage);
      });
    });

    group('and contact has an avatar', () {
      testWidgets('it shows the contact avatar', (tester) async {
        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
        final contactAvatarKey = const Key('chat_contact_avatar');
        expect(find.byKey(contactAvatarKey), findsOneWidget);
      });
    });

    group('and entering a message', () {
      testWidgets('it has the send button available', (tester) async {
        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
        const testMessage = 'Test message';

        await enterChatMessage(tester, testMessage);

        final sendButton = findSendButton();
        expect(sendButton, findsOneWidget);
      });

      testWidgets('it does not show mention suggestions', (tester) async {
        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);

        await enterChatMessage(tester, '@Bo');
        await pumpMentionDebounce(tester);

        expect(find.byKey(const Key('chat_mention_suggestions')), findsNothing);
      });
    });

    group('and message list is empty', () {
      testWidgets('it shows only the encryption notice', (tester) async {
        final l10n = await getL10n();

        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
        expect(find.text(l10n.chatEncryptionNotice), findsOneWidget);
      });
    });

    group('and there is an incoming call', () {
      late FakeMeetingPlaceSDK coreSdk;
      late FakeChatSdk chatSdk;

      setUp(() {
        coreSdk = FakeMeetingPlaceSDK(channels: FakeChannels.allChannels);
        chatSdk = FakeChatSdk()..sessionMessages = [];
      });

      group('and the call chat item is not yet available', () {
        group('and the caller cancels it', () {
          testWidgets('it shows the call as missed when reopening chat', (
            tester,
          ) async {
            final l10n = await getL10n();
            final staleCallItemTime = DateTime.now().subtract(
              const Duration(seconds: 1),
            );

            await navigateToChat(
              tester,
              contactId: contactId,
              chatSdk: chatSdk,
              meetingPlaceCoreSDK: coreSdk,
            );

            // Receive incoming call event, but the call
            // chat item is not yet available
            coreSdk.emitIncomingCall(
              IncomingAudioVideoCallEvent(
                callId: 'call-1',
                callerPermanentChannelDid:
                    FakeChannels.individualChannel.permanentChannelDid!,
                otherPartyPermanentChannelDid:
                    FakeChannels.individualChannel.permanentChannelDid!,
                invitedAt: DateTime.utc(2026),
                mediaType: CallMediaType.video,
              ),
            );
            await tester.pump();

            // Simulate the caller cancelling the call before
            // the call chat item is available
            coreSdk.emitCancelledCall(
              IncomingAudioVideoCallEvent(
                callId: 'call-1',
                callerPermanentChannelDid:
                    FakeChannels.individualChannel.permanentChannelDid!,
                otherPartyPermanentChannelDid:
                    FakeChannels.individualChannel.permanentChannelDid!,
                invitedAt: DateTime.utc(2026),
                mediaType: CallMediaType.video,
              ),
            );
            await tester.pump();

            // Simulate the call chat item being available after
            // the caller has cancelled
            chatSdk.setIncomingCallSessionMessage(
              senderDid: FakeChannels.individualChannel.permanentChannelDid!,
              dateCreated: staleCallItemTime,
            );

            // Advance through six 50ms retry intervals so the delayed
            // missed-call reconciliation has enough fake time to complete.
            await tester.pump(
              _lateIncomingCallRetryInterval * _lateIncomingCallRetryCount,
            );
            await tester.pumpAndSettle();

            expect(chatSdk.updateMessageCalls, hasLength(1));
            final updatedMessage = chatSdk.updateMessageCalls.single;
            final updatedCall = CallMetadata.maybeOf(
              updatedMessage.attachments.first,
            );
            expect(updatedCall?.status, CallStatus.missed);

            await pushRoute(tester, '/contacts');
            await pushRoute(tester, '/contacts/$contactId/chat');

            expect(find.text(l10n.callChatItemMissed), findsOneWidget);
          });
        });
      });
    });

    group('and sending a message', () {
      final chatSdk = FakeChatSdk();

      testWidgets('it appears on the screen', (tester) async {
        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
        const testMessage = 'Hello, this is my test message!';

        await enterChatMessage(tester, testMessage);
        await tapSendButton(tester);
        await tester.pumpAndSettle();

        expect(chatSdk.sendTextMessageCalls, hasLength(1));
        final sendCall = chatSdk.sendTextMessageCalls.first;
        expect(sendCall['text'], testMessage);
        expect(sendCall['attachments'], isA<List<ChatAttachment>>());
        expect(sendCall['attachments'], isNotEmpty);

        // Simulate the message appearing in the UI
        chatSdk.simulateIncomingTextMessage(
          text: testMessage,
          recipientDid: FakeChannels.individualChannel.permanentChannelDid!,
        );
        await tester.pumpAndSettle();

        expect(find.text(testMessage), findsOneWidget);
      });

      testWidgets('the input field is cleared after sending', (tester) async {
        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
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
      final chatSdk = FakeChatSdk();
      const message = 'Hello from the other side!';

      testWidgets('an incoming message appears on the screen', (tester) async {
        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);

        await simulateIncomingMessage(tester, chatSdk, message);
        expect(find.text(message), findsOneWidget);
      });

      group('and user long press on the received message', () {
        testWidgets('should let user react to the message', (tester) async {
          await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);

          await simulateIncomingMessage(tester, chatSdk, message);

          await tester.longPress(find.text(message));
          await tester.pumpAndSettle();

          expect(find.text('👍'), findsWidgets);
          expect(find.text('👎'), findsWidgets);

          expect(find.text(message), findsOneWidget);

          await tester.tap(find.text('👍').first);
          await tester.pumpAndSettle();

          expect(chatSdk.reactOnMessageCalls, hasLength(1));
          final reactionCall = chatSdk.reactOnMessageCalls.first;
          expect(reactionCall['reaction'], '👍');
          expect(reactionCall['message'], isA<Message>());
        });
      });
    });

    group('and clicking the add media button', () {
      testWidgets('should show a menu with media options', (tester) async {
        final l10n = await getL10n();

        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
        final addMediaButton = findAddMediaButton();
        expect(addMediaButton, findsOneWidget);

        await tester.tap(addMediaButton);
        await tester.pumpAndSettle();

        expect(find.text(l10n.generalCamera), findsOneWidget);
        expect(find.text(l10n.generalPhoto), findsOneWidget);
        expect(find.text(l10n.generalDocument), findsOneWidget);
        expect(find.text(l10n.generalVideo), findsNothing);
        expect(find.text(l10n.generalBalloons), findsNothing);
        expect(find.text(l10n.generalConfetti), findsNothing);
      });

      testWidgets('hides the document option when the transport does not '
          'support document attachments', (tester) async {
        final l10n = await getL10n();
        final didcommChatSdk = FakeChatSdk(
          capabilities: const TransportCapabilities({
            ChatFeature.textMessaging,
            ChatFeature.imageAttachments,
            ChatFeature.videoAttachments,
            ChatFeature.reactions,
          }),
        );

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: didcommChatSdk,
        );

        await tester.tap(findAddMediaButton());
        await tester.pumpAndSettle();

        expect(find.text(l10n.generalPhoto), findsOneWidget);
        expect(find.text(l10n.generalDocument), findsNothing);
      });

      for (final effect in [Effect.balloons, Effect.confetti]) {
        group('and pressing on ${effect.name}', () {
          testWidgets('should call sendEffect with ${effect.name} effect', (
            tester,
          ) async {
            final l10n = await getL10n();
            final effectLabel = effect == Effect.balloons
                ? l10n.generalBalloons
                : l10n.generalConfetti;
            final meetingPlaceChatSDK = FakeChatSdk();

            await navigateToChat(
              tester,
              contactId: contactId,
              chatSdk: meetingPlaceChatSDK,
            );

            await tester.tap(findGifButton());
            await tester.pumpAndSettle();

            await tester.tap(find.text(effectLabel));
            await tester.pumpAndSettle();

            expect(meetingPlaceChatSDK.sendEffectCalls, hasLength(1));
            expect(meetingPlaceChatSDK.sendEffectCalls.first['effect'], effect);
          });
        });
      }

      group('and pressing on photo', () {
        testWidgets('should send photo and return to chat screen', (
          tester,
        ) async {
          final l10n = await getL10n();
          const message = 'Check out this photo!';
          final meetingPlaceChatSDK = FakeChatSdk();

          await navigateToChat(
            tester,
            contactId: contactId,
            imagePicker: FakeImagePicker.withDefaultImage(),
            chatSdk: meetingPlaceChatSDK,
          );

          await tester.tap(findAddMediaButton());
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.generalPhoto));
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('media_review_submit_button')),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.close), findsOneWidget);

          await submitMediaWithMessage(tester, message);
          await tester.pumpAndSettle();

          await verifyMessageWithAttachmentSent(
            tester,
            meetingPlaceChatSDK,
            message,
            contactName,
          );
        });

        testWidgets('should send video selected from image picker', (
          tester,
        ) async {
          final l10n = await getL10n();
          final meetingPlaceChatSDK = FakeChatSdk();

          await navigateToChat(
            tester,
            contactId: contactId,
            imagePicker: FakeImagePicker(
              xFileToReturn: XFile.fromData(
                FakeImagePicker.defaultImageBytes,
                name: 'clip.mp4',
                mimeType: 'video/mp4',
              ),
            ),
            chatSdk: meetingPlaceChatSDK,
          );

          await tester.tap(findAddMediaButton());
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.generalPhoto));
          await tester.pumpAndSettle();

          expect(meetingPlaceChatSDK.sendMediaMessageCalls, hasLength(1));
          final sendCall = meetingPlaceChatSDK.sendMediaMessageCalls.first;
          expect(sendCall['contentType'], startsWith('video/'));
          expect(sendCall['filename'], 'video.mp4');
        });
      });

      group('and pressing on camera', () {
        const mockCameras = [
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

        testWidgets('should send photo and return to chat screen', (
          tester,
        ) async {
          final l10n = await getL10n();
          const message = 'Check out this photo!';
          final meetingPlaceChatSDK = FakeChatSdk();

          await navigateToChat(
            tester,
            contactId: contactId,
            imagePicker: FakeImagePicker.withDefaultImage(),
            cameras: mockCameras,
            chatSdk: meetingPlaceChatSDK,
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

        testWidgets('should show error when camera permission is denied', (
          tester,
        ) async {
          final l10n = await getL10n();
          final meetingPlaceChatSDK = FakeChatSdk();

          await navigateToChat(
            tester,
            contactId: contactId,
            imagePicker: FakeImagePicker.withDefaultImage(),
            cameras: mockCameras,
            chatSdk: meetingPlaceChatSDK,
            cameraPermissionStatus: PermissionStatus.denied,
          );

          await tester.tap(findAddMediaButton());
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.generalCamera));
          await tester.pumpAndSettle();

          expect(find.byKey(const Key('camera_capture_button')), findsNothing);
          expect(find.text(l10n.cameraAccessDenied), findsOneWidget);
          expect(find.text(l10n.cameraOpenSettings), findsOneWidget);
          expect(find.text(l10n.generalRetry), findsOneWidget);
        });
      });
    });

    group('and network connectivity changes from offline to online', () {
      testWidgets('should start chat presence updates', (tester) async {
        final meetingPlaceChatSDK = FakeChatSdk();
        final fakeConnectivity = FakeConnectivity(
          initialConnectivityToReturn: [ConnectivityResult.none],
        );

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: meetingPlaceChatSDK,
          cameraPermissionStatus: PermissionStatus.granted,
          connectivity: fakeConnectivity,
        );

        expect(meetingPlaceChatSDK.startedChatPresenceUpdatesCount, 0);

        fakeConnectivity.emitConnectivityChange([ConnectivityResult.wifi]);
        await tester.pumpAndSettle();

        expect(meetingPlaceChatSDK.startedChatPresenceUpdatesCount, 1);
      });
    });

    group('and contact is an OOB contact', () {
      testWidgets('it should show notification unavailable banner', (
        tester,
      ) async {
        final l10n = await getL10n();
        final oobChatSDK = FakeChatSdk();

        await navigateToChat(
          tester,
          contactId: FakeContacts.oobContact.id,
          isAuthenticated: true,
          alreadyOnboarded: true,
          identities: [FakeIdentities.primaryIdentity],
          contacts: [FakeContacts.oobContact],
          chatSdk: oobChatSDK,
        );

        expect(
          find.byKey(const Key('notifications_unavailable_banner')),
          findsOneWidget,
        );

        expect(find.byIcon(Icons.notifications_off_outlined), findsWidgets);

        expect(find.byKey(const Key('notifications_why_link')), findsOneWidget);

        await tester.tap(find.byKey(const Key('notifications_why_link')));
        await tester.pumpAndSettle();

        expect(find.text(l10n.chatNotificationsWhyTitle), findsOneWidget);
        expect(find.text(l10n.chatNotificationsWhyDescription), findsOneWidget);
        expect(find.text(l10n.chatNotificationsWhyButton), findsOneWidget);

        await tester.tap(find.text(l10n.chatNotificationsWhyButton));
        await tester.pumpAndSettle();

        expect(find.text(l10n.chatNotificationsWhyTitle), findsNothing);
      });

      group('and press dismiss button', () {
        testWidgets('it should dismiss the banner', (tester) async {
          final oobChatSDK = FakeChatSdk();

          await navigateToChat(
            tester,
            contactId: FakeContacts.oobContact.id,
            isAuthenticated: true,
            alreadyOnboarded: true,
            identities: [FakeIdentities.primaryIdentity],
            contacts: [FakeContacts.oobContact],
            chatSdk: oobChatSDK,
          );

          expect(
            find.byKey(const Key('notifications_unavailable_banner')),
            findsOneWidget,
          );

          final closeButton = find.descendant(
            of: find.byKey(const Key('notifications_unavailable_banner')),
            matching: find.byIcon(Icons.close),
          );
          expect(closeButton, findsOneWidget);

          await tester.tap(closeButton);
          await tester.pumpAndSettle();

          expect(
            find.byKey(const Key('notifications_unavailable_banner')),
            findsNothing,
          );
        });
      });

      testWidgets(
        'it should not show notification banner when it has been dismissed',
        (tester) async {
          final oobChatSDK = FakeChatSdk();

          await navigateToChat(
            tester,
            contactId: FakeContacts.oobContactDismissed.id,
            isAuthenticated: true,
            alreadyOnboarded: true,
            identities: [FakeIdentities.primaryIdentity],
            contacts: [FakeContacts.oobContactDismissed],
            chatSdk: oobChatSDK,
          );

          expect(
            find.byKey(const Key('notifications_unavailable_banner')),
            findsNothing,
          );

          expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
        },
      );
    });
  });
}
