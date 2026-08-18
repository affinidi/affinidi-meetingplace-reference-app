import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

import 'fake_chat.dart';

class FakeChatSdk implements MeetingPlaceMatrixChatSDK {
  FakeChatSdk({TransportCapabilities? capabilities})
    : _capabilities = capabilities ?? _defaultCapabilities;

  /// Mirrors an individual Matrix chat: the common case exercised by tests.
  static const _defaultCapabilities = TransportCapabilities({
    ChatFeature.textMessaging,
    ChatFeature.imageAttachments,
    ChatFeature.videoAttachments,
    ChatFeature.documentAttachments,
    ChatFeature.voiceMessages,
    ChatFeature.reactions,
    ChatFeature.typingIndicators,
    ChatFeature.deliveryReceipts,
    ChatFeature.messageEdit,
    ChatFeature.messageDelete,
    ChatFeature.effects,
    ChatFeature.contactDetailsUpdate,
    ChatFeature.audioVideoCalling,
    ChatFeature.suggestionRequests,
  });

  TransportCapabilities _capabilities;

  @override
  TransportCapabilities get capabilities => _capabilities;

  set capabilities(TransportCapabilities caps) => _capabilities = caps;

  @override
  String get did => 'fake-sender-did';

  @override
  String get otherPartyDid => 'fake-other-party-did';

  @override
  String get chatId => 'fake-chat-id';

  int _chatSessionStartedCalls = 0;
  int _startedChatPresenceUpdates = 0;
  final StreamController<StreamData> _streamController =
      StreamController<StreamData>.broadcast();

  void _emit(StreamData data) {
    _streamController.add(data);
  }

  bool chatActivitySent = false;
  ConciergeMessage? lastRejectedConnection;
  ConciergeMessage? lastApprovedConnection;
  ConciergeMessage? lastContactDetailsUpdateSent;
  ConciergeMessage? lastContactDetailsUpdateRejected;
  Message? lastReactionMessage;
  String? lastReaction;
  String? lastSuggestionRequestMessageId;
  String? lastSuggestionRequestText;
  bool sessionEnded = false;
  String? lastEffectSent;
  sdk.ContactCard? lastRefreshedCurrentContactCard;
  int refreshCurrentContactCardCallCount = 0;
  bool shouldThrowOnStartSession = false;
  int sendTextMessageFailuresRemaining = 0;
  Completer<void>? sendTextMessageBlocker;
  String? lastRemovedMemberDid;
  int removeMemberCallCount = 0;
  Completer<void>? removeMemberBlocker;

  final List<Map<String, dynamic>> sendTextMessageCalls = [];
  final List<Map<String, dynamic>> sendEffectCalls = [];
  final List<Map<String, dynamic>> reactOnMessageCalls = [];
  final List<Map<String, dynamic>> sendSuggestionRequestCalls = [];
  final List<Map<String, dynamic>> approveConnectionRequestCalls = [];
  final List<Map<String, dynamic>> rejectConnectionRequestCalls = [];
  final List<Map<String, dynamic>> sendContactDetailsUpdateCalls = [];
  final List<Map<String, dynamic>> cancelUpdatingContactDetailsCalls = [];
  final List<Map<String, dynamic>> sendMediaMessageCalls = [];
  final List<Map<String, dynamic>> deleteMessageCalls = [];
  final List<Map<String, dynamic>> editTextMessageCalls = [];
  final Map<String, List<int>> _downloadedMedia = {};
  final List<({List<ChatAttachment> attachments, String senderDid})>
  createAttachmentMessageCalls = [];
  final List<({int targetCount, Completer<void> completer})>
  _attachmentMessageWaiters = [];

  int get startChatSessionCallCount => _chatSessionStartedCalls;
  int get startedChatPresenceUpdatesCount => _startedChatPresenceUpdates;

  /// Simulates an incoming text message by emitting it through the stream
  Message simulateIncomingTextMessage({
    required String text,
    required String recipientDid,
    List<ChatAttachment>? attachments,
    List<ChatMention> mentions = const [],
    bool isFromMe = false,
    String senderDid = 'fake-sender-did',
  }) {
    final transportId =
        'fake-transport-incoming-${DateTime.now().microsecondsSinceEpoch}';
    final normalizedAttachments = <ChatAttachment>[];
    for (final attachment in attachments ?? const <ChatAttachment>[]) {
      normalizedAttachments.add(
        ChatAttachment(
          id: attachment.id,
          description: attachment.description,
          filename: attachment.filename,
          mediaType: attachment.mediaType,
          format: attachment.format,
          lastModifiedTime: attachment.lastModifiedTime,
          data: attachment.data,
          byteCount: attachment.byteCount,
          transportId: attachment.transportId ?? transportId,
          metadata: attachment.metadata,
        ),
      );
    }
    final message = Message(
      chatId: 'fake-chat-id',
      messageId: 'msg-incoming-${DateTime.now().microsecondsSinceEpoch}',
      value: text,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.confirmed,
      isFromMe: isFromMe,
      senderDid: senderDid,
      attachments: normalizedAttachments,
      mentions: mentions,
    );

    final chatEvent = UnhandledChatEvent(
      type: 'https://affinidi.com/chat/1.0/message',
      senderDid: senderDid,
      body: {'text': text, 'timestamp': message.dateCreated.toIso8601String()},
      createdTime: message.dateCreated,
    );

    _emit(StreamData(event: chatEvent, chatItem: message));
    return message;
  }

  /// Simulates an incoming text message using the real `ChatMessageEvent`
  /// production emits for `ChatProtocol.chatMessage` (see
  /// `chat_event_conversion.dart` in `meeting_place_matrix`/`meeting_place_chat`),
  /// unlike [simulateIncomingTextMessage] which uses `UnhandledChatEvent`.
  /// Needed to exercise handlers whose `canHandle` matches `ChatMessageEvent`
  /// specifically, e.g. `ChatMessageProtocolHandler`.
  void simulateIncomingChatMessageEvent({
    required String text,
    String senderDid = 'fake-sender-did',
  }) {
    final message = Message(
      chatId: 'fake-chat-id',
      messageId: 'msg-chatmessage-${DateTime.now().microsecondsSinceEpoch}',
      value: text,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.confirmed,
      isFromMe: false,
      senderDid: senderDid,
      attachments: const [],
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

  /// Simulates a permission to verify relationship concierge message
  ConciergeMessage simulateVrcPermissionRequest({
    required String senderDid,
    required String recipientDid,
  }) {
    final conciergeMessage = ConciergeMessage(
      chatId: 'fake-chat-id',
      messageId: 'concierge-vrc-${DateTime.now().millisecondsSinceEpoch}',
      senderDid: senderDid,
      isFromMe: false,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.userInput,
      data: {},
      conciergeType: ConciergeMessageType.fromJson(
        'permissionToVerifyRelationship',
      ),
    );

    final chatEvent = UnhandledChatEvent(
      type: 'https://affinidi.com/chat/1.0/concierge',
      senderDid: senderDid,
      body: {
        'type': 'permissionToVerifyRelationship',
        'timestamp': conciergeMessage.dateCreated.toIso8601String(),
      },
      createdTime: conciergeMessage.dateCreated,
    );

    _emit(StreamData(event: chatEvent, chatItem: conciergeMessage));

    return conciergeMessage;
  }

  /// Simulates a VRC event message (e.g. vrcExchangeInitiated,
  /// vrcExchangeDoLater, vrcExchangeCompleted, vrcRequestReceived). Pass
  /// extra [data] as needed.
  EventMessage simulateVrcEvent({
    required String eventType,
    required String senderDid,
    required String recipientDid,
    Map<String, dynamic> data = const {},
  }) {
    final eventMessage = EventMessage(
      chatId: 'fake-chat-id',
      messageId: 'event-vrc-${DateTime.now().millisecondsSinceEpoch}',
      senderDid: senderDid,
      isFromMe: false,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.received,
      eventType: EventMessageType.fromJson(eventType),
      data: data,
    );

    final chatEvent = UnhandledChatEvent(
      type: 'https://affinidi.com/chat/1.0/event',
      senderDid: senderDid,
      body: {
        'type': eventType,
        'timestamp': eventMessage.dateCreated.toIso8601String(),
        ...data,
      },
      createdTime: eventMessage.dateCreated,
    );

    _emit(StreamData(event: chatEvent, chatItem: eventMessage));

    return eventMessage;
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

  /// Simulates the SDK recording that it is awaiting a member to join
  EventMessage simulateAwaitingGroupMember({
    required String memberName,
    required String memberDid,
    required String senderDid,
    required String recipientDid,
  }) {
    final eventMessage = EventMessage(
      chatId: 'fake-chat-id',
      messageId: 'event-awaiting-${DateTime.now().millisecondsSinceEpoch}',
      senderDid: senderDid,
      isFromMe: false,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.received,
      eventType: EventMessageType.awaitingGroupMemberToJoin,
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
        'type': 'awaitingGroupMemberToJoin',
        'memberName': memberName,
        'timestamp': eventMessage.dateCreated.toIso8601String(),
      },
      createdTime: eventMessage.dateCreated,
    );

    _emit(StreamData(event: chatEvent, chatItem: eventMessage));

    return eventMessage;
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
    GroupMemberLeaveReason reason = GroupMemberLeaveReason.leave,
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
        'reason': reason.name,
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

  void setIncomingCallSessionMessage({
    required String senderDid,
    String messageId = 'late-incoming-call-item',
    CallMediaType mediaType = CallMediaType.video,
    CallStatus status = CallStatus.calling,
    DateTime? dateCreated,
  }) {
    final createdAt = dateCreated ?? DateTime.now();
    final message = Message(
      chatId: chatId,
      messageId: messageId,
      value: '',
      dateCreated: createdAt,
      status: ChatItemStatus.confirmed,
      isFromMe: false,
      senderDid: senderDid,
      attachments: [
        CallMetadata.buildAttachment(
          id: 'call-attachment-${DateTime.now().microsecondsSinceEpoch}',
          mediaType: mediaType,
          status: status,
          callId: '',
        ),
      ],
    );
    sessionMessages = [message];

    // Emit the message through the stream so the app knows to check for healing
    final chatEvent = UnhandledChatEvent(
      type: 'https://affinidi.com/chat/1.0/message',
      senderDid: senderDid,
      body: {'timestamp': message.dateCreated.toIso8601String()},
      createdTime: createdAt,
    );
    _emit(StreamData(event: chatEvent, chatItem: message));
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

  void simulateIncomingSuggestion({
    required String relatedMessageId,
    required String text,
    required String recipientDid,
    String? senderDid = 'fake-sender-did',
  }) {
    _emit(
      StreamData(
        event: ChatSuggestionEvent(
          senderDid: senderDid,
          relatedMessageId: relatedMessageId,
          text: text,
          createdTime: DateTime.now().toUtc(),
        ),
      ),
    );
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
    return FakeChatStream(_streamController.stream);
  }

  @override
  Future<void> endChatSession() async {
    sessionEnded = true;
  }

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
  Future<void> sendSuggestionRequest({
    required String messageId,
    required String text,
  }) async {
    lastSuggestionRequestMessageId = messageId;
    lastSuggestionRequestText = text;
    sendSuggestionRequestCalls.add({'messageId': messageId, 'text': text});
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
    if (removeMemberBlocker != null) {
      await removeMemberBlocker!.future;
    }
  }

  @override
  Future<Message> sendTextMessage(
    String text, {
    List<ChatAttachment>? attachments,
    List<ChatMention> mentions = const [],
  }) async {
    if (sendTextMessageFailuresRemaining > 0) {
      sendTextMessageFailuresRemaining--;
      throw Exception('Simulated sendTextMessage error');
    }

    // Track the call
    sendTextMessageCalls.add({
      'text': text,
      'attachments': attachments,
      'mentions': mentions,
    });

    if (sendTextMessageBlocker != null) {
      await sendTextMessageBlocker!.future;
    }

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
      _downloadedMedia[mediaUri.toString()] = fileBytes;

      normalizedAttachments = [
        ChatAttachment(
          id: firstAttachment.id,
          mediaType: firstAttachment.mediaType ?? 'application/octet-stream',
          filename: firstAttachment.filename,
          format: firstAttachment.format,
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
      attachments: attachments ?? [],
    );

    return message;
  }

  List<ChatItem>? sessionMessages;

  @override
  Future<List<ChatItem>> get messages async =>
      sessionMessages ?? const <ChatItem>[];

  @override
  Future<ChatItem?> getCallChatItemByCallId(String callId) async {
    if (callId.isEmpty) return null;
    final items = await messages;
    Message? outgoing;
    Message? incoming;
    for (final message in items.whereType<Message>()) {
      final matches = message.attachments.any(
        (a) =>
            CallMetadata.isCall(a) && CallMetadata.maybeOf(a)?.callId == callId,
      );
      if (!matches) continue;
      if (message.isFromMe) {
        outgoing = message;
      } else {
        incoming = message;
      }
    }
    return outgoing ?? incoming;
  }

  @override
  Future<Chat> startChatSession() async {
    _chatSessionStartedCalls++;
    if (shouldThrowOnStartSession) {
      throw Exception('Simulated SDK error');
    }
    final msgs = sessionMessages;
    return msgs != null ? FakeChatWithMessages(msgs) : FakeChat();
  }

  @override
  Future<void> startChatPresenceUpdates() async {
    _startedChatPresenceUpdates += 1;
  }

  @override
  Future<void> refreshCurrentContactCard(sdk.ContactCard? card) async {
    lastRefreshedCurrentContactCard = card;
    refreshCurrentContactCardCallCount += 1;
  }

  @override
  Future<Uint8List> downloadMedia(ChatAttachment attachment) async {
    final transportId = attachment.transportId;
    if (transportId != null) {
      final transportBytes = _downloadedMedia[transportId];
      if (transportBytes != null) {
        return Uint8List.fromList(transportBytes);
      }
    }

    final mediaLink = attachment.data?.links?.firstOrNull?.toString();
    if (mediaLink != null) {
      final linkedBytes = _downloadedMedia[mediaLink];
      if (linkedBytes != null) {
        return Uint8List.fromList(linkedBytes);
      }
    }

    final base64Data = attachment.data?.base64;
    if (base64Data != null && base64Data.isNotEmpty) {
      return Uint8List.fromList(base64Decode(base64Data));
    }

    throw StateError('No fake media available for attachment');
  }

  @override
  Future<void> createAttachmentMessage({
    required List<ChatAttachment> attachments,
    required String senderDid,
  }) async {
    createAttachmentMessageCalls.add((
      attachments: attachments,
      senderDid: senderDid,
    ));
    _resolveAttachmentMessageWaiters();
  }

  Future<void> waitForAttachmentMessageCount(int count) {
    if (createAttachmentMessageCalls.length >= count) {
      return Future.value();
    }

    final completer = Completer<void>();
    _attachmentMessageWaiters.add((targetCount: count, completer: completer));
    return completer.future;
  }

  void _resolveAttachmentMessageWaiters() {
    final completedWaiters = _attachmentMessageWaiters
        .where(
          (waiter) => createAttachmentMessageCalls.length >= waiter.targetCount,
        )
        .toList();
    for (final waiter in completedWaiters) {
      waiter.completer.complete();
      _attachmentMessageWaiters.remove(waiter);
    }
  }

  /// Simulates a sent (own) text message appearing in the stream.
  void simulateSentTextMessage({
    required String text,
    List<ChatMention> mentions = const [],
  }) {
    final message = Message(
      chatId: 'fake-chat-id',
      messageId: 'msg-sent-${DateTime.now().microsecondsSinceEpoch}',
      value: text,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.confirmed,
      isFromMe: true,
      senderDid: 'fake-my-did',
      attachments: [],
      mentions: mentions,
    );
    final chatEvent = UnhandledChatEvent(
      type: 'https://affinidi.com/chat/1.0/message',
      senderDid: 'fake-my-did',
      body: {'text': text, 'timestamp': message.dateCreated.toIso8601String()},
      createdTime: message.dateCreated,
    );
    _emit(StreamData(event: chatEvent, chatItem: message));
  }

  @override
  Future<void> editTextMessage(
    Message message,
    String newText, {
    List<ChatMention>? mentions,
  }) async {
    editTextMessageCalls.add({
      'message': message,
      'newText': newText,
      'mentions': mentions,
    });
    message.value = newText;
    message.editedAt = DateTime.now().toUtc();
    _emit(StreamData(chatItem: message));
  }

  final List<Message> updateMessageCalls = [];

  @override
  Future<ChatItem?> getMessageById(String id) async => sessionMessages
      ?.whereType<Message>()
      .cast<Message?>()
      .firstWhere((m) => m?.messageId == id, orElse: () => null);

  @override
  Future<void> updateMessage(Message message) async {
    updateMessageCalls.add(message);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented in FakeChatSdk',
    );
  }
}
