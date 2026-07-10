import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/delegates/call_chat_item_manager.dart';

import '../mocks/mock_app_logger.dart';

class FakeCallChatItemManager extends CallChatItemManager {
  FakeCallChatItemManager({this.isStaleReturn = false, this.resolveReturn})
    : super(
        ensureInitialized: () async {},
        getChatSdk: () => null,
        logger: FakeAppLogger(),
      );

  final bool isStaleReturn;
  final String? resolveReturn;
  int updateCallCount = 0;
  DateTime? lastResolveBound;

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
  Future<Message?> updateCallChatItem(
    String messageId, {
    required CallStatus status,
    Duration? duration,
  }) async {
    updateCallCount++;
    return null;
  }
}
