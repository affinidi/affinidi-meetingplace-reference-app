import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

import 'fakes/fake_channels.dart';
import 'fakes/fake_chat_sdk.dart';
import 'utils/app.dart';

Future<Message> _simulateIncomingMessage(
  WidgetTester tester,
  FakeChatSdk chatSdk,
  String text,
) async {
  final message = chatSdk.simulateIncomingTextMessage(
    text: text,
    recipientDid: FakeChannels.individualChannel.permanentChannelDid!,
  );
  await tester.pumpAndSettle();
  return message;
}

Future<void> _simulateIncomingSuggestion(
  WidgetTester tester,
  FakeChatSdk chatSdk, {
  required String relatedMessageId,
  required String text,
}) async {
  chatSdk.simulateIncomingSuggestion(
    relatedMessageId: relatedMessageId,
    text: text,
    recipientDid: FakeChannels.individualChannel.permanentChannelDid!,
  );
  await tester.pumpAndSettle();
}

void main() {
  const contactId = 'individual-contact-id';

  group('chat suggestions', () {
    testWidgets('shows the latest incoming suggestion under its message', (
      tester,
    ) async {
      final chatSdk = FakeChatSdk();

      await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
      final message = await _simulateIncomingMessage(
        tester,
        chatSdk,
        'Incoming message',
      );

      await _simulateIncomingSuggestion(
        tester,
        chatSdk,
        relatedMessageId: message.messageId,
        text: 'Use a shorter reply',
      );

      expect(find.text('Use a shorter reply'), findsOneWidget);
    });

    testWidgets('replaces the visible suggestion with a newer one', (
      tester,
    ) async {
      final chatSdk = FakeChatSdk();

      await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
      final firstMessage = await _simulateIncomingMessage(
        tester,
        chatSdk,
        'First incoming message',
      );
      final secondMessage = await _simulateIncomingMessage(
        tester,
        chatSdk,
        'Second incoming message',
      );

      await _simulateIncomingSuggestion(
        tester,
        chatSdk,
        relatedMessageId: firstMessage.messageId,
        text: 'First suggestion',
      );
      expect(find.text('First suggestion'), findsOneWidget);

      await _simulateIncomingSuggestion(
        tester,
        chatSdk,
        relatedMessageId: secondMessage.messageId,
        text: 'Second suggestion',
      );

      expect(find.text('First suggestion'), findsNothing);
      expect(find.text('Second suggestion'), findsOneWidget);
    });

    testWidgets('ignores suggestions for messages not in the current list', (
      tester,
    ) async {
      final chatSdk = FakeChatSdk();

      await navigateToChat(tester, contactId: contactId, chatSdk: chatSdk);
      await _simulateIncomingMessage(tester, chatSdk, 'Incoming message');

      await _simulateIncomingSuggestion(
        tester,
        chatSdk,
        relatedMessageId: 'missing-message-id',
        text: 'Orphaned suggestion',
      );

      expect(find.text('Orphaned suggestion'), findsNothing);
    });
  });
}
