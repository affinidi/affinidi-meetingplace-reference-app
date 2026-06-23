import 'dart:typed_data';

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

  /// Maximum age at which the original sender can still delete a message
  /// for everyone. Mirrors the SDK's `deleteMessageWindow` option.
  Duration get deleteMessageWindow;

  /// Capabilities of the active chat, or `null` before the chat session has
  /// been started. Sourced from the underlying chat SDK variant, so it
  /// reflects both the transport and the chat type (individual vs group).
  TransportCapabilities? get capabilities;

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

  Future<({ChatAttachment attachment, Uint8List bytes})?>
  buildVoiceMessageAttachment({
    required String filePath,
    required String mediaType,
    required Duration duration,
    required List<int> waveform,
  });

  Future<Uint8List> downloadMedia(ChatAttachment attachment);

  Future<void> sendChatActivity();
  Future<void> reactOnMessage(Message message, {required String reaction});
  Future<void> deleteMessage(Message message, {bool deleteForMeOnly = false});
  Future<void> editTextMessage(Message message, String newText);
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

  /// Sends a call chat item over the wire and persists it for the sender,
  /// returning its message id so the call lifecycle can update the item in
  /// place. The receiver gets the item automatically via the chat transport
  /// (isFromMe: false) and is offline-notified like any other message.
  Future<String?> sendOutgoingCallMessage({required CallMediaType mediaType});

  /// Resolves the message id of the latest incoming (not-from-me) call chat
  /// item that is still in a non-terminal state, so the receiver can update it
  /// in place. Returns null when no such item exists.
  Future<String?> resolveIncomingCallChatItemId();

  /// Resolves the message id of the latest outgoing (isFromMe) call chat item
  /// that is still in a non-terminal state. Used by the caller when the emitter
  /// has not yet resolved the id (e.g. fast cancel during connecting phase).
  /// Returns null when no such item exists.
  Future<String?> resolveOutgoingCallChatItemId();

  /// Updates the receiver's pending incoming call chat item to
  /// [CallStatus.missed]. No-op when no matching item is found.
  ///
  /// Called when the ring timer expires or the user declines before answering.
  Future<void> markCallAsMissed();

  /// Updates the local-only [status] and participation [duration] of a
  /// previously emitted call chat item, in place. Per-side and local-only: it
  /// does not propagate to the other party.
  Future<void> updateCallChatItem(
    String messageId, {
    required CallStatus status,
    Duration? duration,
  });
}
