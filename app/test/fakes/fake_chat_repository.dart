import 'package:meeting_place_chat/meeting_place_chat.dart';

class FakeChatRepository implements ChatRepository {
  final Map<String, List<ChatItem>> _items = {};

  @override
  Future<ChatItem> createMessage(ChatItem item) async {
    final chatId = _getChatId(item);
    if (!_items.containsKey(chatId)) {
      _items[chatId] = [];
    }
    _items[chatId]!.add(item);
    return item;
  }

  @override
  Future<ChatItem?> getMessage({
    required String chatId,
    required String messageId,
  }) async {
    final items = _items[chatId];
    if (items == null) return null;

    return items.where((item) => item.messageId == messageId).firstOrNull;
  }

  @override
  Future<List<ChatItem>> listMessages(String chatId) async {
    return _items[chatId] ?? [];
  }

  @override
  Future<ChatItem> updateMesssage(ChatItem item) async {
    final chatId = _getChatId(item);
    final items = _items[chatId];
    if (items != null) {
      final index = items.indexWhere((i) => i.messageId == item.messageId);
      if (index != -1) {
        items[index] = item;
      }
    }
    return item;
  }

  String _getChatId(ChatItem item) {
    // Try to extract a chat identifier from the item
    // This is a simple implementation that uses messageId as a fallback
    return item.messageId;
  }
}
