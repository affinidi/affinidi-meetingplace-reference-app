import 'dart:typed_data';

import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact_presence_status.dart';
import 'package:mpx_flutter_reference_app/domain/models/identity/identity.dart';

/// Recorded arguments for a single updateCallChatItem call.
typedef UpdateCallChatItemCall = ({
  String messageId,
  CallStatus status,
  Duration? duration,
});

class FakeChatSessionService extends ChatSessionService {
  FakeChatSessionService({
    this.sendOutgoingResult,
    this.resolveIncomingResult,
    this.resolveOutgoingResult,
    this.markCallAsMissedMessageId,
    this.incomingItemAvailable = true,
    this.resolveCallItemMaxAttempts = 0,
  });

  static const _resolveCallItemRetryDelay = Duration(milliseconds: 50);

  String? sendOutgoingResult;
  String? resolveIncomingResult;
  String? resolveOutgoingResult;
  String? markCallAsMissedMessageId;
  bool incomingItemAvailable;
  int resolveCallItemMaxAttempts;
  int markCallAsMissedAttempts = 0;
  int schedulePendingMissedCallFollowUpCalls = 0;
  int resolveIncomingCallChatItemIdAttempts = 0;
  String? lastResolveIncomingCallId;
  String? lastResolveOutgoingCallId;

  final List<UpdateCallChatItemCall> updateCalls = [];

  @override
  ChatServiceState build(String channelDid) => ChatServiceState();

  @override
  Future<void> startChatSession() async {}

  @override
  Future<void> pauseChat() async {}

  @override
  int get secondsToShowChatActivityIndicator => 30;

  @override
  int get chatPresenceIntervalInSeconds => 60;

  @override
  Duration get deleteMessageWindow => const Duration(hours: 24);

  @override
  TransportCapabilities? get capabilities => null;

  @override
  Future<String?> restoreUnsentMessage(String contactId) async => null;

  @override
  Future<ContactPresenceStatus> calculateContactPresenceStatus(
    DateTime datePresence,
    int presenceIntervalInSeconds,
  ) async => ContactPresenceStatus.unknown;

  @override
  void onPresenceUpdated(DateTime datePresence) {}

  @override
  Future<void> sendTextMessage(
    String message, {
    List<ChatAttachment>? attachments,
  }) async {}

  @override
  Future<({ChatAttachment attachment, Uint8List bytes})?>
  buildVoiceMessageAttachment({
    required String filePath,
    required String mediaType,
    required Duration duration,
    required List<int> waveform,
  }) async => null;

  @override
  Future<Uint8List> downloadMedia(ChatAttachment attachment) async =>
      Uint8List(0);

  @override
  Future<void> sendChatActivity() async {}

  @override
  Future<void> reactOnMessage(
    Message message, {
    required String reaction,
  }) async {}

  @override
  Future<void> deleteMessage(
    Message message, {
    bool deleteForMeOnly = false,
  }) async {}

  @override
  Future<void> editTextMessage(Message message, String newText) async {}

  @override
  Future<void> sendEffect(Effect effectType) async {}

  @override
  Future<void> updateContactSequenceNumber(String channelDid) async {}

  @override
  Future<void> resetBadgeCount() async {}

  @override
  void clearEffect() {}

  @override
  Future<void> sendRCardFromPlugin(Identity identity) async {}

  @override
  Future<void> persistLocalEventMessage(
    EventMessageType eventType, {
    Map<String, dynamic> data = const {},
  }) async {}

  @override
  Future<void> dismissVrcConciergeMessages() async {}

  @override
  Future<void> showSentVrcAttachment({
    required String vcBlob,
    required String senderDid,
  }) async {}

  @override
  void upsertChatItem(ChatItem item) {}

  @override
  Future<String?> sendOutgoingCallMessage({
    required CallMediaType mediaType,
    required String callId,
  }) async => sendOutgoingResult;

  @override
  Future<String?> resolveIncomingCallChatItemId({String? callId}) {
    lastResolveIncomingCallId = callId;
    return _resolveCallChatItemId(
      resolve: () => resolveIncomingResult,
      onAttempt: () => resolveIncomingCallChatItemIdAttempts++,
      attemptsRemaining: resolveCallItemMaxAttempts,
    );
  }

  @override
  Future<String?> resolveOutgoingCallChatItemId({String? callId}) {
    lastResolveOutgoingCallId = callId;
    return _resolveCallChatItemId(
      resolve: () => resolveOutgoingResult,
      attemptsRemaining: resolveCallItemMaxAttempts,
    );
  }

  @override
  Future<bool> markCallAsMissed() async {
    markCallAsMissedAttempts++;
    final messageId =
        markCallAsMissedMessageId ?? await resolveIncomingCallChatItemId();
    if (!incomingItemAvailable || messageId == null) return false;
    await updateCallChatItem(messageId, status: CallStatus.missed);
    return true;
  }

  Future<String?> _resolveCallChatItemId({
    required String? Function() resolve,
    required int attemptsRemaining,
    void Function()? onAttempt,
  }) async {
    onAttempt?.call();
    final messageId = resolve();
    if (messageId != null || attemptsRemaining <= 0) return messageId;
    await Future<void>.delayed(_resolveCallItemRetryDelay);
    return _resolveCallChatItemId(
      resolve: resolve,
      attemptsRemaining: attemptsRemaining - 1,
      onAttempt: onAttempt,
    );
  }

  @override
  Future<void> updateCallChatItem(
    String messageId, {
    required CallStatus status,
    Duration? duration,
  }) async {
    updateCalls.add((messageId: messageId, status: status, duration: duration));
  }

  @override
  Future<void> sendChatContactDetailsUpdate(ConciergeMessage message) async {}

  @override
  Future<void> rejectChatContactDetailsUpdate(ConciergeMessage message) async {}
}
