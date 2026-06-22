import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

class FakeNoOpChatRepository implements chat.ChatRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) async {}
}

class FakeInMemoryChatRepository implements chat.ChatRepository {
  final List<chat.ChatItem> createdMessages = [];
  final Map<String, chat.ChatItem> _store = {};
  final Map<String, String?> _syncMarker = {};

  @override
  Future<chat.ChatItem> createMessage(chat.ChatItem message) async {
    createdMessages.add(message);
    _store['${message.chatId}_${message.messageId}'] = message;
    return message;
  }

  @override
  Future<chat.ChatItem> updateMesssage(chat.ChatItem message) async {
    _store['${message.chatId}_${message.messageId}'] = message;
    return message;
  }

  @override
  Future<List<chat.ChatItem>> listMessages(String chatId) async =>
      _store.values.where((m) => m.chatId == chatId).toList();

  @override
  Future<chat.ChatItem?> getMessage({
    required String chatId,
    required String messageId,
  }) async => _store['${chatId}_$messageId'];

  @override
  Future<String?> getSyncMarker(String chatId) async {
    return _syncMarker[chatId];
  }

  @override
  Future<void> updateSyncMarker({
    required String chatId,
    required String eventId,
  }) async {
    _syncMarker[chatId] = eventId;
  }
}
