import 'package:meeting_place_chat/meeting_place_chat.dart';

/// Interface for concierge-related operations within the chat service.
abstract class ConciergeMessaging {
  Future<void> approveConnectionRequest(ConciergeMessage message);
  Future<void> rejectConnectionRequest(ConciergeMessage message);
  Future<void> sendChatContactDetailsUpdate(ConciergeMessage message);
  Future<void> rejectChatContactDetailsUpdate(ConciergeMessage message);
}
