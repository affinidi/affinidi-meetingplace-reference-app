import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:mpx_flutter_reference_app/application/services/personal_ai_service/personal_ai_service.dart';
import 'package:mpx_flutter_reference_app/application/services/personal_ai_service/personal_ai_service_state.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'utils/app.dart';

Future<void> _simulateSentMessage(
  WidgetTester tester,
  FakeChatSdk chatSdk,
  String text,
) async {
  chatSdk.simulateSentTextMessage(text: text);
  await tester.pumpAndSettle();
}

Future<void> _simulateIncomingMessage(
  WidgetTester tester,
  FakeChatSdk chatSdk,
  String text,
) async {
  chatSdk.simulateIncomingTextMessage(
    text: text,
    recipientDid: FakeChannels.individualChannel.permanentChannelDid!,
  );
  await tester.pumpAndSettle();
}

void main() {
  const contactId = 'individual-contact-id';
  const readyPersonalAiState = PersonalAiServiceState(
    status: PersonalAiSetupStatus.ready,
    showSetupPrompt: false,
    promptDismissed: false,
    contextProvisioned: true,
    contextUploading: false,
  );

  group('chat message edit', () {
    group('when long pressing an own message', () {
      testWidgets('shows the Edit action in the bottom sheet', (tester) async {
        final chatSdk = FakeChatSdk();
        final l10n = await getL10n();

        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
        await _simulateSentMessage(tester, chatSdk, 'Hello world');

        await tester.longPress(find.text('Hello world'));
        await tester.pumpAndSettle();

        expect(find.text(l10n.chatMessageActionEdit), findsOneWidget);
      });

      testWidgets('does not show the Edit action for incoming messages', (
        tester,
      ) async {
        final chatSdk = FakeChatSdk();
        final l10n = await getL10n();

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          personalAiState: readyPersonalAiState,
        );
        await _simulateIncomingMessage(tester, chatSdk, 'Incoming message');

        await tester.longPress(find.text('Incoming message'));
        await tester.pumpAndSettle();

        expect(find.text(l10n.chatMessageActionEdit), findsNothing);
      });

      testWidgets('shows ask for suggestion for incoming messages', (
        tester,
      ) async {
        final chatSdk = FakeChatSdk();
        final l10n = await getL10n();

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          personalAiState: readyPersonalAiState,
        );
        await _simulateIncomingMessage(tester, chatSdk, 'Incoming message');

        await tester.longPress(find.text('Incoming message'));
        await tester.pumpAndSettle();

        expect(find.text(l10n.chatMessageActionAskSuggestion), findsOneWidget);
      });

      testWidgets('does not show ask for suggestion for own messages', (
        tester,
      ) async {
        final chatSdk = FakeChatSdk();
        final l10n = await getL10n();

        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
        await _simulateSentMessage(tester, chatSdk, 'My message');

        await tester.longPress(find.text('My message'));
        await tester.pumpAndSettle();

        expect(find.text(l10n.chatMessageActionAskSuggestion), findsNothing);
      });

      testWidgets('tapping ask for suggestion calls the SDK and dismisses it', (
        tester,
      ) async {
        final chatSdk = FakeChatSdk();
        final l10n = await getL10n();

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          personalAiState: readyPersonalAiState,
        );
        await _simulateIncomingMessage(tester, chatSdk, 'Incoming message');

        await tester.longPress(find.text('Incoming message'));
        await tester.pumpAndSettle();

        await tester.tap(find.text(l10n.chatMessageActionAskSuggestion));
        await tester.pumpAndSettle();

        expect(chatSdk.sendSuggestionRequestCalls, hasLength(1));
        expect(
          chatSdk.sendSuggestionRequestCalls.first['text'],
          'Incoming message',
        );
        expect(find.text(l10n.chatMessageActionAskSuggestion), findsNothing);
      });

      testWidgets('does not show ask for suggestion when unsupported', (
        tester,
      ) async {
        final chatSdk = FakeChatSdk(
          capabilities: const TransportCapabilities({
            ChatFeature.textMessaging,
            ChatFeature.reactions,
          }),
        );
        final l10n = await getL10n();

        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
        await _simulateIncomingMessage(tester, chatSdk, 'Incoming message');

        await tester.longPress(find.text('Incoming message'));
        await tester.pumpAndSettle();

        expect(find.text(l10n.chatMessageActionAskSuggestion), findsNothing);
      });

      testWidgets('does not show ask for suggestion when agent is not ready', (
        tester,
      ) async {
        final chatSdk = FakeChatSdk();
        final l10n = await getL10n();

        await navigateToChat(
          tester,
          contactId: contactId,
          chatSdk: chatSdk,
          personalAiState: const PersonalAiServiceState.initial(),
        );
        await _simulateIncomingMessage(tester, chatSdk, 'Incoming message');

        await tester.longPress(find.text('Incoming message'));
        await tester.pumpAndSettle();

        expect(find.text(l10n.chatMessageActionAskSuggestion), findsNothing);
      });

      testWidgets(
        '''clears the current long-press selection when agent setup becomes ready''',
        (tester) async {
          final chatSdk = FakeChatSdk();
          final l10n = await getL10n();

          await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
          await _simulateIncomingMessage(tester, chatSdk, 'Incoming message');

          await tester.longPress(find.text('Incoming message'));
          await tester.pumpAndSettle();

          expect(find.text(l10n.chatMessageActionAskSuggestion), findsNothing);
          expect(find.text('❤'), findsOneWidget);

          final context = tester.element(find.byType(Scaffold).first);
          final container = ProviderScope.containerOf(context, listen: false);

          container.read(personalAiServiceProvider.notifier).state =
              readyPersonalAiState;
          await tester.pumpAndSettle();

          expect(find.text(l10n.chatMessageActionAskSuggestion), findsNothing);
          expect(find.text('❤'), findsNothing);

          await tester.longPress(find.text('Incoming message'));
          await tester.pumpAndSettle();

          expect(
            find.text(l10n.chatMessageActionAskSuggestion),
            findsOneWidget,
          );
        },
      );

      group('and tapping Edit', () {
        testWidgets('opens dialog pre-filled with current message text', (
          tester,
        ) async {
          final chatSdk = FakeChatSdk();
          final l10n = await getL10n();
          const originalText = 'My original message';

          await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
          await _simulateSentMessage(tester, chatSdk, originalText);

          await tester.longPress(find.text(originalText));
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.chatMessageActionEdit));
          await tester.pumpAndSettle();

          final textField = tester.widget<TextField>(
            find.byType(TextField).last,
          );
          expect(textField.controller?.text, originalText);
        });

        testWidgets('saving changed text calls editTextMessage on the SDK', (
          tester,
        ) async {
          final chatSdk = FakeChatSdk();
          final l10n = await getL10n();
          const originalText = 'Original text';
          const editedText = 'Edited text';

          await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
          await _simulateSentMessage(tester, chatSdk, originalText);

          await tester.longPress(find.text(originalText));
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.chatMessageActionEdit));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField).last, editedText);
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.chatMessageEditSave));
          await tester.pumpAndSettle();

          expect(chatSdk.editTextMessageCalls, hasLength(1));
          expect(chatSdk.editTextMessageCalls.first['newText'], editedText);
        });

        testWidgets('saving unchanged text does not call editTextMessage', (
          tester,
        ) async {
          final chatSdk = FakeChatSdk();
          final l10n = await getL10n();
          const originalText = 'Unchanged message';

          await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
          await _simulateSentMessage(tester, chatSdk, originalText);

          await tester.longPress(find.text(originalText));
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.chatMessageActionEdit));
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.chatMessageEditSave));
          await tester.pumpAndSettle();

          expect(chatSdk.editTextMessageCalls, isEmpty);
        });

        testWidgets('cancelling does not call editTextMessage', (tester) async {
          final chatSdk = FakeChatSdk();
          final l10n = await getL10n();
          const originalText = 'Message to not edit';

          await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
          await _simulateSentMessage(tester, chatSdk, originalText);

          await tester.longPress(find.text(originalText));
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.chatMessageActionEdit));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField).last, 'Something new');
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.generalCancel));
          await tester.pumpAndSettle();

          expect(chatSdk.editTextMessageCalls, isEmpty);
        });

        testWidgets('shows edited indicator after saving an edit', (
          tester,
        ) async {
          final chatSdk = FakeChatSdk();
          final l10n = await getL10n();
          const originalText = 'Original message';
          const editedText = 'Updated message';

          await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
          await _simulateSentMessage(tester, chatSdk, originalText);

          await tester.longPress(find.text(originalText));
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.chatMessageActionEdit));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField).last, editedText);
          await tester.pumpAndSettle();

          await tester.tap(find.text(l10n.chatMessageEditSave));
          await tester.pumpAndSettle();

          expect(find.text(l10n.chatMessageEditedLabel), findsOneWidget);
        });
      });
    });

    group('when opening chat with previously edited messages', () {
      testWidgets('shows edited indicator for message with editedAt', (
        tester,
      ) async {
        final chatSdk = FakeChatSdk();
        final l10n = await getL10n();

        chatSdk.sessionMessages = [
          Message(
            chatId: 'fake-chat-id',
            messageId: 'msg-edited',
            value: 'A previously edited message',
            dateCreated: DateTime.now().subtract(const Duration(minutes: 5)),
            status: ChatItemStatus.confirmed,
            isFromMe: true,
            senderDid: 'fake-my-did',
            attachments: [],
            editedAt: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
        ];

        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);

        expect(find.text(l10n.chatMessageEditedLabel), findsOneWidget);
      });

      testWidgets('does not show edited indicator for unedited message', (
        tester,
      ) async {
        final chatSdk = FakeChatSdk();
        final l10n = await getL10n();

        chatSdk.sessionMessages = [
          Message(
            chatId: 'fake-chat-id',
            messageId: 'msg-not-edited',
            value: 'An unedited message',
            dateCreated: DateTime.now().subtract(const Duration(minutes: 5)),
            status: ChatItemStatus.confirmed,
            isFromMe: true,
            senderDid: 'fake-my-did',
            attachments: [],
          ),
        ];

        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);

        expect(find.text(l10n.chatMessageEditedLabel), findsNothing);
      });
    });
  });
}
