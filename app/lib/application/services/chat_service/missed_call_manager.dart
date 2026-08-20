import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../contacts_service/contacts_service.dart';
import '../incoming_call_service/incoming_call_notifier.dart';
import 'delegates/call_chat_item_manager.dart';

/// Manages missed-call reconciliation: healing stale incoming call items
/// left behind when a caller hangs up or a decline is recorded off-screen.
///
/// Reconciliation is idempotent and self-clearing: once the referenced call
/// item is settled (healed to missed, or already terminal in history) the
/// durable marker is cleared, so reopening the chat does no further work.
class MissedCallManager {
  MissedCallManager({
    required this.ref,
    required this.otherPartyPermanentChannelDid,
    required this.callChatItemManager,
    required this.onUpsertChatItem,
  });

  final Ref ref;
  final String otherPartyPermanentChannelDid;
  final CallChatItemManager callChatItemManager;
  final void Function(ChatItem) onUpsertChatItem;

  static const _className = 'MissedCallManager';

  AppLogger get _logger => ref.read(appLoggerProvider);

  /// Reconciles stale incoming call items to `missed`.
  ///
  /// Heals every stale incoming call item up to `sweepBound`.
  /// When [sweepUnmarked] is true (chat-open only), sweeps all unmarked stale
  /// items.
  /// Skipped while a call is ringing. Returns true only when at least one
  /// item was healed.
  Future<bool> reconcilePendingMissedCall({bool sweepUnmarked = false}) async {
    const methodName = 'reconcilePendingMissedCall';
    if (!ref.mounted) return false;
    final pendingCallId = await _pendingMissedCallId();
    if (_isRingingForContact(callId: pendingCallId)) {
      _logger.info(
        '$methodName: Skip, call is still ringing',
        name: _className,
      );
      return false;
    }

    final pendingAt = await _pendingMissedCallAt();
    if (pendingAt == null && !sweepUnmarked) {
      _logger.info('$methodName: Skip, no pending marker', name: _className);
      return false;
    }

    // Exclude a call currently ringing for this contact so it's never healed
    // prematurely.
    final ringingEvent = ref.read(incomingCallProvider).eventOrNull;
    final activeRingCallId =
        (ringingEvent != null &&
            ringingEvent.otherPartyPermanentChannelDid ==
                otherPartyPermanentChannelDid)
        ? ringingEvent.callId
        : null;

    // Bound the sweep: the marker time, or — for the unmarked sweep — no
    // later than the ring timeout, so an item that might still be ringing is
    // left alone. The marker wins whenever it's more recent.
    final sweepBound = sweepUnmarked
        ? _laterOf(
            pendingAt,
            clock.now().toUtc().subtract(
              ref.read(environmentProvider).callRingTimeout,
            ),
          )
        : pendingAt;

    final staleItems = await callChatItemManager
        .resolveStaleIncomingCallItemsBefore(
          sweepBound,
          excludeCallId: activeRingCallId,
        );
    var healedAny = false;
    for (final item in staleItems) {
      if (!ref.mounted) return healedAny;
      await _healIncomingCallItemMissed(
        item.messageId,
        clearPendingMarker: false,
      );
      healedAny = true;
    }

    // No durable marker to manage on the chat-open unmarked sweep.
    if (pendingAt == null) return healedAny;

    // The marker stays tied to its own target: if the latest missed call's
    // item has not synced yet, keep the marker so the stream can heal it on
    // arrival; otherwise it is settled now, so clear the marker.
    if (!ref.mounted) return healedAny;
    final markedItem = await callChatItemManager.resolveIncomingCallItemBefore(
      pendingAt,
      callId: pendingCallId,
    );
    if (markedItem == null) {
      _logger.info(
        '$methodName: Marked item not synced yet, keeping marker',
        name: _className,
      );
      return healedAny;
    }
    // A null/empty call id can match an unrelated older item by time alone,
    // so only clear the marker when this sweep actually healed the target;
    // otherwise keep it for the marker-gated stream heal to catch later.
    final hasPendingCallId = pendingCallId != null && pendingCallId.isNotEmpty;
    if (!hasPendingCallId && !healedAny) {
      return healedAny;
    }
    await _clearPendingMissedCall();
    return healedAny;
  }

  /// Heals [message] to `missed` when a stale incoming call item arrives via
  /// the stream and a pending marker exists. Protects live calls: a new call
  /// item arriving before its ring signal (DIDComm race) is never prematurely
  /// healed. The marker is cleared once an ended call's item is healed.
  Future<void> healArrivedStaleCallItemIfPending(Message message) async {
    final methodName = 'healArrivedStaleCallItemIfPending';
    if (!ref.mounted) return;
    if (!callChatItemManager.isStaleIncomingCall(message)) {
      _logger.info(
        '$methodName: Skip, not a stale incoming call',
        name: _className,
      );
      return;
    }
    if (_isRingingForContact()) {
      _logger.info(
        '$methodName: Skip, call is still ringing',
        name: _className,
      );
      return;
    }

    final pendingAt = await _pendingMissedCallAt();
    if (pendingAt == null) {
      _logger.info('$methodName: Skip, no pending marker', name: _className);
      return;
    }
    if (message.dateCreated.toUtc().isAfter(pendingAt.toUtc())) {
      _logger.info(
        '$methodName: Skip, message is newer than pending marker',
        name: _className,
      );
      return;
    }
    await _healIncomingCallItemMissed(
      message.messageId,
      clearPendingMarker: true,
    );
  }

  /// Returns true if a call for this contact is currently ringing.
  bool _isRingingForContact({String? callId}) {
    final ringingEvent = ref.read(incomingCallProvider).eventOrNull;
    if (ringingEvent == null) return false;
    if (ringingEvent.otherPartyPermanentChannelDid !=
        otherPartyPermanentChannelDid) {
      return false;
    }
    if (callId == null || callId.isEmpty) return true;
    return ringingEvent.callId == callId;
  }

  /// Returns the later of two instants. A null [a] yields [b].
  DateTime _laterOf(DateTime? a, DateTime b) =>
      (a != null && a.toUtc().isAfter(b)) ? a : b;

  /// Updates a stale incoming call item to missed.
  Future<void> _healIncomingCallItemMissed(
    String messageId, {
    required bool clearPendingMarker,
  }) async {
    final methodName = '_healIncomingCallItemMissed';
    if (!ref.mounted) return;
    _logger.info(
      '$methodName: Updating message to missed: messageId=$messageId',
      name: _className,
    );
    final updated = await callChatItemManager.updateCallChatItem(
      messageId,
      status: CallStatus.missed,
    );
    if (!ref.mounted) return;
    if (updated != null) onUpsertChatItem(updated);
    if (!ref.mounted || !clearPendingMarker) return;
    await _clearPendingMissedCall();
  }

  Future<DateTime?> _pendingMissedCallAt() {
    return ref
        .read(contactsServiceProvider.notifier)
        .getPendingMissedCallAt(otherPartyPermanentChannelDid);
  }

  Future<String?> _pendingMissedCallId() {
    return ref
        .read(contactsServiceProvider.notifier)
        .getPendingMissedCallId(otherPartyPermanentChannelDid);
  }

  Future<void> _clearPendingMissedCall() {
    return ref
        .read(contactsServiceProvider.notifier)
        .clearPendingMissedCall(otherPartyPermanentChannelDid);
  }
}
