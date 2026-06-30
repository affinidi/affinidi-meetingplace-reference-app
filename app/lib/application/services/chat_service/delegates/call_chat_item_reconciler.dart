import 'package:meeting_place_chat/meeting_place_chat.dart';

import 'call_chat_item_manager.dart';

/// Reconciles incoming call items that were left in a non-final status
/// (`calling`/`ringing`) to `missed`.
///
/// Two triggers:
/// - **Session start** ([onSessionStart]): scans all persisted items in case
///   a decline happened while the chat screen was closed, a sync race occurred,
///   or the app was killed.
/// - **Stream arrival** ([onStreamItem]): heals a single item that arrives via
///   the chat stream after the decline signal was already consumed.
///
/// The [isCallLive] callback lets the reconciler check whether a call from
/// this contact is genuinely ringing right now. When true, the most recent
/// stale item is left untouched so a live ringing call is never prematurely
/// marked missed.
class CallChatItemReconciler {
  CallChatItemReconciler({
    required this.manager,
    required this.isCallLive,
    required this.upsertItem,
  });

  final CallChatItemManager manager;
  final bool Function() isCallLive;
  final void Function(Message) upsertItem;

  /// Scans all persisted stale items and marks each `missed`.
  Future<void> onSessionStart() async {
    final staleIds = await manager.findStaleIncomingCallItemIds(
      liveIncomingCall: isCallLive(),
    );
    for (final id in staleIds) {
      await _markMissedAndUpsert(id);
    }
  }

  /// Heals a single [message] if it arrived via the stream after the decline
  /// signal was already consumed and no call is currently ringing.
  Future<void> onStreamItem(Message message) async {
    if (!manager.isStaleIncomingCall(message)) return;
    if (isCallLive()) return;
    await _markMissedAndUpsert(message.messageId);
  }

  Future<void> _markMissedAndUpsert(String messageId) async {
    final updated = await manager.markItemMissed(messageId);
    if (updated != null) upsertItem(updated);
  }
}
