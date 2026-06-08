import 'dart:async';

import 'package:meeting_place_chat/meeting_place_chat.dart';

class FakeChatWithMessages implements Chat {
  FakeChatWithMessages(this._messages);

  final List<ChatItem> _messages;

  @override
  String get id => 'fake-chat-id';

  @override
  ChatStream? stream;

  @override
  List<ChatItem> get messages => _messages;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented '
      'in FakeChatWithMessages',
    );
  }
}

class FakeChat implements Chat {
  @override
  String get id => 'fake-chat-id';

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
      type: ChatItemType.message,
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented in FakeChat',
    );
  }
}

class FakeChatStream implements ChatStream {
  FakeChatStream(this._stream);

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
  Stream<StreamData> get stream => _stream;

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented in FakeChatStream',
    );
  }
}
