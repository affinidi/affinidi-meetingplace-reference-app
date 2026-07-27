import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/call_chat_item_manager.dart';

import '../mocks/mock_app_logger.dart';

/// Records the arguments passed to a single `updateCallChatItem` call.
class UpdateCallRecord {
  UpdateCallRecord({
    required this.messageId,
    required this.status,
    this.duration,
  });

  final String messageId;
  final CallStatus status;
  final Duration? duration;
}

/// Fake for `CallChatItemManager` that lets tests seed the resolved call item
/// id and capture the `reconcileCallOutcome` arguments.
class FakeOutcomeCallChatItemManager extends CallChatItemManager {
  FakeOutcomeCallChatItemManager({this.resolvedId})
    : super(
        ensureInitialized: () async {},
        getChatSdk: () => null,
        logger: FakeAppLogger(),
      );

  final String? resolvedId;

  String? lastResolveCallId;
  final List<UpdateCallRecord> updates = [];

  @override
  Future<String?> resolveCallItemIdForOutcome(String callId) async {
    lastResolveCallId = callId;
    return resolvedId;
  }

  @override
  Future<Message?> reconcileCallOutcome(
    String messageId, {
    Duration? duration,
  }) async {
    updates.add(
      UpdateCallRecord(
        messageId: messageId,
        status: CallStatus.ended,
        duration: duration,
      ),
    );
    return null;
  }
}
