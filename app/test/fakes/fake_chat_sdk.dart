import 'dart:async';

import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_chat/src/sdk/chat.dart';

class FakeChatSdk implements MeetingPlaceChatSDK {
  int _chatSessionStartedCalls = 0;
  final StreamController<StreamData> _streamController =
      StreamController<StreamData>.broadcast();

  final List<Map<String, dynamic>> sendTextMessageCalls = [];
  final List<Map<String, dynamic>> sendEffectCalls = [];
  final List<Map<String, dynamic>> reactOnMessageCalls = [];

  int get startChatSessionCallCount => _chatSessionStartedCalls;

  /// Simulates an incoming text message by emitting it through the stream
  void simulateIncomingTextMessage({
    required String text,
    required String recipientDid,
    List<Attachment>? attachments,
  }) {
    final message = Message(
      chatId: 'fake-chat-id',
      messageId: 'msg-incoming-${DateTime.now().millisecondsSinceEpoch}',
      value: text,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.confirmed,
      isFromMe: false,
      senderDid: 'fake-sender-did',
      attachments: attachments ?? [],
    );

    final plainTextMessage = PlainTextMessage(
      id: message.messageId,
      type: Uri.parse('https://affinidi.com/chat/1.0/message'),
      body: {
        'text': text,
        'timestamp': message.dateCreated.toIso8601String(),
      },
      from: 'fake-sender-did',
      to: [recipientDid],
      createdTime: message.dateCreated,
    );

    _streamController.add(
      StreamData(
        plainTextMessage: plainTextMessage,
        chatItem: message,
      ),
    );
  }

  @override
  Future<ChatStream?> get chatStreamSubscription async {
    return _FakeChatStream(_streamController.stream);
  }

  @override
  void endChatSession() {}

  @override
  Future<void> reactOnMessage(Message message,
      {required String reaction}) async {
    reactOnMessageCalls.add({
      'message': message,
      'reaction': reaction,
    });
  }

  @override
  Future<void> sendChatActivity() async {
    // No-op for tests - just return successfully
  }

  @override
  Future<void> sendChatContactDetailsUpdate(ConciergeMessage message) async {
    // No-op for tests
  }

  @override
  Future<void> sendChatDeliveredMessage(PlainTextMessage message) async {
    // No-op for tests
  }

  @override
  Future<void> sendChatPresence() async {
    // No-op for tests
  }

  @override
  Future<void> sendEffect(Effect effect) async {
    sendEffectCalls.add({'effect': effect});
  }

  @override
  Future<void> sendProfileHash() async {
    // No-op for tests
  }

  @override
  Future<Message> sendTextMessage(String text,
      {List<Attachment>? attachments}) async {
    // Track the call
    sendTextMessageCalls.add({
      'text': text,
      'attachments': attachments,
    });

    final message = Message(
      chatId: 'fake-chat-id',
      messageId: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      value: text,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.queued,
      isFromMe: true,
      senderDid: 'fake-sender-did',
      attachments: attachments ?? [],
    );

    return message;
  }

  @override
  Future<Chat> startChatSession() async {
    _chatSessionStartedCalls = 1;
    return FakeChat();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented in FakeChatSdk',
    );
  }
}

class FakeChat implements Chat {
  @override
  ChatStream? stream;

  @override
  List<ChatItem> get messages => [
        ChatItem(
            chatId: 'chatId',
            messageId: 'messageId',
            senderDid: 'senderDid',
            isFromMe: true,
            dateCreated: DateTime.now(),
            status: ChatItemStatus.confirmed,
            type: ChatItemType.message)
      ];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented in FakeChat',
    );
  }
}

class _FakeChatStream implements ChatStream {
  _FakeChatStream(this._stream);

  final Stream<StreamData> _stream;
  StreamSubscription<StreamData>? _subscription;

  @override
  ChatStream listen(
    void Function(StreamData) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    _subscription = _stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    return this;
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented in _FakeChatStream',
    );
  }
}
