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

  final List<Map<String, dynamic>> sendTextMessageCalls = [];
  final List<Map<String, dynamic>> sendEffectCalls = [];
  final List<Map<String, dynamic>> reactOnMessageCalls = [];
  final List<Map<String, dynamic>> approveConnectionRequestCalls = [];
  final List<Map<String, dynamic>> rejectConnectionRequestCalls = [];
  final List<Map<String, dynamic>> sendContactDetailsUpdateCalls = [];
  final List<Map<String, dynamic>> cancelUpdatingContactDetailsCalls = [];
  final List<List<Attachment>> createChatMessageFromIssuedCredentialCalls = [];
  final List<List<Attachment>> createChatMessageFromRequestCredentialCalls = [];
  final List<({List<Attachment> attachments, String senderDid})>
  createAttachmentMessageCalls = [];

  int get startChatSessionCallCount => _chatSessionStartedCalls;
  int get startedChatPresenceUpdatesCount => _startedChatPresenceUpdates;

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
      body: {'text': text, 'timestamp': message.dateCreated.toIso8601String()},
      from: 'fake-sender-did',
      to: [recipientDid],
      createdTime: message.dateCreated,
    );

    _streamController.add(
      StreamData(plainTextMessage: plainTextMessage, chatItem: message),
    );
  }

  /// Simulates an incoming concierge message for join group requests
  /// Returns the created ConciergeMessage for verification in tests
  ConciergeMessage simulateJoinGroupRequest({
    required String memberName,
    required String senderDid,
  }) async {
    createAttachmentMessageCalls.add((
      attachments: attachments,
      senderDid: senderDid,
    ));
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

  Future<void> createChatMessageFromIssuedCredential({
    required List<Attachment> attachments,
  }) async {
    createChatMessageFromIssuedCredentialCalls.add(attachments);
  }

  Future<void> createChatMessageFromRequestCredential({
    required List<Attachment> attachments,
  }) async {
    createChatMessageFromRequestCredentialCalls.add(attachments);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'Method ${invocation.memberName} not implemented in FakeChatSdk',
    );
  }
}
