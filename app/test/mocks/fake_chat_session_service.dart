import 'package:meeting_place_chat/meeting_place_chat.dart'
    show CallMediaType, CallStatus;
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_service_state.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';

/// Recorded arguments for a single updateCallChatItem call.
typedef UpdateCallChatItemCall = ({
  String messageId,
  CallStatus status,
  Duration? duration,
});

/// Fake [ChatSessionService] for testing.
///
/// Records calls to [updateCallChatItem] and exposes configurable return values
/// for the resolve methods.
class FakeChatSessionService extends ChatSessionService {
  FakeChatSessionService({
    this.sendOutgoingResult,
    this.resolveIncomingResult,
    this.resolveOutgoingResult,
  });

  String? sendOutgoingResult;
  String? resolveIncomingResult;
  String? resolveOutgoingResult;

  final List<UpdateCallChatItemCall> updateCalls = [];

  @override
  ChatServiceState build(String channelDid) => ChatServiceState();

  @override
  Future<String?> sendOutgoingCallMessage({
    required CallMediaType mediaType,
  }) async => sendOutgoingResult;

  @override
  Future<String?> resolveIncomingCallChatItemId() async =>
      resolveIncomingResult;

  @override
  Future<String?> resolveOutgoingCallChatItemId() async =>
      resolveOutgoingResult;

  @override
  Future<void> markCallAsMissed() async {}

  @override
  Future<void> updateCallChatItem(
    String messageId, {
    required CallStatus status,
    Duration? duration,
  }) async {
    updateCalls.add((messageId: messageId, status: status, duration: duration));
  }
}
