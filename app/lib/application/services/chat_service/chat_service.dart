import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../domain/models/contacts/contact_presence_status.dart';
import '../../../domain/models/identity/identity.dart';
import 'delegates/chat_concierge_messenger.dart' show ChatConciergeMessenger;
import 'delegates/chat_group_manager.dart' show ChatGroupManager;
import 'delegates/interfaces/concierge_messaging.dart';
import 'delegates/interfaces/group_managing.dart';

/// Unified facade for managing a chat session.
///
/// Extends [ConciergeMessaging] and [GroupManaging] to aggregate all
/// chat-related operations into a single interface for presentation
/// controllers.
/// Concrete implementations delegate concierge and group operations to
/// [ChatConciergeMessenger] and [ChatGroupManager] internally.
abstract class ChatService implements ConciergeMessaging, GroupManaging {
  int get secondsToShowChatActivityIndicator;
  int get chatPresenceIntervalInSeconds;

  Future<void> startChatSession();
  void pauseChat();

  Future<String?> restoreUnsentMessage(String contactId);
  Future<ContactPresenceStatus> calculateContactPresenceStatus(
    DateTime datePresence,
    int presenceIntervalInSeconds,
  );

  void onPresenceUpdated(DateTime datePresence);

  Future<void> sendTextMessage(
    String message, {
    List<ChatAttachment>? attachments,
  });

  Future<void> sendChatActivity();
  Future<void> reactOnMessage(Message message, {required String reaction});
  Future<void> sendEffect(Effect effectType);

  Future<void> updateContactSequenceNumber(String channelDid);
  Future<void> resetBadgeCount();
  void clearEffect();

  Future<void> sendRCardFromPlugin(Identity identity);

  /// Persists an event message to the chat repository and injects it into
  /// the live message list. Used for local-only events that must survive
  /// session restarts (e.g. vrcExchangeInitiated).
  ///
  /// [data] is optional metadata stored alongside the event (e.g. persona DID).
  Future<void> persistLocalEventMessage(
    EventMessageType eventType, {
    Map<String, dynamic> data = const {},
  });

  /// Marks all pending `permissionToVerifyRelationship` concierge messages as
  /// confirmed in the DB and removes them from the live message list.
  /// Marks all pending VRC concierge messages as confirmed and removes them.
  Future<void> dismissVrcConciergeMessages();

  /// Creates a local chat message showing a VRC sent by the local user.
  ///
  /// Intended to be called after the VDIP issuance has completed so the
  /// sender sees the credential tile immediately (isFromMe: true).
  Future<void> showSentVrcAttachment({
    required String vcBlob,
    required String senderDid,
  });
  void upsertChatItem(ChatItem item);
}
