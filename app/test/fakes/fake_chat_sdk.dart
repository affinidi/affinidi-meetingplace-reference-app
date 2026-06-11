import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart'
    show AttachmentFormat;
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

class FakeChatSdk implements MeetingPlaceChatSDK {
  int _chatSessionStartedCalls = 0;
  int _startedChatPresenceUpdates = 0;
  final StreamController<StreamData> _streamController =
      StreamController<StreamData>.broadcast();
  final List<StreamData> _bufferedEvents = [];
  bool _hasListener = false;

  void _emit(StreamData data) {
    if (_hasListener) {
      _streamController.add(data);
    } else {
      _bufferedEvents.add(data);
    }
  }

  bool chatActivitySent = false;
  ConciergeMessage? lastRejectedConnection;
  ConciergeMessage? lastApprovedConnection;
  ConciergeMessage? lastContactDetailsUpdateSent;
  ConciergeMessage? lastContactDetailsUpdateRejected;
  Message? lastReactionMessage;
  String? lastReaction;
  bool sessionEnded = false;
  String? lastEffectSent;
  bool shouldThrowOnStartSession = false;
  String? lastRemovedMemberDid;
  int removeMemberCallCount = 0;

  final List<Map<String, dynamic>> sendTextMessageCalls = [];
  final List<Map<String, dynamic>> sendMediaMessageCalls = [];
  final List<Map<String, dynamic>> sendEffectCalls = [];
  final List<Map<String, dynamic>> reactOnMessageCalls = [];
  final List<Map<String, dynamic>> editTextMessageCalls = [];
  final List<Map<String, dynamic>> approveConnectionRequestCalls = [];
  final List<Map<String, dynamic>> rejectConnectionRequestCalls = [];
  final List<Map<String, dynamic>> sendContactDetailsUpdateCalls = [];
  final List<Map<String, dynamic>> cancelUpdatingContactDetailsCalls = [];
  final Map<String, Uint8List> _downloadedMedia = {};

  int get startChatSessionCallCount => _chatSessionStartedCalls;
  int get startedChatPresenceUpdatesCount => _startedChatPresenceUpdates;

  /// Simulates an incoming text message by emitting it through the stream
  void simulateIncomingTextMessage({
    required String text,
    required String recipientDid,
    List<ChatAttachment>? attachments,
  }) {
    final transportId =
        'fake-transport-incoming-${DateTime.now().microsecondsSinceEpoch}';
    for (final attachment in attachments ?? const <ChatAttachment>[]) {
      attachment.transportId ??= transportId;
    }
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

    final chatEvent = UnhandledChatEvent(
      type: 'https://affinidi.com/chat/1.0/message',
      senderDid: 'fake-sender-did',
      body: {'text': text, 'timestamp': message.dateCreated.toIso8601String()},
      createdTime: message.dateCreated,
    );

    _emit(StreamData(event: chatEvent, chatItem: message));
  }

  /// Simulates an own (sent) text message by emitting it through the stream
  void simulateOwnTextMessage({
    required String text,
    required String recipientDid,
  }) {
    final message = Message(
      chatId: 'fake-chat-id',
      messageId: 'msg-own-${DateTime.now().millisecondsSinceEpoch}',
      value: text,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.sent,
      isFromMe: true,
      senderDid: 'fake-sender-did',
      attachments: [],
      transportId: 'transport-${DateTime.now().millisecondsSinceEpoch}',
    );

    _emit(StreamData(event: const ChatMessageEvent(), chatItem: message));
  }

  /// Simulates an incoming concierge message for join group requests
  /// Returns the created ConciergeMessage for verification in tests
  ConciergeMessage simulateJoinGroupRequest({
    required String memberName,
    required String senderDid,
    required String recipientDid,
  }) {
    final conciergeMessage = ConciergeMessage(
      chatId: 'fake-chat-id',
      messageId: 'concierge-${DateTime.now().millisecondsSinceEpoch}',
      senderDid: senderDid,
      isFromMe: false,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.userInput,
      data: {
        'contactCard': {
          'did': 'did:key:identity-id',
          'type': ContactCardType.individual.value,
          'contactInfo': {
            'n': {'given': memberName},
          },
        },
      },
      conciergeType: ConciergeMessageType.permissionToJoinGroup,
    );

    final chatEvent = UnhandledChatEvent(
      type: 'https://affinidi.com/chat/1.0/concierge',
      senderDid: senderDid,
      body: {
        'type': 'permissionToJoinGroup',
        'memberName': memberName,
        'timestamp': conciergeMessage.dateCreated.toIso8601String(),
      },
      createdTime: conciergeMessage.dateCreated,
    );

    _emit(StreamData(event: chatEvent, chatItem: conciergeMessage));

    return conciergeMessage;
  }

  /// Simulates a profile update request concierge message
  ConciergeMessage simulateProfileUpdateRequest({
    required String senderDid,
    required String recipientDid,
  }) {
    final conciergeMessage = ConciergeMessage(
      chatId: 'fake-chat-id',
      messageId: 'concierge-update-${DateTime.now().millisecondsSinceEpoch}',
      senderDid: senderDid,
      isFromMe: false,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.userInput,
      data: {},
      conciergeType: ConciergeMessageType.permissionToUpdateProfile,
    );

    final chatEvent = UnhandledChatEvent(
      type: 'https://affinidi.com/chat/1.0/concierge',
      senderDid: senderDid,
      body: {
        'type': 'permissionToUpdateProfile',
        'timestamp': conciergeMessage.dateCreated.toIso8601String(),
      },
      createdTime: conciergeMessage.dateCreated,
    );

    _emit(StreamData(event: chatEvent, chatItem: conciergeMessage));

    return conciergeMessage;
  }

  /// Simulates a member joining the group event
  EventMessage simulateMemberJoinedGroup({
    required String memberName,
    required String memberDid,
    required String senderDid,
    required String recipientDid,
  }) {
    final eventMessage = EventMessage(
      chatId: 'fake-chat-id',
      messageId: 'event-join-${DateTime.now().millisecondsSinceEpoch}',
      senderDid: senderDid,
      isFromMe: false,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.received,
      eventType: EventMessageType.groupMemberJoinedGroup,
      data: {
        'memberDid': memberDid,
        'contactCard': {
          'did': 'did:key:identity-id',
          'type': ContactCardType.individual.value,
          'contactInfo': {
            'n': {'given': memberName},
          },
        },
      },
    );

    final chatEvent = UnhandledChatEvent(
      type: 'https://affinidi.com/chat/1.0/event',
      senderDid: senderDid,
      body: {
        'type': 'groupMemberJoinedGroup',
        'memberName': memberName,
        'timestamp': eventMessage.dateCreated.toIso8601String(),
      },
      createdTime: eventMessage.dateCreated,
    );

    _emit(StreamData(event: chatEvent, chatItem: eventMessage));

    return eventMessage;
  }

  /// Simulates a member leaving the group event
  EventMessage simulateMemberLeftGroup({
    required String memberName,
    required String memberDid,
    required String senderDid,
    required String recipientDid,
  }) {
    final eventMessage = EventMessage(
      chatId: 'fake-chat-id',
      messageId: 'event-leave-${DateTime.now().millisecondsSinceEpoch}',
      senderDid: senderDid,
      isFromMe: false,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.received,
      eventType: EventMessageType.groupMemberLeftGroup,
      data: {
        'memberDid': memberDid,
        'contactCard': {
          'did': 'did:key:identity-id',
          'type': ContactCardType.individual.value,
          'contactInfo': {
            'n': {'given': memberName},
          },
        },
      },
    );

    final chatEvent = UnhandledChatEvent(
      type: 'https://affinidi.com/chat/1.0/event',
      senderDid: senderDid,
      body: {
        'type': 'groupMemberLeftGroup',
        'memberName': memberName,
        'timestamp': eventMessage.dateCreated.toIso8601String(),
      },
      createdTime: eventMessage.dateCreated,
    );

    _emit(StreamData(event: chatEvent, chatItem: eventMessage));

    return eventMessage;
  }

  /// Simulates a group deleted event
  EventMessage simulateGroupDeleted({
    required String senderDid,
    required String recipientDid,
  }) {
    final eventMessage = EventMessage(
      chatId: 'fake-chat-id',
      messageId: 'event-deleted-${DateTime.now().millisecondsSinceEpoch}',
      senderDid: senderDid,
      isFromMe: false,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.received,
      eventType: EventMessageType.groupDeleted,
      data: {},
    );

    final chatEvent = UnhandledChatEvent(
      type: 'https://affinidi.com/chat/1.0/event',
      senderDid: senderDid,
      body: {
        'type': 'groupDeleted',
        'timestamp': eventMessage.dateCreated.toIso8601String(),
      },
      createdTime: eventMessage.dateCreated,
    );

    _emit(StreamData(event: chatEvent, chatItem: eventMessage));

    return eventMessage;
  }

  ConciergeMessage fakeConciergeMessage() {
    return ConciergeMessage(
      chatId: 'fake-chat-id',
      messageId: 'fake-concierge-message-id',
      senderDid: 'fake-sender-did',
      isFromMe: false,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.userInput,
      data: {},
      conciergeType: ConciergeMessageType.permissionToJoinGroup,
    );
  }

  Message fakeMessage() {
    return Message(
      chatId: 'fake-chat-id',
      messageId: 'fake-message-id',
      value: 'test',
      dateCreated: DateTime.now(),
      status: ChatItemStatus.confirmed,
      isFromMe: false,
      senderDid: 'fake-sender-did',
      attachments: [],
    );
  }

  void simulateIncomingPresenceMessage({
    required String timestamp,
    required String recipientDid,
  }) {
    _emit(
      StreamData(
        event: ChatPresenceEvent(timestamp: DateTime.parse(timestamp)),
      ),
    );
  }

  void simulateIncomingTypingActivity({
    required String senderDid,
    required DateTime createdTime,
    required String recipientDid,
  }) {
    _emit(
      StreamData(
        event: ChatActivityEvent(
          senderDid: senderDid,
          timestamp: createdTime,
          createdTime: createdTime,
        ),
      ),
    );
  }

  void simulateIncomingEffectMessage({
    required String effectName,
    required String recipientDid,
  }) {
    _emit(StreamData(event: ChatEffectEvent(effectName: effectName)));
  }

  void simulateIncomingGroupDetailsUpdate({required String recipientDid}) {
    _emit(StreamData(event: const ChatGroupDetailsUpdateEvent()));
  }

  void simulateIncomingContactCardUpdate({
    required String contactDid,
    required ContactCard card,
    required String recipientDid,
  }) {
    _emit(
      StreamData(
        event: ChatContactDetailsUpdateEvent(
          senderDid: contactDid,
          contactCard: card.toSdkContactCard(),
        ),
      ),
    );
  }

  @override
  Future<ChatStream?> get chatStreamSubscription async {
    return _FakeChatStream(
      _streamController.stream,
      drainBuffer: (onData) {
        for (final data in _bufferedEvents) {
          onData(data);
        }
        _bufferedEvents.clear();
        _hasListener = true;
      },
      onDispose: () {
        _hasListener = false;
      },
    );
  }

  @override
  Future<void> endChatSession() async {
    sessionEnded = true;
  }

  @override
  Future<List<ChatItem>> get messages async => const <ChatItem>[];

  @override
  Future<void> reactOnMessage(
    Message message, {
    required String reaction,
  }) async {
    lastReactionMessage = message;
    lastReaction = reaction;
    reactOnMessageCalls.add({'message': message, 'reaction': reaction});
  }

  @override
  Future<void> editTextMessage(Message message, String newText) async {
    editTextMessageCalls.add({'message': message, 'newText': newText});
    message.value = newText;
    message.editedAt = DateTime.now().toUtc();
    _emit(StreamData(chatItem: message));
  }

  @override
  Future<void> sendChatActivity() async {
    chatActivitySent = true;
  }

  @override
  Future<void> sendChatContactDetailsUpdate(ConciergeMessage message) async {
    lastContactDetailsUpdateSent = message;
    sendContactDetailsUpdateCalls.add({'message': message});
  }

  @override
  Future<void> rejectChatContactDetailsUpdate(ConciergeMessage message) async {
    lastContactDetailsUpdateRejected = message;
    cancelUpdatingContactDetailsCalls.add({'message': message});
  }

  @override
  Future<void> sendEffect(Effect effect) async {
    lastEffectSent = effect.name;
    sendEffectCalls.add({'effect': effect});
  }

  @override
  Future<void> approveConnectionRequest(ConciergeMessage message) async {
    lastApprovedConnection = message;
    approveConnectionRequestCalls.add({'message': message});
  }

  @override
  Future<void> rejectConnectionRequest(ConciergeMessage message) async {
    lastRejectedConnection = message;
    rejectConnectionRequestCalls.add({'message': message});
  }

  @override
  Future<void> removeMember(String memberDid) async {
    lastRemovedMemberDid = memberDid;
    removeMemberCallCount++;
  }

  @override
  Future<Message> sendTextMessage(
    String text, {
    List<ChatAttachment>? attachments,
  }) async {
    // Track the call
    sendTextMessageCalls.add({'text': text, 'attachments': attachments});

    var normalizedAttachments = attachments ?? const <ChatAttachment>[];
    final firstAttachment = normalizedAttachments.firstOrNull;
    final base64Data = firstAttachment?.data?.base64;
    if (firstAttachment != null &&
        base64Data != null &&
        base64Data.isNotEmpty &&
        firstAttachment.data?.links?.isEmpty != false) {
      final fileBytes = base64Decode(base64Data);
      final mediaUri = Uri.parse(
        'mxc://fake-homeserver/fake-media-${sendMediaMessageCalls.length}',
      );
      final transportId = 'fake-event-${DateTime.now().microsecondsSinceEpoch}';
      sendMediaMessageCalls.add({
        'fileBytes': fileBytes,
        'contentType': firstAttachment.mediaType ?? 'application/octet-stream',
        'filename': firstAttachment.filename,
        'caption': text,
        'mxcUri': mediaUri,
        'transportId': transportId,
      });
      _downloadedMedia[transportId] = fileBytes;

      normalizedAttachments = [
        ChatAttachment(
          mediaType: firstAttachment.mediaType ?? 'application/octet-stream',
          filename: firstAttachment.filename,
          format: AttachmentFormat.hostedMedia.value,
          transportId: transportId,
          data: ChatAttachmentData(links: [mediaUri], base64: base64Data),
          metadata: firstAttachment.metadata,
        ),
      ];
    }

    final message = Message(
      chatId: 'fake-chat-id',
      messageId: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      value: text,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.queued,
      isFromMe: true,
      senderDid: 'fake-sender-did',
      attachments: normalizedAttachments,
    );

    return message;
  }

  @override
  Future<Uint8List> downloadMedia(ChatAttachment attachment) async {
    final base64Data = attachment.data?.base64;
    if (base64Data != null && base64Data.isNotEmpty) {
      return base64Decode(base64Data);
    }

    final transportId = attachment.transportId;
    if (transportId != null) {
      final fileBytes = _downloadedMedia[transportId];
      if (fileBytes != null) return fileBytes;
    }

    throw StateError('No media bytes available in FakeChatSdk');
  }

  @override
  Future<Chat> startChatSession() async {
    _chatSessionStartedCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (shouldThrowOnStartSession) {
      throw Exception('Simulated SDK error');
    }
    return FakeChat();
  }

  @override
  Future<void> startChatPresenceUpdates() async {
    _startedChatPresenceUpdates += 1;
  }

  @override
  Future<ChatItem?> getMessageById(String messageId) async {
    return null;
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

class _FakeChatStream implements ChatStream {
  _FakeChatStream(
    this._stream, {
    required this.drainBuffer,
    required this.onDispose,
  });

  final Stream<StreamData> _stream;
  final void Function(void Function(StreamData) onData) drainBuffer;
  final void Function() onDispose;
  StreamSubscription<StreamData>? _subscription;

  @override
  ChatStream listen(
    void Function(StreamData) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    drainBuffer(onData);
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
    onDispose();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented in _FakeChatStream',
    );
  }
}
