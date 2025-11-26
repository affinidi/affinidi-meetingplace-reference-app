import 'dart:async';

import 'package:async/async.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

/// Wraps real MeetingPlaceChatSDK to inject fake messages for testing.
///
/// We can't fully mock the SDK because `Chat` type isn't exported.
/// Instead, we delegate to the real SDK and intercept streams.
///
/// Inject test messages via `simulateIncomingTextMessage()`.
class ChatSDKTestWrapper implements MeetingPlaceChatSDK {
  ChatSDKTestWrapper(this._realSdk);

  final MeetingPlaceChatSDK _realSdk;
  final StreamController<StreamData> _fakeMessageController =
      StreamController<StreamData>.broadcast();

  final List<Map<String, dynamic>> sendEffectCalls = [];
  final List<Map<String, dynamic>> sendTextMessageCalls = [];
  final List<Map<String, dynamic>> reactOnMessageCalls = [];

  @override
  Future<ChatStream?> get chatStreamSubscription async {
    // Get the real stream from the SDK
    final realStream = await _realSdk.chatStreamSubscription;
    if (realStream == null) return null;

    // Create a merged stream that combines real messages and fake messages
    return _MergedChatStream(realStream, _fakeMessageController.stream);
  }

  /// Simulates receiving an incoming text message.
  void simulateIncomingTextMessage({
    required String text,
    required String senderDid,
    required String recipientDid,
    String? messageId,
  }) {
    final now = DateTime.now();
    final id = messageId ?? 'incoming-${now.millisecondsSinceEpoch}';

    final message = Message(
      chatId: 'fake-chat-id',
      messageId: id,
      value: text,
      dateCreated: now,
      status: ChatItemStatus.received,
      isFromMe: false,
      senderDid: senderDid,
      attachments: [],
    );

    final plainTextMessage = PlainTextMessage(
      id: id,
      type: Uri.parse('https://affinidi.com/chat/1.0/message'),
      body: {
        'text': text,
        'timestamp': now.toIso8601String(),
      },
      from: senderDid,
      to: [recipientDid],
      createdTime: now,
    );

    _fakeMessageController.add(
      StreamData(
        plainTextMessage: plainTextMessage,
        chatItem: message,
      ),
    );
  }

  /// Simulates receiving an effect (balloons, confetti, etc.) by injecting it
  ///  into the stream.
  void simulateIncomingEffect({
    required Effect effect,
    required String senderDid,
    required String recipientDid,
    String? messageId,
  }) {
    final now = DateTime.now();
    final id = messageId ?? 'effect-${now.millisecondsSinceEpoch}';

    final plainTextMessage = PlainTextMessage(
      id: id,
      type: Uri.parse('https://affinidi.com/chat/1.0/effect'),
      body: {
        'effect': effect.name,
        'timestamp': now.toIso8601String(),
      },
      from: senderDid,
      to: [recipientDid],
      createdTime: now,
    );

    _fakeMessageController.add(
      StreamData(
        plainTextMessage: plainTextMessage,
        chatItem: null,
      ),
    );
  }

  void dispose() {
    _fakeMessageController.close();
  }

  @override
  void endChatSession() => _realSdk.endChatSession();

  @override
  Future<Message> sendTextMessage(String text,
      {List<Attachment>? attachments}) async {
    sendTextMessageCalls.add({
      'text': text,
      'attachments': attachments,
    });
    return _realSdk.sendTextMessage(text, attachments: attachments);
  }

  @override
  Future<void> reactOnMessage(Message message,
      {required String reaction}) async {
    reactOnMessageCalls.add({
      'message': message,
      'reaction': reaction,
    });
    return _realSdk.reactOnMessage(message, reaction: reaction);
  }

  @override
  Future<void> sendEffect(Effect effect) async {
    sendEffectCalls.add({
      'effect': effect,
    });
    return _realSdk.sendEffect(effect);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #startChatSession) {
      return _realSdk.startChatSession();
    }
    return super.noSuchMethod(invocation);
  }
}

/// A ChatStream that merges messages from both the real SDK and injected
/// fake messages.
class _MergedChatStream implements ChatStream {
  _MergedChatStream(this._realStream, this._fakeStream);

  final ChatStream _realStream;
  final Stream<StreamData> _fakeStream;
  StreamSubscription<StreamData>? _mergedSubscription;

  @override
  ChatStream listen(
    void Function(StreamData) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    // Merge the real stream and fake stream
    // When either emits data, forward it to the listener
    final mergedStream = StreamGroup.merge([
      _realStream._toStream(),
      _fakeStream,
    ]);

    _mergedSubscription = mergedStream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );

    return this;
  }

  @override
  Future<void> dispose() async {
    await _mergedSubscription?.cancel();
    _realStream.dispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented in _MergedChatStream',
    );
  }
}

// Extension to convert ChatStream to Stream<StreamData>
extension _ChatStreamExt on ChatStream {
  Stream<StreamData> _toStream() {
    final controller = StreamController<StreamData>();
    listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );
    return controller.stream;
  }
}

/// A fake implementation of ChatStream for testing.
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
  Future<void> dispose() async {
    await _subscription?.cancel();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
        'Method ${invocation.memberName} not implemented in FakeChatStream');
  }
}
