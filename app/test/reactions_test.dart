import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

import 'fakes/fake_chat_sdk.dart';
import 'utils/app.dart';

// The local user's DID in the chat harness is the channel's
// permanentChannelDid, which resolves to the individual contact's channelDid.
const _myDid = 'did:key:individual-channel';
const _otherDid = 'did:key:reactor-bob';
const _anotherDid = 'did:key:reactor-carol';

Message _messageWith(
  List<MessageReaction> reactions, {
  bool isFromMe = false,
}) => Message(
  chatId: 'fake-chat-id',
  messageId: 'msg-with-reactions',
  value: 'React to me',
  dateCreated: DateTime.now(),
  status: isFromMe ? ChatItemStatus.sent : ChatItemStatus.received,
  isFromMe: isFromMe,
  senderDid: isFromMe ? _myDid : _otherDid,
  attachments: const [],
  reactions: reactions,
);

Future<void> _openChat(
  WidgetTester tester,
  FakeChatSdk chatSdk,
  Message message,
) async {
  chatSdk.sessionMessages = [message];
  await navigateToChat(tester, chatSdk: chatSdk);
}

// Background colour of the reaction chip that contains [emoji].
Color _chipColor(WidgetTester tester, String emoji) {
  final container = tester.widget<Container>(
    find.ancestor(of: find.text(emoji), matching: find.byType(Container)).first,
  );
  return (container.decoration! as BoxDecoration).color!;
}

void main() {
  group('reaction chips', () {
    testWidgets('group the same emoji from different people into one count', (
      tester,
    ) async {
      final chatSdk = FakeChatSdk();
      await _openChat(
        tester,
        chatSdk,
        _messageWith(const [
          MessageReaction(emoji: '❤', senderDid: _otherDid),
          MessageReaction(emoji: '❤', senderDid: _anotherDid),
        ]),
      );

      expect(find.text('❤'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('show no counter for a single reaction', (tester) async {
      final chatSdk = FakeChatSdk();
      await _openChat(
        tester,
        chatSdk,
        _messageWith(const [MessageReaction(emoji: '❤', senderDid: _otherDid)]),
      );

      expect(find.text('❤'), findsOneWidget);
      final chips = find.ancestor(
        of: find.text('❤'),
        matching: find.byType(Wrap),
      );
      expect(
        find.descendant(
          of: chips,
          matching: find.textContaining(RegExp(r'^\d+$')),
        ),
        findsNothing,
      );
    });

    testWidgets('visually distinguish my reaction from others', (tester) async {
      final chatSdk = FakeChatSdk();
      await _openChat(
        tester,
        chatSdk,
        _messageWith(const [
          MessageReaction(emoji: '😀', senderDid: _myDid),
          MessageReaction(emoji: '❤', senderDid: _otherDid),
        ]),
      );

      expect(_chipColor(tester, '😀'), isNot(_chipColor(tester, '❤')));
    });
  });

  group('reacting via a chip', () {
    testWidgets('tapping a reaction on an incoming message toggles mine', (
      tester,
    ) async {
      final chatSdk = FakeChatSdk();
      await _openChat(
        tester,
        chatSdk,
        _messageWith(const [MessageReaction(emoji: '❤', senderDid: _otherDid)]),
      );

      await tester.tap(find.text('❤'));
      await tester.pumpAndSettle();

      expect(chatSdk.reactOnMessageCalls, hasLength(1));
      expect(chatSdk.reactOnMessageCalls.first['reaction'], '❤');
    });

    testWidgets('reactions on my own message are read-only', (tester) async {
      final chatSdk = FakeChatSdk();
      await _openChat(
        tester,
        chatSdk,
        _messageWith(const [
          MessageReaction(emoji: '❤', senderDid: _otherDid),
        ], isFromMe: true),
      );

      await tester.tap(find.text('❤'));
      await tester.pumpAndSettle();

      expect(chatSdk.reactOnMessageCalls, isEmpty);
    });
  });
}
