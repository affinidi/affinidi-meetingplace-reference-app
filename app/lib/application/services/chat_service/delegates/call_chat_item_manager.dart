import 'package:collection/collection.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/loggers/app_logger/app_logger.dart';

class CallChatItemManager {
  CallChatItemManager({
    required this.ensureInitialized,
    required this.getChatSdk,
    required this.logger,
  });

  static const _logKey = 'CallChatItemManager';

  final Future<void> Function() ensureInitialized;
  final MeetingPlaceChatSDK? Function() getChatSdk;
  final AppLogger logger;

  Future<String?> sendOutgoingCallMessage({
    required CallMediaType mediaType,
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

  Future<String?> resolveIncomingCallChatItemId() =>
      _resolveCallChatItemId(fromMe: false);

  Future<String?> resolveOutgoingCallChatItemId() =>
      _resolveCallChatItemId(fromMe: true);

  Future<String?> _resolveCallChatItemId({required bool fromMe}) async {
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
      if (match == null) return null;
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
