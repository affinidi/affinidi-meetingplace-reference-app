import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

        await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
        await _simulateIncomingMessage(tester, chatSdk, 'Incoming message');

        await tester.longPress(find.text('Incoming message'));
        await tester.pumpAndSettle();

        expect(find.text(l10n.chatMessageActionEdit), findsNothing);
      });

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
      });
    });
  });
}
