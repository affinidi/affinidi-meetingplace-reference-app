import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:mpx_flutter_reference_app/infrastructure/plugins/audio_attachments_plugin/audio_attachments_plugin.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/profile_circle_avatar.dart';
import 'package:permission_handler/permission_handler.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_groups.dart';
import 'fakes/fake_image_picker.dart';
import 'fakes/fake_meeting_place_sdk.dart';
import 'utils/app.dart';

Finder findChatMessageInput() => find.byKey(const Key('chat_message_input'));
Finder findSendButton() => find.byKey(const Key('chat_send_button'));
Finder findAddMediaButton() => find.byKey(const Key('chat_add_media_button'));
Finder findGifButton() => find.byKey(const Key('chat_gif_button'));

const groupMentionCapabilities = TransportCapabilities({
  ChatFeature.textMessaging,
  ChatFeature.mentions,
  ChatFeature.imageAttachments,
  ChatFeature.videoAttachments,
  ChatFeature.documentAttachments,
  ChatFeature.voiceMessages,
  ChatFeature.reactions,
  ChatFeature.typingIndicators,
  ChatFeature.deliveryReceipts,
  ChatFeature.messageEdit,
  ChatFeature.messageDelete,
  ChatFeature.effects,
  ChatFeature.contactDetailsUpdate,
  ChatFeature.suggestionRequests,
});

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
  FakeChatSdk chatSdk,
  String message,
  String groupName,
) async {
  expect(chatSdk.sendTextMessageCalls, hasLength(1));
  final sendCall = chatSdk.sendTextMessageCalls.first;
  expect(sendCall['text'], message);
  expect(sendCall['attachments'], isA<List<ChatAttachment>>());
  expect((sendCall['attachments'] as List).length, 1);

  final attachments = sendCall['attachments'] as List<ChatAttachment>;
  chatSdk.simulateIncomingTextMessage(
    text: message,
    recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
    attachments: attachments,
  );
  await tester.pumpAndSettle();

  expect(find.text(groupName), findsOneWidget);
  expect(find.text(message), findsOneWidget);
  expect(find.byType(Image), findsWidgets);
}

void main() {
  final contacts = [FakeContacts.groupContact];
  group('When opening a group chat', () {
    final contactId = FakeContacts.groupContact.id;
    final contact = FakeContacts.groupContact;
    final groupName = contact.displayName ?? 'Group';
    final chatSdk = FakeChatSdk();

    testWidgets('it shows the chat screen with correct title', (tester) async {
      await navigateToChat(
        tester,
        contactId: contactId,
        chatSdk: chatSdk,
        contacts: contacts,
      );

      expect(find.text(groupName), findsOneWidget);
    });

    testWidgets('it shows the message input field', (tester) async {
      await navigateToChat(
        tester,
        contactId: contactId,
        chatSdk: chatSdk,
        contacts: contacts,
      );

      final inputField = findChatMessageInput();
      expect(inputField, findsOneWidget);

      final textField = tester.widget<TextFormField>(inputField);
      expect(textField.enabled, isNot(false));
    });

    testWidgets('it shows the send button', (tester) async {
      await navigateToChat(
        tester,
        contactId: contactId,
        chatSdk: chatSdk,
        contacts: contacts,
      );

      final sendButton = findSendButton();
      expect(sendButton, findsOneWidget);
    });

    testWidgets('it shows the add media button', (tester) async {
      await navigateToChat(
        tester,
        contactId: contactId,
        chatSdk: chatSdk,
        contacts: contacts,
      );
      final addButton = findAddMediaButton();
      expect(addButton, findsOneWidget);
    });

    testWidgets('it shows the encryption notice', (tester) async {
      final l10n = await getL10n();

      await navigateToChat(
        tester,
        contactId: contactId,
        chatSdk: chatSdk,
        contacts: contacts,
      );
      expect(find.text(l10n.chatEncryptionNotice), findsOneWidget);
    });

    testWidgets('it renders audio attachments as voice messages', (
      tester,
    ) async {
      final chatSDK = FakeChatSdk();
      await navigateToChat(
        tester,
        contactId: contactId,
        chatSdk: chatSDK,
        contacts: contacts,
      );

      chatSDK.simulateIncomingTextMessage(
        text: '',
        recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
        attachments: [
          ChatAttachment(
            id: 'voice-attachment-1',
            mediaType: 'audio/mp4',
            filename: 'voice.m4a',
            format: AudioAttachmentsPlugin.pluginName,
            data: ChatAttachmentData(
              links: [Uri.parse('mxc://fake-homeserver/voice')],
            ),
            metadata: VoiceMessageMetadata(
              durationMs: 11000,
              waveform: [0, 35, 100],
            ).toMetadata(),
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.text('0:11'), findsOneWidget);
      final waveform = find.byKey(const Key('voice_waveform_paint'));
      expect(waveform, findsOneWidget);
      expect(tester.getSize(waveform).width, greaterThan(0));
      expect(tester.getSize(waveform).height, 28);
      expect(find.byIcon(Icons.insert_drive_file), findsNothing);
    });

    testWidgets('it allows typing in the message input', (tester) async {
      await navigateToChat(
        tester,
        contactId: contactId,
        chatSdk: chatSdk,
        contacts: contacts,
      );
      const testMessage = 'Hello group!';

      await enterChatMessage(tester, testMessage);

      final inputField = findChatMessageInput();
      final textField = tester.widget<TextFormField>(inputField);
      expect(textField.controller?.text, testMessage);
    });

    testWidgets('it shows the group avatar', (tester) async {
      await navigateToChat(
        tester,
        contactId: contactId,
        chatSdk: chatSdk,
        contacts: contacts,
      );
      final contactAvatarKey = const Key('chat_contact_avatar');
      expect(find.byKey(contactAvatarKey), findsOneWidget);
    });

    testWidgets('it shows group member details hint', (tester) async {
      final l10n = await getL10n();

      await navigateToChat(
        tester,
        contactId: contactId,
        chatSdk: chatSdk,
        contacts: contacts,
      );

      expect(find.text(l10n.chatScreenTapForMemberDetails), findsOneWidget);
    });

    group('and entering a message', () {
      testWidgets('it has the send button available', (tester) async {
        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          contacts: contacts,
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

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          contacts: contacts,
        );
        expect(find.text(l10n.chatEncryptionNotice), findsOneWidget);
      });
    });

    group('and sending a message', () {
      final chatSdk = FakeChatSdk();

      testWidgets('it appears on the screen', (tester) async {
        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          contacts: contacts,
        );
        const testMessage = 'Hello group members!';

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
          recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
        );
        await tester.pumpAndSettle();

        expect(find.text(testMessage), findsOneWidget);
      });

      testWidgets('the input field is cleared after sending', (tester) async {
        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          contacts: contacts,
        );
        const testMessage = 'Another group message';

        await enterChatMessage(tester, testMessage);
        await tapSendButton(tester);
        await tester.pumpAndSettle();

        final inputField = findChatMessageInput();
        final textField = tester.widget<TextFormField>(inputField);
        expect(textField.controller?.text, isEmpty);
      });

      testWidgets('it suggests members and forwards mentions', (tester) async {
        final chatSdk = FakeChatSdk(capabilities: groupMentionCapabilities);
        final coreSdk = FakeMeetingPlaceSDK(channels: FakeChannels.allChannels)
          ..setMockGroup(FakeGroups.approvedGroup());

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          contacts: contacts,
          meetingPlaceCoreSDK: coreSdk,
        );

        await enterChatMessage(tester, 'Hello @Bo');
        await pumpMentionDebounce(tester);

        expect(
          find.byKey(const Key('chat_mention_suggestions')),
          findsOneWidget,
        );
        expect(find.text('Bob'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('chat_mention_suggestions')),
            matching: find.byType(ProfileCircleAvatar),
          ),
          findsWidgets,
        );

        await tester.tap(find.text('Bob'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('chat_mention_suggestions')), findsNothing);

        final inputField = findChatMessageInput();
        final textField = tester.widget<TextFormField>(inputField);
        expect(textField.controller?.text, 'Hello @Bob ');

        await tapSendButton(tester);
        await tester.pumpAndSettle();

        expect(chatSdk.sendTextMessageCalls, hasLength(1));
        final sendCall = chatSdk.sendTextMessageCalls.first;
        expect(sendCall['text'], 'Hello @Bob');
        expect(sendCall['mentions'], isA<List<ChatMention>>());
        final mentions = sendCall['mentions'] as List<ChatMention>;
        expect(mentions, hasLength(1));
        expect(mentions.first.target, FakeGroups.removableMemberDid);
        expect(mentions.first.start, 6);
        expect(mentions.first.length, '@Bob'.length);
        expect(mentions.first.display, '@Bob');
      });

      testWidgets('it shows mention suggestions without waiting for debounce', (
        tester,
      ) async {
        final chatSdk = FakeChatSdk(capabilities: groupMentionCapabilities);
        final coreSdk = FakeMeetingPlaceSDK(channels: FakeChannels.allChannels)
          ..setMockGroup(FakeGroups.approvedGroup());

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          contacts: contacts,
          meetingPlaceCoreSDK: coreSdk,
        );

        await enterChatMessage(tester, 'Hello @Bo');

        expect(
          find.byKey(const Key('chat_mention_suggestions')),
          findsOneWidget,
        );
        expect(find.text('Bob'), findsOneWidget);
      });

      testWidgets('it does not reopen suggestions for an existing mention', (
        tester,
      ) async {
        final chatSdk = FakeChatSdk(capabilities: groupMentionCapabilities);
        final coreSdk = FakeMeetingPlaceSDK(channels: FakeChannels.allChannels)
          ..setMockGroup(FakeGroups.approvedGroup());

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          contacts: contacts,
          meetingPlaceCoreSDK: coreSdk,
        );

        await enterChatMessage(tester, 'Hello @Bo');
        await pumpMentionDebounce(tester);
        await tester.tap(find.text('Bob'));
        await tester.pumpAndSettle();

        final inputField = findChatMessageInput();
        final textField = tester.widget<TextFormField>(inputField);
        final controller = textField.controller!;
        final mentionStart = controller.text.indexOf('@Bob');
        final mentionEnd = mentionStart + '@Bob'.length;

        controller.value = controller.value.copyWith(
          selection: TextSelection.collapsed(offset: mentionStart + 1),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('chat_mention_suggestions')), findsNothing);

        controller.value = controller.value.copyWith(
          selection: TextSelection.collapsed(offset: mentionEnd),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('chat_mention_suggestions')), findsNothing);

        await tapSendButton(tester);
        await tester.pumpAndSettle();

        expect(chatSdk.sendTextMessageCalls, hasLength(1));
        final sendCall = chatSdk.sendTextMessageCalls.first;
        expect(sendCall['text'], 'Hello @Bob');
        final mentions = sendCall['mentions'] as List<ChatMention>;
        expect(mentions, hasLength(1));
        expect(mentions.first.target, FakeGroups.removableMemberDid);
        expect(mentions.first.start, 6);
        expect(mentions.first.length, '@Bob'.length);
        expect(mentions.first.display, '@Bob');
      });

      testWidgets('it deletes a whole mention when backspacing after it', (
        tester,
      ) async {
        final chatSdk = FakeChatSdk(capabilities: groupMentionCapabilities);
        final coreSdk = FakeMeetingPlaceSDK(channels: FakeChannels.allChannels)
          ..setMockGroup(FakeGroups.approvedGroup());

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          contacts: contacts,
          meetingPlaceCoreSDK: coreSdk,
        );

        await enterChatMessage(tester, 'Hello @Bo');
        await pumpMentionDebounce(tester);
        await tester.tap(find.text('@Bob'));
        await tester.pumpAndSettle();

        final inputField = findChatMessageInput();
        final textField = tester.widget<TextFormField>(inputField);
        final controller = textField.controller!;
        final mentionEnd = controller.text.indexOf('@Bob') + '@Bob'.length;

        controller.value = controller.value.copyWith(
          selection: TextSelection.collapsed(offset: mentionEnd),
        );
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
        await tester.pumpAndSettle();

        expect(controller.text, 'Hello ');
        expect(find.byKey(const Key('chat_mention_suggestions')), findsNothing);

        await tapSendButton(tester);
        await tester.pumpAndSettle();

        expect(chatSdk.sendTextMessageCalls, hasLength(1));
        final sendCall = chatSdk.sendTextMessageCalls.first;
        expect(sendCall['text'], 'Hello');
        expect(sendCall['mentions'], isA<List<ChatMention>>());
        expect(sendCall['mentions'], isEmpty);
      });

      testWidgets('it deletes a whole mention when deleting its last letter', (
        tester,
      ) async {
        final chatSdk = FakeChatSdk(capabilities: groupMentionCapabilities);
        final coreSdk = FakeMeetingPlaceSDK(channels: FakeChannels.allChannels)
          ..setMockGroup(FakeGroups.approvedGroup());

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          contacts: contacts,
          meetingPlaceCoreSDK: coreSdk,
        );

        await enterChatMessage(tester, 'Hello @Bo');
        await pumpMentionDebounce(tester);
        await tester.tap(find.text('@Bob'));
        await tester.pumpAndSettle();

        final inputField = findChatMessageInput();
        final textField = tester.widget<TextFormField>(inputField);
        final controller = textField.controller!;
        final mentionEnd = controller.text.indexOf('@Bob') + '@Bob'.length;

        controller.value = TextEditingValue(
          text: 'Hello @Bo ',
          selection: TextSelection.collapsed(offset: mentionEnd - 1),
        );
        await tester.pumpAndSettle();

        expect(controller.text, 'Hello ');
        expect(find.byKey(const Key('chat_mention_suggestions')), findsNothing);

        await tapSendButton(tester);
        await tester.pumpAndSettle();

        expect(chatSdk.sendTextMessageCalls, hasLength(1));
        final sendCall = chatSdk.sendTextMessageCalls.first;
        expect(sendCall['text'], 'Hello');
        expect(sendCall['mentions'], isA<List<ChatMention>>());
        expect(sendCall['mentions'], isEmpty);
      });

      testWidgets('it supports mentions in the edit dialog', (tester) async {
        final chatSdk = FakeChatSdk(capabilities: groupMentionCapabilities);
        final coreSdk = FakeMeetingPlaceSDK(channels: FakeChannels.allChannels)
          ..setMockGroup(FakeGroups.approvedGroup());
        final l10n = await getL10n();

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          contacts: contacts,
          meetingPlaceCoreSDK: coreSdk,
        );

        chatSdk.simulateSentTextMessage(text: 'Hello team');
        await tester.pumpAndSettle();

        await tester.longPress(find.text('Hello team'));
        await tester.pumpAndSettle();

        await tester.tap(find.text(l10n.chatMessageActionEdit));
        await tester.pumpAndSettle();

        final dialogFinder = find.byType(AlertDialog);
        final dialogTextField = find.descendant(
          of: dialogFinder,
          matching: find.byType(TextField),
        );

        await tester.enterText(dialogTextField, 'Hello @Car');
        await pumpMentionDebounce(tester);

        expect(
          find.byKey(const Key('chat_mention_suggestions')),
          findsOneWidget,
        );
        expect(find.text('@Carol'), findsOneWidget);

        await tester.tap(find.text('@Carol'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('chat_mention_suggestions')), findsNothing);

        final dialogField = tester.widget<TextField>(dialogTextField);
        expect(dialogField.controller?.text, 'Hello @Carol ');

        await tester.tap(find.text(l10n.chatMessageEditSave));
        await tester.pumpAndSettle();

        expect(chatSdk.editTextMessageCalls, hasLength(1));
        final editCall = chatSdk.editTextMessageCalls.first;
        expect(editCall['newText'], 'Hello @Carol');
        expect(editCall['mentions'], isA<List<ChatMention>>());
        final mentions = editCall['mentions'] as List<ChatMention>;
        expect(mentions, hasLength(1));
        expect(mentions.first.target, FakeGroups.adminMemberDid);
        expect(mentions.first.start, 6);
        expect(mentions.first.length, '@Carol'.length);
        expect(mentions.first.display, '@Carol');
      });
    });

    group('and receiving a message', () {
      final chatSdk = FakeChatSdk();
      const message = 'Hello everyone in the group!';

      testWidgets('an incoming message appears on the screen', (tester) async {
        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          contacts: contacts,
        );

        await simulateIncomingMessage(tester, chatSdk, message);
        expect(find.text(message), findsOneWidget);
      });

      group('and user long press on the received message', () {
        testWidgets('should let user react to the message', (tester) async {
          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

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

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          contacts: contacts,
        );
        final addMediaButton = findAddMediaButton();
        expect(addMediaButton, findsOneWidget);

        await tester.tap(addMediaButton);
        await tester.pumpAndSettle();

        expect(find.text(l10n.generalCamera), findsOneWidget);
        expect(find.text(l10n.generalPhoto), findsOneWidget);
        expect(find.text(l10n.generalBalloons), findsNothing);
        expect(find.text(l10n.generalConfetti), findsNothing);
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
            final chatSdk = FakeChatSdk();

            await navigateToChat(
              tester,
              contactId: contactId,
              chatSdk: chatSdk,
              contacts: contacts,
            );

            await tester.tap(findGifButton());
            await tester.pumpAndSettle();

            await tester.tap(find.text(effectLabel));
            await tester.pumpAndSettle();

            expect(chatSdk.sendEffectCalls, hasLength(1));
            expect(chatSdk.sendEffectCalls.first['effect'], effect);
          });
        });
      }

      group('and pressing on photo', () {
        testWidgets('should send photo and return to chat screen', (
          tester,
        ) async {
          final l10n = await getL10n();
          const message = 'Check out this photo!';
          final chatSdk = FakeChatSdk();

          await navigateToChat(
            tester,
            contactId: contactId,
            imagePicker: FakeImagePicker.withDefaultImage(),
            chatSdk: chatSdk,
            contacts: contacts,
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
            chatSdk,
            message,
            groupName,
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
            contacts: contacts,
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
          final chatSdk = FakeChatSdk();

          await navigateToChat(
            tester,
            contactId: contactId,
            imagePicker: FakeImagePicker.withDefaultImage(),
            cameras: mockCameras,
            chatSdk: chatSdk,
            cameraPermissionStatus: PermissionStatus.granted,
            contacts: contacts,
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
            chatSdk,
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

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

          chatSdk.simulateJoinGroupRequest(
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

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

          chatSdk.simulateJoinGroupRequest(
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

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

          chatSdk.simulateJoinGroupRequest(
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
            final chatSdk = FakeChatSdk();

            await navigateToChat(
              tester,
              contactId: contactId,
              chatSdk: chatSdk,
              contacts: contacts,
            );

            final simulatedMessage = chatSdk.simulateJoinGroupRequest(
              memberName: memberName,
              senderDid:
                  FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
              recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
            );
            await tester.pumpAndSettle();

            await tester.tap(find.text(l10n.generalApprove));
            await tester.pumpAndSettle();

            expect(chatSdk.approveConnectionRequestCalls, hasLength(1));
            final approveCall = chatSdk.approveConnectionRequestCalls.first;
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
            final chatSdk = FakeChatSdk();

            await navigateToChat(
              tester,
              contactId: contactId,
              chatSdk: chatSdk,
              contacts: contacts,
            );

            final simulatedMessage = chatSdk.simulateJoinGroupRequest(
              memberName: memberName,
              senderDid:
                  FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
              recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
            );
            await tester.pumpAndSettle();

            await tester.tap(find.text(l10n.generalReject));
            await tester.pumpAndSettle();

            expect(chatSdk.rejectConnectionRequestCalls, hasLength(1));
            final rejectCall = chatSdk.rejectConnectionRequestCalls.first;
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
          final chatSdk = FakeChatSdk();
          final l10n = await getL10n();

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

          chatSdk.simulateProfileUpdateRequest(
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
          final chatSdk = FakeChatSdk();
          final l10n = await getL10n();

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

          chatSdk.simulateProfileUpdateRequest(
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
            final chatSdk = FakeChatSdk();
            final l10n = await getL10n();

            await navigateToChat(
              tester,
              contactId: contactId,
              chatSdk: chatSdk,
              contacts: contacts,
            );

            final simulatedMessage = chatSdk.simulateProfileUpdateRequest(
              senderDid:
                  FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
              recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
            );
            await tester.pumpAndSettle();

            await tester.tap(find.text(l10n.genWordYes));
            await tester.pumpAndSettle();

            expect(chatSdk.sendContactDetailsUpdateCalls, hasLength(1));
            final updateCall = chatSdk.sendContactDetailsUpdateCalls.first;
            final calledWithMessage = updateCall['message'] as ConciergeMessage;
            expect(calledWithMessage.messageId, simulatedMessage.messageId);
            expect(calledWithMessage.chatId, simulatedMessage.chatId);
          },
        );

        testWidgets('Later button removes the profile update message from UI', (
          WidgetTester tester,
        ) async {
          final contactId = FakeContacts.groupContact.id;
          final chatSdk = FakeChatSdk();
          final l10n = await getL10n();

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

          chatSdk.simulateProfileUpdateRequest(
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
            final chatSdk = FakeChatSdk();
            final l10n = await getL10n();

            await navigateToChat(
              tester,
              contactId: contactId,
              chatSdk: chatSdk,
              contacts: contacts,
            );

            final simulatedMessage = chatSdk.simulateProfileUpdateRequest(
              senderDid:
                  FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
              recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
            );
            await tester.pumpAndSettle();

            await tester.tap(find.text(l10n.genWordNo));
            await tester.pumpAndSettle();

            expect(chatSdk.cancelUpdatingContactDetailsCalls, hasLength(1));
            final cancelCall = chatSdk.cancelUpdatingContactDetailsCalls.first;
            final calledWithMessage = cancelCall['message'] as ConciergeMessage;
            expect(calledWithMessage.messageId, simulatedMessage.messageId);
            expect(calledWithMessage.chatId, simulatedMessage.chatId);
          },
        );
      });

      group('and member joins the group', () {
        testWidgets('shows member joined message', (WidgetTester tester) async {
          final contactId = FakeContacts.groupContact.id;
          final chatSdk = FakeChatSdk();
          final memberName = 'Khoa Vo';

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

          chatSdk.simulateMemberJoinedGroup(
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
          final chatSdk = FakeChatSdk();
          final l10n = await getL10n();
          final memberName = 'Earl G.Reyes';

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

          chatSdk.simulateMemberLeftGroup(
            memberName: memberName,
            memberDid: 'did:member:456',
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
          );
          await tester.pumpAndSettle();

          expect(find.text(l10n.leavingGroup(memberName)), findsOneWidget);
        });

        testWidgets('shows member removed message', (
          WidgetTester tester,
        ) async {
          final contactId = FakeContacts.groupContact.id;
          final chatSdk = FakeChatSdk();
          final l10n = await getL10n();
          final memberName = 'Alice';

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

          chatSdk.simulateMemberLeftGroup(
            memberName: memberName,
            memberDid: 'did:member:456',
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
            reason: GroupMemberLeaveReason.kick,
          );
          await tester.pumpAndSettle();

          expect(
            find.text(l10n.memberRemovedFromGroup(memberName)),
            findsOneWidget,
          );
          expect(find.text(l10n.leavingGroup(memberName)), findsNothing);
        });
      });

      group('and group is deleted', () {
        testWidgets('shows group deleted message', (WidgetTester tester) async {
          final contactId = FakeContacts.groupContact.id;
          final chatSdk = FakeChatSdk();
          final l10n = await getL10n();

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

          chatSdk.simulateGroupDeleted(
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
          );
          await tester.pumpAndSettle();

          expect(find.text(l10n.groupDeleted), findsOneWidget);
        });

        testWidgets('disables the message input', (WidgetTester tester) async {
          final contactId = FakeContacts.groupContact.id;
          final chatSdk = FakeChatSdk();

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

          final inputBeforeDeletion = tester.widget<TextFormField>(
            findChatMessageInput(),
          );
          expect(inputBeforeDeletion.enabled, isNot(false));

          chatSdk.simulateGroupDeleted(
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
          );
          await tester.pumpAndSettle();

          final inputAfterDeletion = tester.widget<TextFormField>(
            findChatMessageInput(),
          );
          expect(inputAfterDeletion.enabled, isFalse);
        });

        testWidgets('disables the message input when opened after deletion', (
          WidgetTester tester,
        ) async {
          final contactId = FakeContacts.groupContact.id;
          final chatSdk = FakeChatSdk();
          final deletedGroup = FakeGroups.approvedGroup()..markAsDeleted();
          final coreSdk = FakeMeetingPlaceSDK(
            channels: FakeChannels.allChannels,
          )..setMockGroup(deletedGroup);

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
            meetingPlaceCoreSDK: coreSdk,
          );

          final input = tester.widget<TextFormField>(findChatMessageInput());
          expect(input.enabled, isFalse);
        });
      });

      group('and current user is removed from the group', () {
        testWidgets('disables the message input on a live removal', (
          WidgetTester tester,
        ) async {
          final contactId = FakeContacts.groupContact.id;
          final chatSdk = FakeChatSdk();
          final myDid = FakeContacts.groupContact.channelDid!;

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

          final inputBefore = tester.widget<TextFormField>(
            findChatMessageInput(),
          );
          expect(inputBefore.enabled, isNot(false));

          chatSdk.simulateMemberLeftGroup(
            memberName: 'You',
            memberDid: myDid,
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
            reason: GroupMemberLeaveReason.kick,
          );
          await tester.pumpAndSettle();

          final inputAfter = tester.widget<TextFormField>(
            findChatMessageInput(),
          );
          expect(inputAfter.enabled, isFalse);
        });

        testWidgets('disables the message input when opened after removal', (
          WidgetTester tester,
        ) async {
          final contactId = FakeContacts.groupContact.id;
          final chatSdk = FakeChatSdk();
          final myDid = FakeContacts.groupContact.channelDid!;
          final groupWithSelfRemoved = sdk.Group(
            id: 'group-id',
            did: 'group-did',
            offerLink: FakeContacts.groupContact.offerLink,
            members: [
              sdk.GroupMember(
                did: myDid,
                dateAdded: DateTime.now(),
                status: sdk.GroupMemberStatus.deleted,
                membershipType: sdk.GroupMembershipType.member,
                contactCard: FakeContacts.sdkContactCard,
                publicKey: 'fake-public-key',
              ),
            ],
            created: DateTime.now(),
            publicKey: 'fake-public-key',
          );
          final coreSdk = FakeMeetingPlaceSDK(
            channels: FakeChannels.allChannels,
          )..setMockGroup(groupWithSelfRemoved);

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
            meetingPlaceCoreSDK: coreSdk,
          );

          final input = tester.widget<TextFormField>(findChatMessageInput());
          expect(input.enabled, isFalse);
        });

        testWidgets('keeps the message input enabled when a member voluntarily '
            'leaves', (WidgetTester tester) async {
          final contactId = FakeContacts.groupContact.id;
          final chatSdk = FakeChatSdk();
          final myDid = FakeContacts.groupContact.channelDid!;

          await navigateToChat(
            tester,
            contactId: contactId,
            chatSdk: chatSdk,
            contacts: contacts,
          );

          chatSdk.simulateMemberLeftGroup(
            memberName: 'You',
            memberDid: myDid,
            senderDid: FakeChannels.groupChannel.otherPartyPermanentChannelDid!,
            recipientDid: FakeChannels.groupChannel.permanentChannelDid!,
            reason: GroupMemberLeaveReason.leave,
          );
          await tester.pumpAndSettle();

          final input = tester.widget<TextFormField>(findChatMessageInput());
          expect(input.enabled, isNot(false));
        });
      });
    });
  });
}
