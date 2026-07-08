import 'dart:async';

import 'package:collection/collection.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:uuid/uuid.dart';

import '../../../../infrastructure/loggers/app_logger/app_logger.dart';

class CallChatItemManager {
  CallChatItemManager({
    required this.ensureInitialized,
    required this.getChatSdk,
    required this.logger,
  });

  static const _resolveCallChatItemRetryDelay = Duration(milliseconds: 50);
  static const _resolveCallChatItemMaxAttempts = 10;
  static const _logKey = 'CallChatItemManager';

  final Future<void> Function() ensureInitialized;
  final MeetingPlaceChatSDK? Function() getChatSdk;
  final AppLogger logger;

  /// Sends an outgoing call message with the specified [mediaType].
  /// Returns the message ID on success, or `null` if send failed.
  Future<String?> sendOutgoingCallMessage({
    required CallMediaType mediaType,
    String? callId,
  }) async {
    await ensureInitialized();
    final chatSdk = getChatSdk();
    if (chatSdk == null) {
      logger.warning(
        'sendOutgoingCallMessage: chat SDK unavailable',
        name: _logKey,
      );
      return null;
    }
    try {
      final attachment = CallMetadata.buildAttachment(
        mediaType: mediaType,
        status: CallStatus.calling,
        id: const Uuid().v4(),
        callId: callId ?? '',
      );
      final message = await chatSdk.sendTextMessage(
        '',
        attachments: [attachment],
      );
      if (message.status == ChatItemStatus.error) {
        logger.warning(
          'sendOutgoingCallMessage: delivery failed for ${message.messageId}',
          name: _logKey,
        );
      } else {
        logger.info(
          'sendOutgoingCallMessage: sent call item ${message.messageId}',
          name: _logKey,
        );
      }
      return message.messageId;
    } catch (e, stackTrace) {
      logger.error(
        'sendOutgoingCallMessage failed',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      return null;
    }
  }

  /// Returns the ID of the latest incoming call item that has not yet been
  /// settled (not ended, missed, or declined), or `null` if none exist.
  Future<String?> resolveIncomingCallChatItemId() => _resolveCallChatItemId(
    fromMe: false,
    attemptsRemaining: _resolveCallChatItemMaxAttempts,
  );

  /// Returns the ID of the latest outgoing call item that has not yet been
  /// settled (not ended, missed, or declined), or `null` if none exist.
  Future<String?> resolveOutgoingCallChatItemId() => _resolveCallChatItemId(
    fromMe: true,
    attemptsRemaining: _resolveCallChatItemMaxAttempts,
  );

  /// Finds the latest call item from the specified sender direction that is
  /// not yet settled (not ended, missed, or declined).
  Future<String?> _resolveCallChatItemId({
    required bool fromMe,
    required int attemptsRemaining,
  }) async {
    await ensureInitialized();
    final chatSdk = getChatSdk();
    final label = fromMe
        ? 'resolveOutgoingCallChatItemId'
        : 'resolveIncomingCallChatItemId';
    if (chatSdk == null) {
      logger.warning('$label: chat SDK unavailable', name: _logKey);
      return null;
    }
    try {
      final items = await chatSdk.messages;
      final match = items.whereType<Message>().lastWhereOrNull((message) {
        if (message.isFromMe != fromMe) return false;
        final attachment = message.attachments.firstWhereOrNull(
          CallMetadata.isCall,
        );
        if (attachment == null) return false;
        final call = CallMetadata.maybeOf(attachment);
        return call != null &&
            call.status != CallStatus.ended &&
            call.status != CallStatus.missed &&
            call.status != CallStatus.declined;
      });
      if (match == null) {
        if (attemptsRemaining <= 0) return null;
        await Future<void>.delayed(_resolveCallChatItemRetryDelay);
        return _resolveCallChatItemId(
          fromMe: fromMe,
          attemptsRemaining: attemptsRemaining - 1,
        );
      }
      logger.info('$label: ${match.messageId}', name: _logKey);
      return match.messageId;
    } catch (e, stackTrace) {
      logger.error(
        '$label failed',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      return null;
    }
  }

  /// Marks the latest pending incoming call item as `missed`. A no-op if
  /// no pending incoming call item exists.
  Future<void> markCallAsMissed() async {
    final messageId = await resolveIncomingCallChatItemId();
    if (messageId == null) {
      logger.info(
        'markCallAsMissed: No pending incoming call item found',
        name: _logKey,
      );
      return;
    }
    await updateCallChatItem(messageId, status: CallStatus.missed);
  }

  /// Whether [message] is an incoming call item still in a non-final status
  /// (`calling`/`ringing`) and therefore eligible to be reconciled to
  /// `missed`.
  bool isStaleIncomingCall(Message message) {
    if (message.isFromMe) return false;
    final attachment = message.attachments.firstWhereOrNull(
      CallMetadata.isCall,
    );
    if (attachment == null) return false;
    final call = CallMetadata.maybeOf(attachment);
    return call != null &&
        (call.status == CallStatus.calling ||
            call.status == CallStatus.ringing);
  }

  /// Marks the call item with [messageId] as `missed` and returns the
  /// persisted [Message] after the update, or `null` if the item is no
  /// longer found.
  Future<Message?> markItemMissed(String messageId) async {
    await updateCallChatItem(messageId, status: CallStatus.missed);
    final chatSdk = getChatSdk();
    if (chatSdk == null) return null;
    final updated = await chatSdk.getMessageById(messageId);
    return updated is Message ? updated : null;
  }

  /// Returns message IDs of incoming call items stuck in non-final status
  /// (`calling`/`ringing`) that should be reconciled to `missed`.
  /// If [liveIncomingCall] is true, excludes the most recent item to avoid
  /// marking an actively ringing call as missed.
  /// If [olderThan] is provided, only items whose [Message.dateCreated] is
  /// older than that duration are included — items within the window may still
  /// be genuinely ringing (e.g. after an app restart).
  Future<List<String>> findStaleIncomingCallItemIds({
    required bool liveIncomingCall,
    Duration? olderThan,
  }) async {
    final messages = await findStaleIncomingCallMessages(
      liveIncomingCall: liveIncomingCall,
      olderThan: olderThan,
    );
    return messages.map((m) => m.messageId).toList();
  }

  /// Returns incoming call items stuck in non-final status
  /// (`calling`/`ringing`). If [liveIncomingCall] is true, excludes the most
  /// recent item. If [olderThan] is provided, only items older than that
  /// duration are included.
  Future<List<Message>> findStaleIncomingCallMessages({
    required bool liveIncomingCall,
    Duration? olderThan,
  }) async {
    await ensureInitialized();
    final chatSdk = getChatSdk();
    if (chatSdk == null) {
      logger.warning(
        'findStaleIncomingCallMessages: chat SDK unavailable',
        name: _logKey,
      );
      return const [];
    }
    try {
      final items = await chatSdk.messages;
      final now = DateTime.now().toUtc();
      final stale =
          items
              .whereType<Message>()
              .where(isStaleIncomingCall)
              .where(
                (m) =>
                    olderThan == null ||
                    now.difference(m.dateCreated.toUtc()) > olderThan,
              )
              .toList()
            ..sort((a, b) => a.dateCreated.compareTo(b.dateCreated));

      if (stale.isEmpty) return const [];

      final reconcilable = liveIncomingCall
          ? stale.sublist(0, stale.length - 1)
          : stale;
      logger.info(
        'findStaleIncomingCallMessages: ${reconcilable.length} stale item(s)',
        name: _logKey,
      );
      return reconcilable;
    } catch (e, stackTrace) {
      logger.error(
        'findStaleIncomingCallMessages failed',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      return const [];
    }
  }

  /// Updates the call item with [messageId] to the specified [status] and
  /// optional [duration]. Persists the change to the SDK. Logs a warning if
  /// the message is not found or does not contain a call attachment.
  Future<void> updateCallChatItem(
    String messageId, {
    required CallStatus status,
    Duration? duration,
    String? callId,
  }) async {
    await ensureInitialized();
    final chatSdk = getChatSdk();
    if (chatSdk == null) {
      logger.warning('updateCallChatItem: Chat SDK unavailable', name: _logKey);
      return;
    }
    try {
      final item = await chatSdk.getMessageById(messageId);
      if (item is! Message) {
        logger.warning(
          'updateCallChatItem: message $messageId not found',
          name: _logKey,
        );
        return;
      }
      final callAttachment = item.attachments.firstWhereOrNull(
        CallMetadata.isCall,
      );
      final existing = callAttachment == null
          ? null
          : CallMetadata.maybeOf(callAttachment);
      if (existing == null) {
        logger.warning(
          'updateCallChatItem: $messageId is not a call item',
          name: _logKey,
        );
        return;
      }
      final updated = CallMetadata.buildAttachment(
        mediaType: existing.mediaType,
        status: status,
        durationMs: duration?.inMilliseconds ?? existing.durationMs,
        id: callAttachment!.id,
        callId: callId ?? '',
      );
      item.attachments = [
        for (final a in item.attachments)
          if (CallMetadata.isCall(a)) updated else a,
      ];
      await chatSdk.updateMessage(item);
      logger.info(
        'updateCallChatItem: $messageId -> ${status.name}',
        name: _logKey,
      );
    } catch (e, stackTrace) {
      logger.error(
        'updateCallChatItem failed',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }
}
