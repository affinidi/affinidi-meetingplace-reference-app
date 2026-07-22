import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

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
  /// Runs at chat open and after a marker is written. Resolves the incoming
  /// call item the marker points at and settles it:
  /// - not synced yet: keeps the marker so the stream can heal it on arrival.
  /// - stale (still calling/ringing): heals it to missed and clears the marker.
  /// - already terminal: clears the marker, nothing left to heal.
  ///
  /// Skipped while a call is ringing. Returns true only when it heals an item.
  Future<bool> reconcilePendingMissedCall() async {
    const methodName = 'reconcilePendingMissedCall';
    if (!ref.mounted) return false;
    if (_isRingingForContact()) {
      _logger.info(
        '$methodName: Skip, call is still ringing',
        name: _className,
      );
      return false;
    }

    final pendingAt = await _pendingMissedCallAt();
    if (pendingAt == null) {
      _logger.info('$methodName: Skip, no pending marker', name: _className);
      return false;
    }

    final item = await callChatItemManager.resolveIncomingCallItemBefore(
      pendingAt,
      callId: await _pendingMissedCallId(),
    );
    if (item == null) {
      _logger.info(
        '$methodName: Item not synced yet, keeping marker',
        name: _className,
      );
      return false;
    }
    if (!callChatItemManager.isStaleIncomingCall(item)) {
      _logger.info(
        '$methodName: Item already settled, clearing marker',
        name: _className,
      );
      await _clearPendingMissedCall();
      return false;
    }

    await _healIncomingCallItemMissed(item.messageId, clearPendingMarker: true);
    return true;
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
  bool _isRingingForContact() {
    final ringingDid = ref
        .read(incomingCallProvider)
        .eventOrNull
        ?.otherPartyPermanentChannelDid;
    return ringingDid == otherPartyPermanentChannelDid;
  }

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
