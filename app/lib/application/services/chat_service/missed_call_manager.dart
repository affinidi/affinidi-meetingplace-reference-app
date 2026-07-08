import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../contacts_service/contacts_service.dart';
import 'delegates/call_chat_item_manager.dart';

/// Manages missed-call reconciliation: replaying pending markers and healing
/// stale incoming call items that arrive after the decline is recorded.
///
/// Follows the RCard/VRC replay-on-session-start pattern and mirrors the
/// lifecycle-aware healing that occurs when items arrive off-screen.
class MissedCallManager {
  MissedCallManager({
    required this.ref,
    required this.otherPartyPermanentChannelDid,
    required this.callChatItemManager,
    required this.getMessageById,
    required this.onUpsertChatItem,
  });

  final Ref ref;
  final String otherPartyPermanentChannelDid;
  final CallChatItemManager callChatItemManager;
  final Future<Message?> Function(String messageId) getMessageById;
  final void Function(ChatItem) onUpsertChatItem;

  /// Replays a pending missed-call marker recorded by
  /// [ContactsService.setPendingMissedCall] while the chat screen was closed
  /// or before the caller's message synced. Heals the latest stale incoming
  /// call item created at or before the recorded time, then clears the marker.
  Future<void> replayPendingMissedCall() async {
    final pendingAt = ref
        .read(contactsServiceProvider)
        .getContactByChannelDid(otherPartyPermanentChannelDid)
        ?.pendingMissedCallAt;
    if (pendingAt == null) return;

    final messageId = await callChatItemManager
        .resolveStaleIncomingCallItemIdBefore(pendingAt);
    if (messageId != null) {
      await _healIncomingCallItemMissed(messageId);
      return;
    }

    final ringTimeout = ref.read(environmentProvider).incomingCallRingTimeout;
    final expired =
        DateTime.now().toUtc().difference(pendingAt.toUtc()) > ringTimeout * 2;
    if (expired) {
      await ref
          .read(contactsServiceProvider.notifier)
          .clearPendingMissedCall(otherPartyPermanentChannelDid);
    }
  }

  /// Heals or updates [message] to `missed` when a pending marker exists for
  /// this contact and [message] is the stale incoming call item it refers to
  /// (created at or before the marker time). Covers the item arriving via the
  /// stream after the decline was recorded off-screen.
  Future<void> healArrivedStaleCallItemIfPending(Message message) async {
    if (!callChatItemManager.isStaleIncomingCall(message)) return;
    final pendingAt = ref
        .read(contactsServiceProvider)
        .getContactByChannelDid(otherPartyPermanentChannelDid)
        ?.pendingMissedCallAt;
    if (pendingAt == null) return;
    if (message.dateCreated.toUtc().isAfter(pendingAt.toUtc())) return;
    await _healIncomingCallItemMissed(message.messageId);
  }

  Future<void> _healIncomingCallItemMissed(String messageId) async {
    await callChatItemManager.updateCallChatItem(
      messageId,
      status: CallStatus.missed,
    );
    final updated = await getMessageById(messageId);
    if (updated is Message) onUpsertChatItem(updated);
    await ref
        .read(contactsServiceProvider.notifier)
        .clearPendingMissedCall(otherPartyPermanentChannelDid);
  }
}
