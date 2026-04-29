import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_presence_status.dart';

/// Service that manages chat sessions, including message handling,
/// presence updates, and group interactions.
///
/// Owns the chat session state `ChatServiceState` and provides
/// methods for starting, updating, and ending chat sessions. Handles
/// all Meeting Place SDK interactions related to chats, such as sending
/// messages, updating contact presence, and managing group details.
/// Delegates specific operations to `GroupDelegate` and `ConciergeDelegate`
///  to keep responsibilities focused.
abstract class ChatService {
  int get secondsToShowChatActivityIndicator;
  int get chatPresenceIntervalInSeconds;

  Future<void> startChatSession();
  void pauseChat();

  Future<String?> restoreUnsentMessage(String contactId);
  Future<ContactPresenceStatus> calculateContactPresenceStatus(
    DateTime datePresence,
    int presenceIntervalInSeconds,
  );
  Future<void> updateGroupContactPendingStatus(Contact contact, Group group);

  void onPresenceUpdated(DateTime datePresence);

  Future<void> sendTextMessage(String message, {List<Attachment>? attachments});
  Future<void> sendChatActivity();
  Future<void> rejectConnectionRequest(ConciergeMessage message);
  Future<void> approveConnectionRequest(ConciergeMessage message);
  Future<void> sendChatContactDetailsUpdate(ConciergeMessage message);
  Future<void> rejectChatContactDetailsUpdate(ConciergeMessage message);
  Future<void> reactOnMessage(Message message, {required String reaction});
  Future<void> sendEffect(Effect effectType);

  Future<void> updateContactSequenceNumber(String channelDid);
  Future<void> resetBadgeCount();
  void clearEffect();
}
