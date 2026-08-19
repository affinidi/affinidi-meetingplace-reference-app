import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/call_chat_item_manager.dart';

import '../mocks/mock_app_logger.dart';

class FakeCallChatItemManager extends CallChatItemManager {
  FakeCallChatItemManager({
    this.isStaleReturn = false,
    this.resolveReturn,
    this.staleItemsReturn,
  }) : super(
         ensureInitialized: () async {},
         getChatSdk: () => null,
         logger: FakeAppLogger(),
       );

  final bool isStaleReturn;
  final Message? resolveReturn;
  final List<Message>? staleItemsReturn;
  int updateCallCount = 0;
  DateTime? lastResolveBound;
  String? lastResolveCallId;
  final List<String> updatedMessageIds = [];
  DateTime? lastSweepBound;
  String? lastSweepExcludeCallId;

  @override
  bool isStaleIncomingCall(Message message) => isStaleReturn;

  @override
  Future<Message?> resolveIncomingCallItemBefore(
    DateTime notAfter, {
    String? callId,
  }) async {
    lastResolveBound = notAfter;
    lastResolveCallId = callId;
    return resolveReturn;
  }

  @override
  Future<List<Message>> resolveStaleIncomingCallItemsBefore(
    DateTime? notAfter, {
    String? excludeCallId,
  }) async {
    lastSweepBound = notAfter;
    lastSweepExcludeCallId = excludeCallId;
    if (staleItemsReturn != null) return staleItemsReturn!;
    // Back-compat: expose the single stale resolveReturn as a one-element
    // sweep so existing single-item tests keep working unchanged.
    if (resolveReturn != null && isStaleReturn) return [resolveReturn!];
    return const [];
  }

  @override
  Future<Message?> updateCallChatItem(
    String messageId, {
    required CallStatus status,
    Duration? duration,
    CallParticipation? participation,
  }) async {
    updateCallCount++;
    updatedMessageIds.add(messageId);
    return null;
  }
}
