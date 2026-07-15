import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/call_chat_item_manager.dart';

import '../mocks/mock_app_logger.dart';

class FakeCallChatItemManager extends CallChatItemManager {
  FakeCallChatItemManager({
    this.isStaleReturn = false,
    this.resolveReturn,
    this.resolveIdsReturn = const [],
  }) : super(
         ensureInitialized: () async {},
         getChatSdk: () => null,
         logger: FakeAppLogger(),
       );

  final bool isStaleReturn;
  final String? resolveReturn;
  final List<String> resolveIdsReturn;
  int updateCallCount = 0;
  String? lastHealedMessageId;
  DateTime? lastResolveBound;
  String? lastResolvedCallId;

  @override
  bool isStaleIncomingCall(Message message) => isStaleReturn;

  @override
  Future<String?> resolveStaleIncomingCallItemIdBefore(
    DateTime dateTime,
  ) async {
    lastResolveBound = dateTime;
    return resolveReturn;
  }

  @override
  Future<List<String>> resolveStaleIncomingCallItemIdsBefore(
    DateTime dateTime,
  ) async {
    lastResolveBound = dateTime;
    return resolveIdsReturn;
  }

  @override
  Future<List<String>> resolveStaleIncomingCallItemIdsByCallId(
    String callId,
  ) async {
    lastResolvedCallId = callId;
    return resolveIdsReturn;
  }

  @override
  String? callIdOf(Message message) {
    return CallMetadata.maybeOf(
      message.attachments.firstWhere(CallMetadata.isCall),
    )?.callId;
  }

  @override
  Future<Message?> updateCallChatItem(
    String messageId, {
    required CallStatus status,
    Duration? duration,
  }) async {
    updateCallCount++;
    lastHealedMessageId = messageId;
    return null;
  }
}
