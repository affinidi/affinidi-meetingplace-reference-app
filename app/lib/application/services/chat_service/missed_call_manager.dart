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

  final Ref ref;
  final String otherPartyPermanentChannelDid;
  final CallChatItemManager callChatItemManager;
  final Future<Message?> Function(String messageId) getMessageById;
  final void Function(ChatItem) onUpsertChatItem;

  static const _className = 'MissedCallManager';

  AppLogger get _logger => ref.read(appLoggerProvider);

  /// Replays a pending missed-call marker and heals stale incoming call items
  /// at chat open. Marker exists only for unanswered calls; skipped if a call
  /// is ringing. Durable across restarts.
  Future<void> replayPendingMissedCall() async {
    final methodName = 'replayPendingMissedCall';
    if (!ref.mounted) return;
    if (_isRingingForContact()) {
      _logger.info(
        '$methodName: Skip, call is still ringing',
        name: _className,
      );
      return;
    }
    final messageId = await callChatItemManager
        .resolveStaleIncomingCallItemIdBefore(DateTime.now().toUtc());
    if (messageId == null) {
      _logger.info('$methodName: No stale item found', name: _className);
      return;
    }
    await _healIncomingCallItemMissed(messageId);
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

    final pendingAt = ref
        .read(contactsServiceProvider)
        .getContactByChannelDid(otherPartyPermanentChannelDid)
        ?.pendingMissedCallAt;
    if (pendingAt == null) {
      _logger.info('$methodName: Skip, no pending marker', name: _className);
      return;
    }
    await _healIncomingCallItemMissed(message.messageId);
  }

  /// Returns true if a call for this contact is currently ringing.
  bool _isRingingForContact() {
    final ringingDid = ref
        .read(incomingCallProvider)
        .eventOrNull
        ?.otherPartyPermanentChannelDid;
    return ringingDid == otherPartyPermanentChannelDid;
  }

  /// Updates message to missed and clears the pending marker.
  Future<void> _healIncomingCallItemMissed(String messageId) async {
    final methodName = '_healIncomingCallItemMissed';
    if (!ref.mounted) return;
    _logger.info(
      '$methodName: Updating message to missed: messageId=$messageId',
      name: _className,
    );
    await callChatItemManager.updateCallChatItem(
      messageId,
      status: CallStatus.missed,
    );
    if (!ref.mounted) return;
    final updated = await getMessageById(messageId);
    if (updated != null) onUpsertChatItem(updated);
    if (!ref.mounted) return;
    await ref
        .read(contactsServiceProvider.notifier)
        .clearPendingMissedCall(otherPartyPermanentChannelDid);
  }
}
