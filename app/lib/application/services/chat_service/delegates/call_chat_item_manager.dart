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

  /// Marks the latest pending incoming call item as `missed`. Returns `true`
  /// when an item was found and updated, `false` otherwise.
  Future<bool> markCallAsMissed() async {
    final messageId = await resolveIncomingCallChatItemId();
    if (messageId == null) {
      logger.info(
        'markCallAsMissed: No pending incoming call item found',
        name: _logKey,
      );
      return false;
    }
    await updateCallChatItem(messageId, status: CallStatus.missed);
    return true;
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

  /// Returns the transport call id carried by [message], or null when it is
  /// not a call item.
  String? callIdOf(Message message) {
    final attachment = message.attachments.firstWhereOrNull(
      CallMetadata.isCall,
    );
    return attachment == null ? null : CallMetadata.maybeOf(attachment)?.callId;
  }

  /// Whether [message] belongs to the pending incoming call identified by
  /// [pendingCallId].
  ///
  /// When the SDK has not yet observed the caller's live MatrixRTC membership,
  /// the incoming banner falls back to the Matrix room id. Call items still
  /// carry the full MatrixRTC callId in the form `roomId@timestamp`, so prefix
  /// matching preserves deterministic healing without relying on local time.
  bool matchesPendingCallId(Message message, String pendingCallId) {
    final messageCallId = callIdOf(message);
    if (messageCallId == null) return false;
    if (messageCallId == pendingCallId) return true;
    return !pendingCallId.contains('@') &&
        messageCallId.startsWith('$pendingCallId@');
  }

  /// Returns the id of the latest stale incoming call item created at or
  /// before [notAfter], or `null` if none. Retries up to
  /// [_resolveCallChatItemMaxAttempts] times to handle delayed chat history
  /// bootstrap. The [notAfter] guard prevents a newer, genuinely ringing call
  /// from being marked missed.
  Future<String?> resolveStaleIncomingCallItemIdBefore(
    DateTime notAfter,
  ) async {
    final match = await _resolveStaleIncomingCallItems(
      methodName: 'resolveStaleIncomingCallItemIdBefore',
      messageFilter: (message) =>
          !message.dateCreated.toUtc().isAfter(notAfter.toUtc()),
    );
    return match.lastOrNull;
  }

  /// Returns stale incoming call item ids created at or before [notAfter].
  ///
  /// Replay healing uses this to settle delayed history from the same ended
  /// call episode before the pending marker is cleared.
  Future<List<String>> resolveStaleIncomingCallItemIdsBefore(
    DateTime notAfter,
  ) async {
    return _resolveStaleIncomingCallItems(
      methodName: 'resolveStaleIncomingCallItemIdsBefore',
      messageFilter: (message) =>
          !message.dateCreated.toUtc().isAfter(notAfter.toUtc()),
    );
  }

  /// Returns all stale incoming call item ids for [callId].
  Future<List<String>> resolveStaleIncomingCallItemIdsByCallId(
    String callId,
  ) async {
    return _resolveStaleIncomingCallItems(
      methodName: 'resolveStaleIncomingCallItemIdsByCallId',
      messageFilter: (message) => matchesPendingCallId(message, callId),
    );
  }

  /// Updates the call item with [messageId] to the specified [status] and
  /// optional [duration]. Persists the change to the SDK and returns the
  /// updated [Message] so callers can refresh the UI immediately instead of
  /// waiting for the SDK stream echo. Returns `null` if the message is not
  /// found or does not contain a call attachment.
  Future<Message?> updateCallChatItem(
    String messageId, {
    required CallStatus status,
    Duration? duration,
  }) async {
    await ensureInitialized();
    final chatSdk = getChatSdk();
    if (chatSdk == null) {
      logger.warning('updateCallChatItem: Chat SDK unavailable', name: _logKey);
      return null;
    }
    try {
      final item = await chatSdk.getMessageById(messageId);
      if (item is! Message) {
        logger.warning(
          'updateCallChatItem: message $messageId not found',
          name: _logKey,
        );
        return null;
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
        return null;
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
      return item;
    } catch (e, stackTrace) {
      logger.error(
        'updateCallChatItem failed',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      return null;
    }
  }

  /// Returns stale incoming call item ids that satisfy [messageFilter].
  Future<List<String>> _resolveStaleIncomingCallItems({
    required String methodName,
    required bool Function(Message message) messageFilter,
  }) async {
    await ensureInitialized();
    final chatSdk = getChatSdk();
    if (chatSdk == null) {
      logger.warning('$methodName: Chat SDK unavailable', name: _logKey);
      return const [];
    }

    try {
      final items = await chatSdk.messages;
      final matches = items
          .whereType<Message>()
          .where(isStaleIncomingCall)
          .where(messageFilter)
          .map((message) => message.messageId)
          .toList(growable: false);

      logger.info(
        '$methodName: Found ${matches.length} item(s)',
        name: _logKey,
      );
      return matches;
    } catch (e, stackTrace) {
      logger.error(
        '$methodName failed',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      return const [];
    }
  }
}
