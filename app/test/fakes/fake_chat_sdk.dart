import 'dart:async';

import 'package:async/async.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

/// A wrapper around a real MeetingPlaceChatSDK that allows injecting fake messages.
///
/// **Why this approach?**
/// - We can't fake MeetingPlaceChatSDK entirely because `startChatSession()` returns
///   a `Chat` type that isn't exported from the package
/// - Instead, we wrap the REAL SDK and delegate all calls to it (no type issues!)
/// - We only intercept `chatStreamSubscription` to merge real and fake messages
///
/// **Current status:** Ready to use, but requires provider refactoring to inject.
///
/// This wrapper:
/// - Delegates all method calls to the real SDK (including startChatSession)
/// - Intercepts the chatStreamSubscription to merge real messages with fake ones
/// - Allows tests to simulate incoming messages via simulateIncomingTextMessage()
///
/// Usage example:
/// ```dart
/// // In tests, after the real SDK is created by the provider:
/// final realSdk = await ref.read(chatSdkProvider(channel).future);
/// final wrapper = ChatSDKTestWrapper(realSdk);
///
/// // Now you can inject fake messages:
/// wrapper.simulateIncomingTextMessage(
///   text: 'Hello!',
///   senderDid: 'sender-did',
///   recipientDid: 'recipient-did',
/// );
/// ```
class ChatSDKTestWrapper implements MeetingPlaceChatSDK {
  ChatSDKTestWrapper(this._realSdk);

  final MeetingPlaceChatSDK _realSdk;
  final StreamController<StreamData> _fakeMessageController =
      StreamController<StreamData>.broadcast();

  // Track method calls for testing (similar to FakeMeetingPlaceSDK)
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

  /// Simulates receiving an incoming text message by injecting it into the stream.
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

  /// Simulates receiving an effect (balloons, confetti, etc.) by injecting it into the stream.
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

  // Delegate all other SDK methods to the real implementation
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
  Future<void> sendChatActivity() => _realSdk.sendChatActivity();

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
  Future<void> approveConnectionRequest(ConciergeMessage message) =>
      _realSdk.approveConnectionRequest(message);

  @override
  Future<void> rejectConnectionRequest(ConciergeMessage message) =>
      _realSdk.rejectConnectionRequest(message);

  @override
  Future<void> sendChatContactDetailsUpdate(ConciergeMessage message) =>
      _realSdk.sendChatContactDetailsUpdate(message);

  @override
  Future<void> rejectChatContactDetailsUpdate(ConciergeMessage message) =>
      _realSdk.rejectChatContactDetailsUpdate(message);

  @override
  Future<void> sendChatDeliveredMessage(PlainTextMessage message) =>
      _realSdk.sendChatDeliveredMessage(message);

  @override
  Future<void> sendChatPresence() => _realSdk.sendChatPresence();

  @override
  Future<ChatItem?> getMessageById(String messageId) =>
      _realSdk.getMessageById(messageId);

  @override
  Future<List<Message>> fetchNewMessages() => _realSdk.fetchNewMessages();

  // Use noSuchMethod for startChatSession since we can't match the Chat return type
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #startChatSession) {
      return _realSdk.startChatSession();
    }
    return super.noSuchMethod(invocation);
  }
}

/// A ChatStream that merges messages from both the real SDK and injected fake messages.
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
      (data) => controller.add(data),
      onError: (Object error) => controller.addError(error),
      onDone: () => controller.close(),
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
