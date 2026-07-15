import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../contacts_service/contacts_service.dart';
import '../incoming_call_service/incoming_call_notifier.dart';
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
  static const _backgroundReplayRetryDelay = Duration(milliseconds: 250);
  static const _backgroundReplayMaxAttempts = 8;

  final Ref ref;
  final String otherPartyPermanentChannelDid;
  final CallChatItemManager callChatItemManager;
  final Future<Message?> Function(String messageId) getMessageById;
  final void Function(ChatItem) onUpsertChatItem;
  bool _backgroundReplayScheduled = false;

  static const _className = 'MissedCallManager';

  AppLogger get _logger => ref.read(appLoggerProvider);

  /// Replays a pending missed-call marker and heals stale incoming call items
  /// at chat open. Marker exists only for unanswered calls; skipped if a call
  /// is ringing. Durable across restarts.
  ///
  /// Also handles crash-recovery: if the app died while the incoming banner
  /// was showing (before `_markCallAsMissed` ran), the `activeIncomingCallId`
  /// marker is used to reconstruct the missed-call state and heal the item.
  Future<void> replayPendingMissedCall() async {
    final methodName = 'replayPendingMissedCall';
    if (!ref.mounted) {
      _logger.info('$methodName: Skip, ref not mounted', name: _className);
      return;
    }
    if (_isRingingForContact()) {
      _logger.info(
        '$methodName: Skip, call is still ringing',
        name: _className,
      );
      return;
    }
    final pendingCallId = await _pendingMissedCallId();
    if (pendingCallId == null) {
      await _replayFromCrashRecoveryIfNeeded(methodName);
      return;
    }
    final healedAny = await _healStaleIncomingCallItemsByCallId(
      pendingCallId,
      clearPendingMarker: true,
    );
    if (!healedAny) {
      _logger.info('$methodName: No stale item found', name: _className);
      return;
    }
  }

  /// Attempts immediate reconciliation for an active chat session after the
  /// durable missed-call marker has been written. If no stale item is available
  /// yet, a short follow-up window stays armed so delayed history can still be
  /// healed by this manager instead of by upstream services.
  Future<bool> reconcilePendingMissedCall() async {
    const methodName = 'reconcilePendingMissedCall';
    if (!ref.mounted) {
      _logger.info('$methodName: Skip, ref not mounted', name: _className);
      return false;
    }
    if (_isRingingForContact()) {
      _logger.info(
        '$methodName: Skip, call is still ringing',
        name: _className,
      );
      return false;
    }

    final pendingCallId = await _pendingMissedCallId();
    if (pendingCallId == null) {
      _logger.info('$methodName: Skip, no pending marker', name: _className);
      return false;
    }

    final healedAny = await _healStaleIncomingCallItemsByCallId(
      pendingCallId,
      clearPendingMarker: true,
    );
    if (!healedAny) {
      scheduleReplayPendingMissedCallFollowUp();
    }
    return healedAny;
  }

  /// Schedules a short follow-up replay window for chat-open cases where the
  /// stale call item arrives after the first bootstrap pass.
  void scheduleReplayPendingMissedCallFollowUp() {
    if (_backgroundReplayScheduled) {
      _logger.info(
        'scheduleReplayPendingMissedCallFollowUp: Skip, already scheduled',
        name: _className,
      );
      return;
    }
    _backgroundReplayScheduled = true;
    unawaited(_runReplayPendingMissedCallFollowUp());
  }

  /// Heals [message] to `missed` when a stale incoming call item arrives via
  /// the stream and a pending marker exists. Protects live calls: a new call
  /// item arriving before its ring signal (DIDComm race) is never prematurely
  /// healed. The marker is cleared once an ended call's item is healed.
  Future<void> healArrivedStaleCallItemIfPending(Message message) async {
    final methodName = 'healArrivedStaleCallItemIfPending';
    if (!ref.mounted) {
      _logger.info('$methodName: Skip, ref not mounted', name: _className);
      return;
    }
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

    final pendingCallId = await _pendingMissedCallId();
    if (pendingCallId == null) {
      _logger.info('$methodName: Skip, no pending marker', name: _className);
      return;
    }
    if (!callChatItemManager.matchesPendingCallId(message, pendingCallId)) {
      _logger.info(
        '$methodName: Skip, message callId does not match pending marker',
        name: _className,
      );
      return;
    }
    await _healIncomingCallItemMissed(
      message.messageId,
      clearPendingMarker: true,
    );
  }

  /// Retries replay healing for delayed history while the marker remains set.
  Future<void> _runReplayPendingMissedCallFollowUp() async {
    final methodName = '_runReplayPendingMissedCallFollowUp';
    try {
      for (var attempt = 0; attempt < _backgroundReplayMaxAttempts; attempt++) {
        if (!ref.mounted) {
          _logger.info('$methodName: Stop, ref not mounted', name: _className);
          return;
        }
        if (!await _hasPendingMissedCallMarker()) {
          _logger.info(
            '$methodName: Stop, no pending marker',
            name: _className,
          );
          return;
        }
        if (_isRingingForContact()) {
          _logger.info('$methodName: Stop, call is ringing', name: _className);
          return;
        }

        final pendingCallId = await _pendingMissedCallId();
        if (pendingCallId == null) {
          _logger.info(
            '$methodName: Stop, no pending marker',
            name: _className,
          );
          return;
        }

        final healedAny = await _healStaleIncomingCallItemsByCallId(
          pendingCallId,
          clearPendingMarker: true,
        );
        if (healedAny) return;

        if (attempt < _backgroundReplayMaxAttempts - 1) {
          await Future<void>.delayed(_backgroundReplayRetryDelay);
        } else {
          await _clearPendingMissedCall();
        }
      }
    } finally {
      _backgroundReplayScheduled = false;
    }
  }

  /// Returns true if a call for this contact is currently ringing.
  bool _isRingingForContact() {
    final ringingDid = ref
        .read(incomingCallProvider)
        .eventOrNull
        ?.otherPartyPermanentChannelDid;
    return ringingDid == otherPartyPermanentChannelDid;
  }

  /// Handles crash-recovery: if `activeIncomingCallId` is set but
  /// `pendingMissedCallId` is not, the app died before `_markCallAsMissed`
  /// ran. Promotes the active call marker to a pending missed marker and heals.
  Future<void> _replayFromCrashRecoveryIfNeeded(String callerMethod) async {
    final activeCallId = await _activeIncomingCallId();
    if (activeCallId == null) {
      _logger.info(
        '$callerMethod: Skip, no pending marker and no crash-recovery marker',
        name: _className,
      );
      return;
    }
    _logger.info(
      '$callerMethod: Crash-recovery — promoting activeIncomingCallId '
      '$activeCallId to pending missed marker',
      name: _className,
    );
    await ref
        .read(contactsServiceProvider.notifier)
        .setPendingMissedCall(
          otherPartyPermanentChannelDid,
          callId: activeCallId,
        );
    await _clearActiveIncomingCall();
    final healedAny = await _healStaleIncomingCallItemsByCallId(
      activeCallId,
      clearPendingMarker: true,
    );
    if (!healedAny) {
      _logger.info(
        '$callerMethod: Crash-recovery — no stale item yet, follow-up armed',
        name: _className,
      );
      scheduleReplayPendingMissedCallFollowUp();
    }
  }

  /// Returns the pending missed-call id for this contact, if any.
  Future<String?> _pendingMissedCallId() {
    return ref
        .read(contactsServiceProvider.notifier)
        .getPendingMissedCallId(otherPartyPermanentChannelDid);
  }

  /// Returns whether a pending missed-call marker still exists.
  Future<bool> _hasPendingMissedCallMarker() async {
    return await _pendingMissedCallId() != null;
  }

  /// Heals the newest stale incoming call item matching [callId].
  ///
  /// Only the most recent match is healed to prevent older stale items from
  /// different call episodes sharing the same roomId prefix from being settled
  /// by an unrelated marker.
  Future<bool> _healStaleIncomingCallItemsByCallId(
    String callId, {
    required bool clearPendingMarker,
  }) async {
    const methodName = '_healStaleIncomingCallItemsByCallId';
    final messageIds = await callChatItemManager
        .resolveStaleIncomingCallItemIdsByCallId(callId);
    if (messageIds.isEmpty) {
      _logger.info(
        '$methodName: Skip, no stale items found for $callId',
        name: _className,
      );
      return false;
    }

    await _healIncomingCallItemMissed(
      messageIds.last,
      clearPendingMarker: false,
    );

    if (clearPendingMarker) {
      await _clearPendingMissedCall();
    }
    return true;
  }

  /// Updates a stale incoming call item to missed.
  Future<void> _healIncomingCallItemMissed(
    String messageId, {
    required bool clearPendingMarker,
  }) async {
    final methodName = '_healIncomingCallItemMissed';
    if (!ref.mounted) {
      _logger.info('$methodName: Skip, ref not mounted', name: _className);
      return;
    }
    _logger.info(
      '$methodName: Updating message to missed: messageId=$messageId',
      name: _className,
    );
    final updated = await callChatItemManager.updateCallChatItem(
      messageId,
      status: CallStatus.missed,
    );
    if (!ref.mounted) {
      _logger.info(
        '$methodName: Stop, ref not mounted after update',
        name: _className,
      );
      return;
    }
    if (updated != null) {
      onUpsertChatItem(updated);
    } else {
      _logger.info(
        '$methodName: Skip, call item update returned null for $messageId',
        name: _className,
      );
    }
    if (!ref.mounted) {
      _logger.info(
        '$methodName: Stop, ref not mounted before clearing marker',
        name: _className,
      );
      return;
    }
    if (!clearPendingMarker) {
      _logger.info(
        '$methodName: Skip, marker clear not requested for $messageId',
        name: _className,
      );
      return;
    }
    await _clearPendingMissedCall();
  }

  /// Returns the active incoming call id for this contact, if any.
  Future<String?> _activeIncomingCallId() {
    return ref
        .read(contactsServiceProvider.notifier)
        .getActiveIncomingCallId(otherPartyPermanentChannelDid);
  }

  /// Clears the active incoming call marker for this contact.
  Future<void> _clearActiveIncomingCall() {
    return ref
        .read(contactsServiceProvider.notifier)
        .clearActiveIncomingCall(otherPartyPermanentChannelDid);
  }

  /// Clears the pending missed-call marker for this contact.
  Future<void> _clearPendingMissedCall() {
    return ref
        .read(contactsServiceProvider.notifier)
        .clearPendingMissedCall(otherPartyPermanentChannelDid);
  }
}
