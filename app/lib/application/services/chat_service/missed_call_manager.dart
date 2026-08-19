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

  /// Reconciles the durable missed-call marker against chat history.
  ///
  /// Runs at chat open and after a marker is written. Heals EVERY stale
  /// incoming call item at or before the marker, not only the one the marker
  /// points at: back-to-back missed calls overwrite the single-slot marker,
  /// so earlier calls' items lose their marker and would otherwise stay stuck
  /// on `ringing`.
  /// - marked item not synced yet: keeps the marker so the stream can heal it
  ///   on arrival.
  /// - marked item already terminal: clears the marker, nothing left to heal.
  ///
  /// When [sweepUnmarked] is set (chat open only), also heals stale incoming
  /// items that never got a marker at all: rapid back-to-back calls can leave
  /// the latest call's own miss event never firing, so its item never gets a
  /// marker and the marker-gated sweep above skips it. This is safe because
  /// the top-of-method ringing guard already skips the whole reconcile while
  /// a call is ringing for the contact, so with no active ring, a stale
  /// incoming item is a settled miss. The miss-event and stream paths keep
  /// the marker-gated (DIDComm-race-safe) behavior by leaving [sweepUnmarked]
  /// at its default `false`. It also never heals an item younger than the
  /// call ring timeout, so a live call whose invite item arrives before its
  /// ring signal is never mistaken for a settled miss.
  ///
  /// Skipped while a call is ringing. Returns true only when it heals an item.
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

    // Heal EVERY stale incoming call item at or before the marker, not only
    // the one the marker points at. Back-to-back missed calls overwrite the
    // single-slot marker, so earlier calls' items lose their marker and would
    // otherwise stay stuck on `ringing`. A call currently ringing for this
    // contact is excluded so a live call is never healed prematurely.
    final ringingEvent = ref.read(incomingCallProvider).eventOrNull;
    final activeRingCallId =
        (ringingEvent != null &&
            ringingEvent.otherPartyPermanentChannelDid ==
                otherPartyPermanentChannelDid)
        ? ringingEvent.callId
        : null;

    // Bound the sweep. The marker-gated path sweeps up to the marker time.
    // The unmarked chat-open sweep additionally guards a live call whose
    // invite item arrived before its ring signal reached incomingCallProvider
    // (a transport race): it never heals an item younger than the ring
    // timeout, so a call that might still be ringing is left alone and only
    // settled misses are healed. An unmarked item older than the ring window
    // can no longer be ringing, so it heals on this or a later chat open. The
    // marker is kept whenever it is more recent, so a fresh miss still heals
    // immediately.
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
