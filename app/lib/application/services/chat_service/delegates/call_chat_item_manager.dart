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
  ///
  /// [onSent] is called immediately after the message is confirmed by the
  /// server, before the chat stream echoes it back. Use it to inject the item
  /// into the UI right away so the caller doesn't wait for the stream
  /// round-trip.
  Future<String?> sendOutgoingCallMessage({
    required CallMediaType mediaType,
    String? callId,
    void Function(Message message)? onSent,
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
        onSent?.call(message);
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
  /// (`calling`/`ringing`), eligible to be reconciled to `missed`.
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

  /// Returns the id of the latest stale incoming call item created at or before
  /// [notAfter], or `null` if none. Single-pass (no retry): used by the
  /// session-start replay once chat history is already loaded. The [notAfter]
  /// guard prevents a newer, genuinely ringing call from being marked missed by
  /// a stale pending-miss marker.
  Future<String?> resolveStaleIncomingCallItemIdBefore(
    DateTime notAfter,
  ) async {
    await ensureInitialized();
    final chatSdk = getChatSdk();
    if (chatSdk == null) {
      logger.warning(
        'resolveStaleIncomingCallItemIdBefore: Chat SDK unavailable',
        name: _logKey,
      );
      return null;
    }
    try {
      final items = await chatSdk.messages;
      final match = items.whereType<Message>().lastWhereOrNull(
        (m) =>
            isStaleIncomingCall(m) &&
            !m.dateCreated.toUtc().isAfter(notAfter.toUtc()),
      );
      return match?.messageId;
    } catch (e, stackTrace) {
      logger.error(
        'resolveStaleIncomingCallItemIdBefore failed',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      return null;
    }
  }

  /// Updates the call item with [messageId] to the specified [status] and
  /// optional [duration]. Persists the change to the SDK. Logs a warning if
  /// the message is not found or does not contain a call attachment.
  Future<void> updateCallChatItem(
    String messageId, {
    required CallStatus status,
    Duration? duration,
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
        callId: existing.callId,
        durationMs: duration?.inMilliseconds ?? existing.durationMs,
        id: callAttachment!.id,
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
