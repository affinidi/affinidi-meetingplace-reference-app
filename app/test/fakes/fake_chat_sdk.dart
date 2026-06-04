import 'dart:async';

import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/contact_card_extensions.dart';

import 'fake_chat.dart';

class FakeChatSdk implements MeetingPlaceChatSDK {
  int _chatSessionStartedCalls = 0;
  int _startedChatPresenceUpdates = 0;
  final StreamController<StreamData> _streamController =
      StreamController<StreamData>.broadcast();

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
  final List<Map<String, dynamic>> sendEffectCalls = [];
  final List<Map<String, dynamic>> reactOnMessageCalls = [];
  final List<Map<String, dynamic>> approveConnectionRequestCalls = [];
  final List<Map<String, dynamic>> rejectConnectionRequestCalls = [];
  final List<Map<String, dynamic>> sendContactDetailsUpdateCalls = [];
  final List<Map<String, dynamic>> cancelUpdatingContactDetailsCalls = [];
  final List<({List<Attachment> attachments, String senderDid})>
  createAttachmentMessageCalls = [];

  int get startChatSessionCallCount => _chatSessionStartedCalls;
  int get startedChatPresenceUpdatesCount => _startedChatPresenceUpdates;

  /// Simulates an incoming text message by emitting it through the stream
  void simulateIncomingTextMessage({
    required String text,
    required String recipientDid,
    List<ChatAttachment>? attachments,
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

    final chatEvent = UnhandledChatEvent(
      type: 'https://affinidi.com/chat/1.0/message',
      senderDid: 'fake-sender-did',
      body: {'text': text, 'timestamp': message.dateCreated.toIso8601String()},
      createdTime: message.dateCreated,
    );

    _streamController.add(StreamData(event: chatEvent, chatItem: message));
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

    _streamController.add(
      StreamData(event: chatEvent, chatItem: conciergeMessage),
    );

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

    final plainTextMessage = PlainTextMessage(
      id: conciergeMessage.messageId,
      type: Uri.parse('https://affinidi.com/chat/1.0/concierge'),
      body: {
        'type': 'permissionToVerifyRelationship',
        'timestamp': conciergeMessage.dateCreated.toIso8601String(),
      },
      from: senderDid,
      to: [recipientDid],
      createdTime: conciergeMessage.dateCreated,
    );

    _streamController.add(
      StreamData(
        plainTextMessage: plainTextMessage,
        chatItem: conciergeMessage,
      ),
    );

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

    final plainTextMessage = PlainTextMessage(
      id: eventMessage.messageId,
      type: Uri.parse('https://affinidi.com/chat/1.0/event'),
      body: {
        'type': eventType,
        'timestamp': eventMessage.dateCreated.toIso8601String(),
        ...data,
      },
      from: senderDid,
      to: [recipientDid],
      createdTime: eventMessage.dateCreated,
    );

    _streamController.add(
      StreamData(plainTextMessage: plainTextMessage, chatItem: eventMessage),
    );

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

    _streamController.add(
      StreamData(event: chatEvent, chatItem: conciergeMessage),
    );

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

    _streamController.add(StreamData(event: chatEvent, chatItem: eventMessage));

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

    _streamController.add(StreamData(event: chatEvent, chatItem: eventMessage));

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

    _streamController.add(StreamData(event: chatEvent, chatItem: eventMessage));

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
    _streamController.add(
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
    _streamController.add(
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
    _streamController.add(
      StreamData(event: ChatEffectEvent(effectName: effectName)),
    );
  }

  void simulateIncomingGroupDetailsUpdate({required String recipientDid}) {
    _streamController.add(
      StreamData(event: const ChatGroupDetailsUpdateEvent()),
    );
  }

  void simulateIncomingContactCardUpdate({
    required String contactDid,
    required ContactCard card,
    required String recipientDid,
  }) {
    _streamController.add(
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
  Future<Chat> startChatSession() async {
    _chatSessionStartedCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
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
  Future<void> createAttachmentMessage({
    required List<Attachment> attachments,
    required String senderDid,
  }) async {
    createAttachmentMessageCalls.add((
      attachments: attachments,
      senderDid: senderDid,
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented in FakeChatSdk',
    );
  }
}
