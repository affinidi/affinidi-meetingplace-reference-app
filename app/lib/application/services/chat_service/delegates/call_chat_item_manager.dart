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

  /// Resolves the latest unsettled incoming call item, preferring an exact
  /// callId match when [callId] is provided.
  Future<String?> resolveIncomingCallChatItemId({String? callId}) =>
      _resolveCallChatItemId(
        fromMe: false,
        attemptsRemaining: _resolveCallChatItemMaxAttempts,
        callId: callId,
      );

  /// Resolves the latest unsettled outgoing call item, preferring an exact
  /// callId match when [callId] is provided.
  Future<String?> resolveOutgoingCallChatItemId({String? callId}) =>
      _resolveCallChatItemId(
        fromMe: true,
        attemptsRemaining: _resolveCallChatItemMaxAttempts,
        callId: callId,
      );

  /// Returns the incoming call item matching [callId]
  /// (or latest by direction when callId absent) created no later than
  /// [notAfter], or null if not found.
  Future<Message?> resolveIncomingCallItemBefore(
    DateTime notAfter, {
    String? callId,
  }) async {
    const label = 'resolveIncomingCallItemBefore';
    await ensureInitialized();
    final chatSdk = getChatSdk();
    if (chatSdk == null) {
      logger.warning('$label: chat SDK unavailable', name: _logKey);
      return null;
    }
    try {
      final items = await chatSdk.messages;
      final boundUtc = notAfter.toUtc();
      final matchCallId = callId != null && callId.isNotEmpty;
      final match = items.whereType<Message>().lastWhereOrNull((message) {
        if (message.isFromMe) return false;
        if (message.dateCreated.toUtc().isAfter(boundUtc)) return false;
        final attachment = message.attachments.firstWhereOrNull(
          CallMetadata.isCall,
        );
        if (attachment == null) return false;
        if (!matchCallId) return true;
        return CallMetadata.maybeOf(attachment)?.callId == callId;
      });
      if (match == null) {
        logger.info(
          '$label: no incoming call item at or before $notAfter',
          name: _logKey,
        );
        return null;
      }
      logger.info('$label: ${match.messageId}', name: _logKey);
      return match;
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

  /// Returns every stale incoming call item (status `calling`/`ringing`)
  /// created no later than [notAfter], excluding any item whose call id equals
  /// [excludeCallId].
  ///
  /// Back-to-back missed calls overwrite the single-slot durable marker, so
  /// only the latest call keeps a marker and earlier items are orphaned on
  /// `ringing`. Reconciliation uses this to heal them all, not just the
  /// marked one. [excludeCallId] protects a call that is currently ringing
  /// from being healed.
  ///
  /// A null [notAfter] returns every stale incoming item with no upper time
  /// bound. Used by the chat-open reconcile, which has no marker to bound by.
  Future<List<Message>> resolveStaleIncomingCallItemsBefore(
    DateTime? notAfter, {
    String? excludeCallId,
  }) async {
    const label = 'resolveStaleIncomingCallItemsBefore';
    await ensureInitialized();
    final chatSdk = getChatSdk();
    if (chatSdk == null) {
      logger.warning('$label: chat SDK unavailable', name: _logKey);
      return const [];
    }
    try {
      final items = await chatSdk.messages;
      final boundUtc = notAfter?.toUtc();
      final hasExclude = excludeCallId != null && excludeCallId.isNotEmpty;
      final matches = items.whereType<Message>().where((message) {
        if (boundUtc != null && message.dateCreated.toUtc().isAfter(boundUtc)) {
          return false;
        }
        if (!isStaleIncomingCall(message)) return false;
        if (!hasExclude) return true;
        final attachment = message.attachments.firstWhereOrNull(
          CallMetadata.isCall,
        );
        final callId = attachment == null
            ? null
            : CallMetadata.maybeOf(attachment)?.callId;
        return callId != excludeCallId;
      }).toList();
      logger.info('$label: ${matches.length} stale item(s)', name: _logKey);
      return matches;
    } catch (e, stackTrace) {
      logger.error(
        '$label failed',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      return const [];
    }
  }

  /// Finds the latest unsettled call item from [fromMe] direction, preferring
  /// exact callId match when [callId] is provided.
  Future<String?> _resolveCallChatItemId({
    required bool fromMe,
    required int attemptsRemaining,
    String? callId,
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
      final matchCallId = callId != null && callId.isNotEmpty;
      Message? directionMatch;
      Message? callIdMatch;
      for (final message in items.whereType<Message>()) {
        if (message.isFromMe != fromMe) continue;
        final attachment = message.attachments.firstWhereOrNull(
          CallMetadata.isCall,
        );
        if (attachment == null) continue;
        final call = CallMetadata.maybeOf(attachment);
        if (call == null ||
            call.status == CallStatus.ended ||
            call.status == CallStatus.missed ||
            call.status == CallStatus.declined) {
          continue;
        }
        directionMatch = message;
        if (matchCallId && call.callId == callId) {
          callIdMatch = message;
        }
      }
      final match = callIdMatch ?? directionMatch;
      if (match == null) {
        if (attemptsRemaining <= 0) return null;
        await Future<void>.delayed(_resolveCallChatItemRetryDelay);
        return _resolveCallChatItemId(
          fromMe: fromMe,
          attemptsRemaining: attemptsRemaining - 1,
          callId: callId,
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
  Future<bool> markCallAsMissed({String? callId}) async {
    final messageId = await resolveIncomingCallChatItemId(callId: callId);
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

  /// Updates the call item with [messageId] to the specified [status] and
  /// optional [duration]. Persists the change to the SDK and returns the
  /// updated [Message] so callers can refresh the UI immediately instead of
  /// waiting for the SDK stream echo. Returns `null` if the message is not
  /// found or does not contain a call attachment.
  Future<Message?> updateCallChatItem(
    String messageId, {
    required CallStatus status,
    Duration? duration,
    CallParticipation? participation,
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
        participation: participation ?? existing.participation,
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

  /// Resolves this device's own call item for [callId] for outcome
  /// reconciliation. Matches the exact [callId] across every direction and
  /// status, including already-settled items, so a device that already ended
  /// its own item can still converge on the full duration. Prefers the
  /// device's own outgoing item, then an incoming item. Returns `null` when no
  /// item carries [callId]; never falls back to a non-matching item.
  Future<String?> resolveCallItemIdForOutcome(String callId) async {
    const label = 'resolveCallItemIdForOutcome';
    await ensureInitialized();
    final chatSdk = getChatSdk();
    if (chatSdk is! MeetingPlaceMatrixChatSDK) {
      logger.warning('$label: chat SDK unavailable', name: _logKey);
      return null;
    }
    if (callId.isEmpty) return null;
    try {
      final match = await chatSdk.getCallChatItemByCallId(callId);
      if (match == null) {
        logger.info('$label: no call item for callId $callId', name: _logKey);
        return null;
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

  /// Reconciles the call item [messageId] to `ended` with the authoritative
  /// [duration] from a transport-delivered outcome. Clears
  /// `selfLeftBeforeEnd` on any group participation so a participant who left
  /// early converges on the full call duration and the "You left" label is
  /// replaced by the standard duration label. Returns the updated [Message] for
  /// an immediate UI refresh, or `null` when the item is missing or not a call.
  Future<Message?> reconcileCallOutcome(
    String messageId, {
    Duration? duration,
  }) async {
    await ensureInitialized();
    final chatSdk = getChatSdk();
    if (chatSdk == null) {
      logger.warning(
        'reconcileCallOutcome: Chat SDK unavailable',
        name: _logKey,
      );
      return null;
    }
    try {
      final item = await chatSdk.getMessageById(messageId);
      if (item is! Message) {
        logger.warning(
          'reconcileCallOutcome: message $messageId not found',
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
          'reconcileCallOutcome: $messageId is not a call item',
          name: _logKey,
        );
        return null;
      }
      // The transport outcome converges a call this device took part in (in
      // progress, or already ended locally) onto the authoritative duration.
      // It must never overwrite an unanswered terminal: a missed/declined item
      // means this device did not join, and a ringing/calling item never
      // connected here, so forcing it to ended would fabricate a completed
      // call.
      if (existing.status != CallStatus.inProgress &&
          existing.status != CallStatus.ended) {
        logger.info(
          'reconcileCallOutcome: $messageId is ${existing.status}, not a '
          'participated call; preserving status',
          name: _logKey,
        );
        return item;
      }
      final convergedParticipation = existing.participation?.copyWith(
        selfLeftBeforeEnd: false,
      );
      final updated = CallMetadata.buildAttachment(
        mediaType: existing.mediaType,
        status: CallStatus.ended,
        callId: existing.callId,
        durationMs: duration?.inMilliseconds ?? existing.durationMs,
        participation: convergedParticipation,
        id: callAttachment!.id,
      );
      item.attachments = [
        for (final a in item.attachments)
          if (CallMetadata.isCall(a)) updated else a,
      ];
      await chatSdk.updateMessage(item);
      logger.info('reconcileCallOutcome: $messageId -> ended', name: _logKey);
      return item;
    } catch (e, stackTrace) {
      logger.error(
        'reconcileCallOutcome failed',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      return null;
    }
  }
}
