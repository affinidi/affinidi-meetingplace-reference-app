import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../domain/models/contact_card/contact_card.dart' as domain;
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_presence_status.dart';

abstract class ChatService {
  int get secondsToShowChatActivityIndicator;
  int get chatPresenceIntervalInSeconds;

  Stream<bool> get loadingActivity;
  Stream<DateTime> get presence;
  Stream<String?> get typingMembers;
  Stream<String?> get effect;
  Stream<StreamData> get groupDetails;
  Stream<domain.ContactCard> get otherPartyContactCardUpdate;
  Stream<String> get clearTyping;
  Stream<ChatItem> get chatItem;
  Stream<Chat> get session;

  Future<void> startChatSession({required Contact contact});

  Future<String?> restoreUnsentMessage(String contactId);
  Future<Group?> refreshGroup(String groupId);
  Future<ContactPresenceStatus> calculateContactPresenceStatus(
    DateTime datePresence,
    int presenceIntervalInSeconds,
  );
  Future<void> updateGroupContactPendingStatus(Contact contact, Group? group);

  Future<void> sendTextMessage(String message, {List<Attachment>? attachments});
  Future<void> sendChatActivity();
  Future<void> rejectConnectionRequest(ConciergeMessage chatItem);
  Future<void> approveConnectionRequest(ConciergeMessage chatItem);
  Future<void> sendChatContactDetailsUpdate(ConciergeMessage message);
  Future<void> rejectChatContactDetailsUpdate(ConciergeMessage message);
  Future<void> reactOnMessage(Message message, {required String reaction});
  Future<void> sendEffect(Effect effectType);

  void disposeChat();
}
