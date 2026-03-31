import 'package:meeting_place_chat/meeting_place_chat.dart';

import 'interfaces/concierge_delegate.dart';

/// Encapsulates all concierge-related SDK interactions.
class AppConciergeDelegate implements ConciergeDelegate {
  AppConciergeDelegate({required MeetingPlaceChatSDK chatSdk})
    : _chatSdk = chatSdk;

  final MeetingPlaceChatSDK _chatSdk;

  @override
  Future<void> approveConnectionRequest(ConciergeMessage message) async {
    await _chatSdk.approveConnectionRequest(message);
  }

  @override
  Future<void> rejectConnectionRequest(ConciergeMessage message) async {
    await _chatSdk.rejectConnectionRequest(message);
  }

  @override
  Future<void> sendChatContactDetailsUpdate(ConciergeMessage message) async {
    await _chatSdk.sendChatContactDetailsUpdate(message);
  }

  @override
  Future<void> rejectChatContactDetailsUpdate(ConciergeMessage message) async {
    await _chatSdk.rejectChatContactDetailsUpdate(message);
  }
}
