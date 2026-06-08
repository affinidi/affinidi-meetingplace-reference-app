import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:permission_handler/permission_handler.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_connectivity.dart';
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

Future<void> navigateToGroupChatScreen(
  WidgetTester tester, {
  required String contactId,
  MeetingPlaceChatSDK? meetingPlaceChatSDK,
  ImagePicker? imagePicker,
  List<CameraDescription>? mockCameras,
  FakeSecureStorage? secureStorage,
  PermissionStatus? cameraPermissionStatus,
  Connectivity? connectivity,
}) async {
  await navigateToLocation(
    tester,
    '/contacts/$contactId/chat',
    isAuthenticated: true,
    alreadyOnboarded: true,
    identities: [FakeIdentities.primaryIdentity],
    contacts: [FakeContacts.groupContact],
    connectivity:
        connectivity ??
        FakeConnectivity(
          initialConnectivityToReturn: [ConnectivityResult.wifi],
        ),
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
    recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
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
  String groupName,
) async {
  expect(meetingPlaceChatSDK.sendMediaMessageCalls, hasLength(1));
  final sendCall = meetingPlaceChatSDK.sendMediaMessageCalls.first;
  expect(sendCall['caption'], message);
  expect(sendCall['fileBytes'], isNotNull);
  expect(sendCall['contentType'], startsWith('image/'));

  // Simulate the message coming back through the stream as a hosted media
  // attachment — transportId-only so the download path is exercised.
  final mxcUri = sendCall['mxcUri'] as Uri;
  final transportId = sendCall['transportId'] as String;
  final attachment = ChatAttachment(
    mediaType: sendCall['contentType'] as String,
    filename: sendCall['filename'] as String?,
    format: AttachmentFormat.hostedMedia.value,
    data: ChatAttachmentData(links: [mxcUri]),
  )..transportId = transportId;

  meetingPlaceChatSDK.simulateIncomingTextMessage(
    text: message,
    recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
    attachments: [attachment],
  );
  await tester.pumpAndSettle();

  expect(find.text(groupName), findsOneWidget);
  expect(find.text(message), findsOneWidget);
  expect(find.byType(Image), findsWidgets);
}

void main() {
  group('When opening a group chat', () {
    final contactId = FakeContacts.groupContact.id;
    final contact = FakeContacts.groupContact;
    final groupName = contact.displayName ?? 'Group';
    final meetingPlaceChatSDK = FakeChatSdk();

    testWidgets('it shows the chat screen with correct title', (tester) async {
      await navigateToGroupChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );

      expect(find.text(groupName), findsOneWidget);
    });

    testWidgets('it shows the message input field', (tester) async {
      await navigateToGroupChatScreen(
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
      await navigateToGroupChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );

      final sendButton = findSendButton();
      expect(sendButton, findsOneWidget);
    });

    testWidgets('it shows the add media button', (tester) async {
      await navigateToGroupChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );
      final addButton = findAddMediaButton();
      expect(addButton, findsOneWidget);
    });

    testWidgets('it shows the encryption notice', (tester) async {
      final l10n = await getL10n();

      await navigateToGroupChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );
      expect(find.text(l10n.chatEncryptionNotice), findsOneWidget);
    });

    testWidgets('it allows typing in the message input', (tester) async {
      await navigateToGroupChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );
      const testMessage = 'Hello group!';

      await enterChatMessage(tester, testMessage);

      final inputField = findChatMessageInput();
      final textField = tester.widget<TextFormField>(inputField);
      expect(textField.controller?.text, testMessage);
    });

    testWidgets('it shows the group avatar', (tester) async {
      await navigateToGroupChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );
      final contactAvatarKey = const Key('chat_contact_avatar');
      expect(find.byKey(contactAvatarKey), findsOneWidget);
    });

    testWidgets('it shows group member details hint', (tester) async {
      final l10n = await getL10n();

      await navigateToGroupChatScreen(
        tester,
        contactId: contactId,
        meetingPlaceChatSDK: meetingPlaceChatSDK,
      );

      expect(find.text(l10n.chatScreenTapForMemberDetails), findsOneWidget);
    });

    group('and entering a message', () {
      testWidgets('it has the send button available', (tester) async {
        await navigateToGroupChatScreen(
          tester,
          contactId: contactId,
          meetingPlaceChatSDK: meetingPlaceChatSDK,
        );
        const testMessage = 'Test group message';

        await enterChatMessage(tester, testMessage);

        final sendButton = findSendButton();
        expect(sendButton, findsOneWidget);
      });
    });

    group('and message list is empty', () {
      testWidgets('it shows only the encryption notice', (tester) async {
        final l10n = await getL10n();

        await navigateToGroupChatScreen(
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
        await navigateToGroupChatScreen(
          tester,
          contactId: contactId,
          meetingPlaceChatSDK: meetingPlaceChatSDK,
        );
        const testMessage = 'Hello group members!';

        await enterChatMessage(tester, testMessage);
        await tapSendButton(tester);
        await tester.pumpAndSettle();

        expect(meetingPlaceChatSDK.sendTextMessageCalls, hasLength(1));
        final sendCall = meetingPlaceChatSDK.sendTextMessageCalls.first;
        expect(sendCall['text'], testMessage);
        expect(sendCall['attachments'], isEmpty);

        // Simulate the message appearing in the UI
        meetingPlaceChatSDK.simulateIncomingTextMessage(
          text: testMessage,
          recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
        );
        await tester.pumpAndSettle();

        expect(find.text(testMessage), findsOneWidget);
      });

      testWidgets('the input field is cleared after sending', (tester) async {
        await navigateToGroupChatScreen(
          tester,
          contactId: contactId,
          meetingPlaceChatSDK: meetingPlaceChatSDK,
        );
        const testMessage = 'Another group message';

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
      const message = 'Hello everyone in the group!';

      testWidgets('an incoming message appears on the screen', (tester) async {
        await navigateToGroupChatScreen(
          tester,
          contactId: contactId,
          meetingPlaceChatSDK: meetingPlaceChatSDK,
        );

        await simulateIncomingMessage(tester, meetingPlaceChatSDK, message);
        expect(find.text(message), findsOneWidget);
      });

      group('and user long press on the received message', () {
        testWidgets('should let user react to the message', (tester) async {
          await navigateToGroupChatScreen(
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
      testWidgets('should show a menu with media and effects options', (
        tester,
      ) async {
        final l10n = await getL10n();

        await navigateToGroupChatScreen(
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
          testWidgets('should call sendEffect with ${effect.name} effect', (
            tester,
          ) async {
            final l10n = await getL10n();
            final effectLabel = effect == Effect.balloons
                ? l10n.generalBalloons
                : l10n.generalConfetti;
            final meetingPlaceChatSDK = FakeChatSdk();

            await navigateToGroupChatScreen(
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
        testWidgets('should send photo and return to chat screen', (
          tester,
        ) async {
          final l10n = await getL10n();
          const message = 'Check out this photo!';
          final meetingPlaceChatSDK = FakeChatSdk();

          await navigateToGroupChatScreen(
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
            groupName,
          );
        });
      });

      group('and pressing on camera', () {
        testWidgets('should send photo and return to chat screen', (
          tester,
        ) async {
          final l10n = await getL10n();
          const message = 'Check out this photo!';
          final meetingPlaceChatSDK = FakeChatSdk();

          await navigateToGroupChatScreen(
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
            groupName,
          );
        });
      });
    });

    group('and user is group admin', () {
      group('and a member requests to join', () {
        testWidgets('it shows a concierge message for approval', (
          tester,
        ) async {
          final l10n = await getL10n();
          const memberName = 'Khoa Vo';

          await navigateToGroupChatScreen(
            tester,
            contactId: contactId,
            meetingPlaceChatSDK: meetingPlaceChatSDK,
          );

          meetingPlaceChatSDK.simulateJoinGroupRequest(
            memberName: memberName,
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
          );
          await tester.pumpAndSettle();

          expect(find.text(l10n.genWordConciergeMessage), findsOneWidget);
        });

        testWidgets('it shows the join request message with member name', (
          tester,
        ) async {
          final l10n = await getL10n();
          const memberName = 'Khoa Vo';

          await navigateToGroupChatScreen(
            tester,
            contactId: contactId,
            meetingPlaceChatSDK: meetingPlaceChatSDK,
          );

          meetingPlaceChatSDK.simulateJoinGroupRequest(
            memberName: memberName,
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
          );
          await tester.pumpAndSettle();

          final expectedText = l10n.chatRequestPermissionToJoinGroup(
            memberName,
          );
          expect(find.text(expectedText), findsOneWidget);
        });

        testWidgets('it shows approve and reject buttons', (tester) async {
          final l10n = await getL10n();
          const memberName = 'Khoa Vo';

          await navigateToGroupChatScreen(
            tester,
            contactId: contactId,
            meetingPlaceChatSDK: meetingPlaceChatSDK,
          );

          meetingPlaceChatSDK.simulateJoinGroupRequest(
            memberName: memberName,
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
          );
          await tester.pumpAndSettle();

          expect(find.text(l10n.generalApprove), findsOneWidget);
          expect(find.text(l10n.generalReject), findsOneWidget);
        });

        testWidgets(
          'when approve button is pressed, it calls approveConnectionRequest',
          (tester) async {
            final l10n = await getL10n();
            const memberName = 'Khoa Vo';
            final meetingPlaceChatSDK = FakeChatSdk();

            await navigateToGroupChatScreen(
              tester,
              contactId: contactId,
              meetingPlaceChatSDK: meetingPlaceChatSDK,
            );

            final simulatedMessage = meetingPlaceChatSDK
                .simulateJoinGroupRequest(
                  memberName: memberName,
                  senderDid:
                      FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
                  recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
                );
            await tester.pumpAndSettle();

            await tester.tap(find.text(l10n.generalApprove));
            await tester.pumpAndSettle();

            expect(
              meetingPlaceChatSDK.approveConnectionRequestCalls,
              hasLength(1),
            );
            final approveCall =
                meetingPlaceChatSDK.approveConnectionRequestCalls.first;
            final calledWithMessage =
                approveCall['message'] as ConciergeMessage;
            expect(calledWithMessage.messageId, simulatedMessage.messageId);
            expect(calledWithMessage.chatId, simulatedMessage.chatId);
          },
        );

        testWidgets(
          'when reject button is pressed, it calls rejectConnectionRequest',
          (tester) async {
            final l10n = await getL10n();
            const memberName = 'Khoa Vo';
            final meetingPlaceChatSDK = FakeChatSdk();

            await navigateToGroupChatScreen(
              tester,
              contactId: contactId,
              meetingPlaceChatSDK: meetingPlaceChatSDK,
            );

            final simulatedMessage = meetingPlaceChatSDK
                .simulateJoinGroupRequest(
                  memberName: memberName,
                  senderDid:
                      FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
                  recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
                );
            await tester.pumpAndSettle();

            await tester.tap(find.text(l10n.generalReject));
            await tester.pumpAndSettle();

            expect(
              meetingPlaceChatSDK.rejectConnectionRequestCalls,
              hasLength(1),
            );
            final rejectCall =
                meetingPlaceChatSDK.rejectConnectionRequestCalls.first;
            final calledWithMessage = rejectCall['message'] as ConciergeMessage;
            expect(calledWithMessage.messageId, simulatedMessage.messageId);
            expect(calledWithMessage.chatId, simulatedMessage.chatId);
          },
        );
      });

      group('and profile update is requested', () {
        testWidgets('shows concierge message with update prompt', (
          WidgetTester tester,
        ) async {
          final contactId = FakeContacts.groupContact.id;
          final meetingPlaceChatSDK = FakeChatSdk();
          final l10n = await getL10n();

          await navigateToGroupChatScreen(
            tester,
            contactId: contactId,
            meetingPlaceChatSDK: meetingPlaceChatSDK,
          );

          meetingPlaceChatSDK.simulateProfileUpdateRequest(
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
          );
          await tester.pumpAndSettle();

          expect(
            find.text(l10n.chatRequestPermissionToUpdateProfileGroup),
            findsOneWidget,
          );
        });

        testWidgets('shows Yes, Later, No buttons', (
          WidgetTester tester,
        ) async {
          final contactId = FakeContacts.groupContact.id;
          final meetingPlaceChatSDK = FakeChatSdk();
          final l10n = await getL10n();

          await navigateToGroupChatScreen(
            tester,
            contactId: contactId,
            meetingPlaceChatSDK: meetingPlaceChatSDK,
          );

          meetingPlaceChatSDK.simulateProfileUpdateRequest(
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
          );
          await tester.pumpAndSettle();

          expect(find.text(l10n.genWordYes), findsOneWidget);
          expect(find.text(l10n.genWordLater), findsOneWidget);
          expect(find.text(l10n.genWordNo), findsOneWidget);
        });

        testWidgets(
          'Yes button calls sendContactDetailsUpdate with correct message',
          (WidgetTester tester) async {
            final contactId = FakeContacts.groupContact.id;
            final meetingPlaceChatSDK = FakeChatSdk();
            final l10n = await getL10n();

            await navigateToGroupChatScreen(
              tester,
              contactId: contactId,
              meetingPlaceChatSDK: meetingPlaceChatSDK,
            );

            final simulatedMessage = meetingPlaceChatSDK
                .simulateProfileUpdateRequest(
                  senderDid:
                      FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
                  recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
                );
            await tester.pumpAndSettle();

            await tester.tap(find.text(l10n.genWordYes));
            await tester.pumpAndSettle();

            expect(
              meetingPlaceChatSDK.sendContactDetailsUpdateCalls,
              hasLength(1),
            );
            final updateCall =
                meetingPlaceChatSDK.sendContactDetailsUpdateCalls.first;
            final calledWithMessage = updateCall['message'] as ConciergeMessage;
            expect(calledWithMessage.messageId, simulatedMessage.messageId);
            expect(calledWithMessage.chatId, simulatedMessage.chatId);
          },
        );

        testWidgets('Later button removes the profile update message from UI', (
          WidgetTester tester,
        ) async {
          final contactId = FakeContacts.groupContact.id;
          final meetingPlaceChatSDK = FakeChatSdk();
          final l10n = await getL10n();

          await navigateToGroupChatScreen(
            tester,
            contactId: contactId,
            meetingPlaceChatSDK: meetingPlaceChatSDK,
          );

          meetingPlaceChatSDK.simulateProfileUpdateRequest(
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
          );
          await tester.pumpAndSettle();

          expect(
            find.text(l10n.chatRequestPermissionToUpdateProfileGroup),
            findsOneWidget,
          );

          await tester.tap(find.text(l10n.genWordLater));
          await tester.pumpAndSettle();

          expect(
            find.text(l10n.chatRequestPermissionToUpdateProfileGroup),
            findsNothing,
          );
        });

        testWidgets(
          'No button calls cancelUpdatingContactDetails with correct message',
          (WidgetTester tester) async {
            final contactId = FakeContacts.groupContact.id;
            final meetingPlaceChatSDK = FakeChatSdk();
            final l10n = await getL10n();

            await navigateToGroupChatScreen(
              tester,
              contactId: contactId,
              meetingPlaceChatSDK: meetingPlaceChatSDK,
            );

            final simulatedMessage = meetingPlaceChatSDK
                .simulateProfileUpdateRequest(
                  senderDid:
                      FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
                  recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
                );
            await tester.pumpAndSettle();

            await tester.tap(find.text(l10n.genWordNo));
            await tester.pumpAndSettle();

            expect(
              meetingPlaceChatSDK.cancelUpdatingContactDetailsCalls,
              hasLength(1),
            );
            final cancelCall =
                meetingPlaceChatSDK.cancelUpdatingContactDetailsCalls.first;
            final calledWithMessage = cancelCall['message'] as ConciergeMessage;
            expect(calledWithMessage.messageId, simulatedMessage.messageId);
            expect(calledWithMessage.chatId, simulatedMessage.chatId);
          },
        );
      });

      group('and member joins the group', () {
        testWidgets('shows member joined message', (WidgetTester tester) async {
          final contactId = FakeContacts.groupContact.id;
          final meetingPlaceChatSDK = FakeChatSdk();
          final memberName = 'Khoa Vo';

          await navigateToGroupChatScreen(
            tester,
            contactId: contactId,
            meetingPlaceChatSDK: meetingPlaceChatSDK,
          );

          meetingPlaceChatSDK.simulateMemberJoinedGroup(
            memberName: memberName,
            memberDid: 'did:member:123',
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
          );
          await tester.pumpAndSettle();

          expect(find.textContaining('has joined the group'), findsOneWidget);
          expect(find.textContaining(memberName), findsWidgets);
        });
      });

      group('and member leaves the group', () {
        testWidgets('shows member left message', (WidgetTester tester) async {
          final contactId = FakeContacts.groupContact.id;
          final meetingPlaceChatSDK = FakeChatSdk();
          final l10n = await getL10n();
          final memberName = 'Earl G.Reyes';

          await navigateToGroupChatScreen(
            tester,
            contactId: contactId,
            meetingPlaceChatSDK: meetingPlaceChatSDK,
          );

          meetingPlaceChatSDK.simulateMemberLeftGroup(
            memberName: memberName,
            memberDid: 'did:member:456',
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
          );
          await tester.pumpAndSettle();

          expect(find.text(l10n.leavingGroup(memberName)), findsOneWidget);
        });
      });

      group('and group is deleted', () {
        testWidgets('shows group deleted message', (WidgetTester tester) async {
          final contactId = FakeContacts.groupContact.id;
          final meetingPlaceChatSDK = FakeChatSdk();
          final l10n = await getL10n();

          await navigateToGroupChatScreen(
            tester,
            contactId: contactId,
            meetingPlaceChatSDK: meetingPlaceChatSDK,
          );

          meetingPlaceChatSDK.simulateGroupDeleted(
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
          );
          await tester.pumpAndSettle();

          expect(find.text(l10n.groupDeleted), findsOneWidget);
        });
      });
    });
  });
}
