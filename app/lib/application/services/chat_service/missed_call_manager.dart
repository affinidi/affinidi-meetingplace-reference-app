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
  /// Heals every stale incoming call item up to the sweep bound.
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

    final healedAny = await _healStaleItemsUpTo(
      _resolveSweepBound(pendingAt, sweepUnmarked),
      excludeCallId: _activeRingCallId(),
    );
    return await _settlePendingMarker(
      pendingAt,
      pendingCallId,
      healedAny: healedAny,
    );
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

  /// CallId of a call currently ringing for this contact, to exclude from
  /// healing.
  String? _activeRingCallId() {
    final ringingEvent = ref.read(incomingCallProvider).eventOrNull;
    return (ringingEvent != null &&
            ringingEvent.otherPartyPermanentChannelDid ==
                otherPartyPermanentChannelDid)
        ? ringingEvent.callId
        : null;
  }

  /// Bounds the sweep to [pendingAt], or no later than the ring timeout when
  /// [sweepUnmarked].
  DateTime? _resolveSweepBound(DateTime? pendingAt, bool sweepUnmarked) {
    if (!sweepUnmarked) return pendingAt;
    return _laterOf(
      pendingAt,
      clock.now().toUtc().subtract(
        ref.read(environmentProvider).callRingTimeout,
      ),
    );
  }

  /// Heals every stale incoming call item up to [sweepBound], excluding
  /// [excludeCallId]. Returns true if at least one item was healed.
  Future<bool> _healStaleItemsUpTo(
    DateTime? sweepBound, {
    required String? excludeCallId,
  }) async {
    final staleItems = await callChatItemManager
        .resolveStaleIncomingCallItemsBefore(
          sweepBound,
          excludeCallId: excludeCallId,
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
    return healedAny;
  }

  /// Settles the marker after healing: keeps it if the marked item hasn't
  /// synced yet, or if a null-callId match can't be trusted; otherwise
  /// clears it. Returns [healedAny] unchanged.
  Future<bool> _settlePendingMarker(
    DateTime? pendingAt,
    String? pendingCallId, {
    required bool healedAny,
  }) async {
    const methodName = 'reconcilePendingMissedCall';
    if (pendingAt == null) return healedAny;
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
    final hasPendingCallId = pendingCallId != null && pendingCallId.isNotEmpty;
    if (!hasPendingCallId && !healedAny) {
      return healedAny;
    }
    await _clearPendingMissedCall();
    return healedAny;
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
