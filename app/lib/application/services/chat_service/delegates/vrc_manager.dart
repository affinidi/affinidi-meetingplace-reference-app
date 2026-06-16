import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:uuid/uuid.dart';

import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../../infrastructure/plugins/vrc_attachments_plugin/vrc_attachment.dart';
import '../../../../infrastructure/providers/chat_repository_provider.dart';
import '../../vrc_service/vrc_service.dart';

/// Handles VRC-related chat message persistence: request notifications,
/// local event messages, concierge prompt lifecycle, and VRC card display.
class VrcManager {
  VrcManager({
    required this._ref,
    required this._getChatId,
    required this._logger,
    required this._getChatSdk,
    required this._getMessages,
    required this._upsertChatItem,
    required this._removeChatItem,
  });

  static const _logKey = 'VRCMSG';

  final Ref _ref;
  final String? Function() _getChatId;
  final AppLogger _logger;
  final MeetingPlaceChatSDK? Function() _getChatSdk;
  final List<ChatItem> Function() _getMessages;
  final void Function(ChatItem) _upsertChatItem;
  final void Function(ChatItem) _removeChatItem;

  /// Triggered when a peer sends a VRC exchange request.
  ///
  /// Injects an [EventMessage] (vrcRequestReceived) and, when
  /// [shouldPromptForAction] is true, a [ConciergeMessage]
  /// (permissionToVerifyRelationship) into the local message list.
  Future<void> onVrcRequestReceived(
    String channelDid,
    String? identityDid,
    String? identityName, {
    bool shouldPromptForAction = true,
  }) async {
    final chatId = _getChatId();
    if (chatId == null) {
      _logger.warning(
        'Cannot persist VRC request: chatId not yet known',
        name: _logKey,
      );
      return;
    }

    final alreadyReceived = _getMessages().any(
      (message) =>
          message is EventMessage &&
          message.eventType == EventMessageType.fromJson('vrcRequestReceived'),
    );
    if (alreadyReceived) {
      _logger.warning(
        'VRC request already received, skipping duplicate',
        name: _logKey,
      );
      return;
    }

    final hasVrc = await _ref
        .read(vrcServiceProvider.notifier)
        .hasVrcInChannel(channelDid);
    if (hasVrc) {
      _logger.warning(
        'VRC already exists, skipping concierge UI',
        name: _logKey,
      );
      return;
    }

    final now = DateTime.now();
    final data = <String, dynamic>{};
    if (identityDid != null) data['identityDid'] = identityDid;
    if (identityName != null) data['identityName'] = identityName;

    final eventMessage = EventMessage(
      chatId: chatId,
      messageId: const Uuid().v4(),
      senderDid: channelDid,
      isFromMe: false,
      dateCreated: now,
      status: ChatItemStatus.received,
      eventType: EventMessageType.fromJson('vrcRequestReceived'),
      data: data,
    );
    final repository = await _ref.read(chatRepositoryProvider.future);
    await repository.createMessage(eventMessage);
    _upsertChatItem(eventMessage);

    if (!shouldPromptForAction) {
      _logger.info(
        'Persisted VRC request event without concierge for channel $channelDid',
        name: _logKey,
      );
      return;
    }

    final conciergeMessage = ConciergeMessage(
      chatId: chatId,
      messageId: const Uuid().v4(),
      senderDid: channelDid,
      isFromMe: false,
      // Place the concierge prompt after the event notice
      dateCreated: now.add(const Duration(milliseconds: 1)),
      status: ChatItemStatus.userInput,
      conciergeType: ConciergeMessageType.fromJson(
        'permissionToVerifyRelationship',
      ),
      data: const {},
    );
    await repository.createMessage(conciergeMessage);
    _upsertChatItem(conciergeMessage);
    _logger.info(
      'Persisted and injected VRC request concierge for channel $channelDid',
      name: _logKey,
    );
  }

  /// Persists a local [EventMessage] of the given [eventType] into the chat.
  Future<void> persistLocalEventMessage(
    EventMessageType eventType, {
    Map<String, dynamic> data = const {},
  }) async {
    final chatId = _getChatId();
    if (chatId == null) {
      _logger.warning(
        'Cannot persist local event: chatId not yet known',
        name: _logKey,
      );
      return;
    }
    final eventMessage = EventMessage(
      chatId: chatId,
      messageId:
          'local_${eventType.value}_${DateTime.now().millisecondsSinceEpoch}',
      senderDid: '',
      isFromMe: false,
      dateCreated: DateTime.now(),
      status: ChatItemStatus.sent,
      eventType: eventType,
      data: data,
    );
    final repository = await _ref.read(chatRepositoryProvider.future);
    await repository.createMessage(eventMessage);
    _upsertChatItem(eventMessage);
  }

  /// Marks all pending VRC concierge prompts as confirmed and removes them
  /// from the visible message list.
  Future<void> dismissVrcConciergeMessages() async {
    final repository = await _ref.read(chatRepositoryProvider.future);
    final toRemove = _getMessages()
        .whereType<ConciergeMessage>()
        .where(
          (m) =>
              m.conciergeType ==
              ConciergeMessageType.fromJson('permissionToVerifyRelationship'),
        )
        .toList();

    for (final msg in toRemove) {
      msg.status = ChatItemStatus.confirmed;
      await repository.updateMesssage(msg);
      _removeChatItem(msg);
    }
  }

  /// Shows a sent VRC as an outgoing attachment in the chat.
  Future<void> showSentVrcAttachment({
    required String vcBlob,
    required String senderDid,
  }) async {
    final chatSdk = _getChatSdk();
    if (chatSdk == null) return;
    await chatSdk.createAttachmentMessage(
      attachments: [VrcAttachment(vcBlob: vcBlob).toAttachment()],
      senderDid: senderDid,
    );
  }
}
