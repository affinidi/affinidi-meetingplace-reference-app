import 'dart:typed_data';

import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../domain/models/contacts/contact_presence_status.dart';
import '../../../presentation/screens/chat/chat_screen_controller.dart'
    show ChatScreenController;
import 'delegates/chat_concierge_messenger.dart' show ChatConciergeMessenger;
import 'delegates/chat_group_manager.dart' show ChatGroupManager;
import 'delegates/interfaces/concierge_messaging.dart';
import 'delegates/interfaces/group_managing.dart';

/// Unified facade for managing a chat session.
///
/// Extends [ConciergeMessaging] and [GroupManaging] to aggregate all
/// chat-related operations into a single interface for [ChatScreenController].
/// Concrete implementations delegate concierge and group operations to
/// [ChatConciergeMessenger] and [ChatGroupManager] internally.
abstract class ChatService implements ConciergeMessaging, GroupManaging {
  int get secondsToShowChatActivityIndicator;
  int get chatPresenceIntervalInSeconds;

  /// Maximum age at which the original sender can still delete a message
  /// for everyone. Mirrors the SDK's `deleteMessageWindow` option.
  Duration get deleteMessageWindow;

  Future<void> startChatSession();
  Future<void> pauseChat();

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

  Future<Message> sendMediaMessage(
    Uint8List fileBytes, {
    required String contentType,
    String? filename,
    String? caption,
  });

  Future<Uint8List> downloadMedia(ChatAttachment attachment);

  Future<void> sendChatActivity();
  Future<void> reactOnMessage(Message message, {required String reaction});
  Future<void> editTextMessage(Message message, String newText);
  Future<void> deleteMessage(Message message, {bool deleteForMeOnly = false});
  Future<void> sendEffect(Effect effectType);

  Future<void> updateContactSequenceNumber(String channelDid);
  Future<void> resetBadgeCount();
  void clearEffect();
}
