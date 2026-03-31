import 'package:meeting_place_chat/meeting_place_chat.dart';

import 'interfaces/concierge_delegate.dart';

/// Encapsulates all concierge-related SDK interactions.
class AppConciergeDelegate implements ConciergeDelegate {
  AppConciergeDelegate({required MeetingPlaceChatSDK Function() getChatSdk})
    : _getChatSdk = getChatSdk;

  final MeetingPlaceChatSDK Function() _getChatSdk;

  @override
  Future<void> approveConnectionRequest(ConciergeMessage message) async {
    await _getChatSdk().approveConnectionRequest(message);
  }

  @override
  Future<void> rejectConnectionRequest(ConciergeMessage message) async {
    await _getChatSdk().rejectConnectionRequest(message);
  }

  @override
  Future<void> sendChatContactDetailsUpdate(ConciergeMessage message) async {
    await _getChatSdk().sendChatContactDetailsUpdate(message);
  }

  @override
  Future<void> rejectChatContactDetailsUpdate(ConciergeMessage message) async {
    await _getChatSdk().rejectChatContactDetailsUpdate(message);
  }
}
