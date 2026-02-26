import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/chat_items_extensions.dart';

Message _message(String id, DateTime dateCreated) {
  return Message(
    chatId: 'chat-id',
    messageId: id,
    value: id,
    dateCreated: dateCreated,
    status: ChatItemStatus.confirmed,
    isFromMe: true,
    senderDid: 'did:key:sender',
    attachments: const <Attachment>[],
  );
}

void main() {
  group('ChatItemListExtensions.insertSorted', () {
    test('inserts into an empty list', () {
      final item = _message('m1', DateTime(2025, 1, 1, 10));

      final result = <ChatItem>[].insertSorted(item);

      expect(result, hasLength(1));
      expect((result.first as Message).messageId, 'm1');
    });

    test('inserts newest item at the beginning (newest -> oldest)', () {
      final t1 = DateTime(2025, 1, 1, 10, 0, 0);
      final t2 = DateTime(2025, 1, 1, 10, 1, 0);
      final t3 = DateTime(2025, 1, 1, 10, 2, 0);
      final t4 = DateTime(2025, 1, 1, 10, 3, 0);

      final original = <ChatItem>[
        _message('m3', t3),
        _message('m2', t2),
        _message('m1', t1),
      ];

      final result = original.insertSorted(_message('m4', t4));

      expect(
        original.map((e) => (e as Message).messageId).toList(),
        ['m3', 'm2', 'm1'],
      );
      expect(
        result.map((e) => (e as Message).messageId).toList(),
        ['m4', 'm3', 'm2', 'm1'],
      );
    });

    test('inserts oldest item at the end (newest -> oldest)', () {
      final t0 = DateTime(2025, 1, 1, 9, 59, 0);
      final t1 = DateTime(2025, 1, 1, 10, 0, 0);
      final t2 = DateTime(2025, 1, 1, 10, 1, 0);
      final t3 = DateTime(2025, 1, 1, 10, 2, 0);

      final original = <ChatItem>[
        _message('m3', t3),
        _message('m2', t2),
        _message('m1', t1),
      ];

      final result = original.insertSorted(_message('m0', t0));

      expect(
        result.map((e) => (e as Message).messageId).toList(),
        ['m3', 'm2', 'm1', 'm0'],
      );
    });

    test('inserts item into the middle (newest -> oldest)', () {
      final t1 = DateTime(2025, 1, 1, 10, 0, 0);
      final t2 = DateTime(2025, 1, 1, 10, 1, 0);
      final t25 = DateTime(2025, 1, 1, 10, 1, 30);
      final t3 = DateTime(2025, 1, 1, 10, 2, 0);

      final original = <ChatItem>[
        _message('m3', t3),
        _message('m2', t2),
        _message('m1', t1),
      ];

      final result = original.insertSorted(_message('m25', t25));

      expect(
        result.map((e) => (e as Message).messageId).toList(),
        ['m3', 'm25', 'm2', 'm1'],
      );
    });

    test('inserts item after all items with same timestamp', () {
      final t1 = DateTime(2025, 1, 1, 10, 0, 0);
      final t2 = DateTime(2025, 1, 1, 10, 1, 0);
      final t3 = DateTime(2025, 1, 1, 10, 2, 0);

      final original = <ChatItem>[
        _message('m3', t3),
        _message('m2a', t2),
        _message('m2b', t2),
        _message('m1', t1),
      ];

      final result = original.insertSorted(_message('m2new', t2));

      expect(
        result.map((e) => (e as Message).messageId).toList(),
        ['m3', 'm2a', 'm2b', 'm2new', 'm1'],
      );
    });
  });
}
