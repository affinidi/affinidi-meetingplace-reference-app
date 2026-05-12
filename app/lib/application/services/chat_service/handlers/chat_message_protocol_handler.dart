import 'dart:async';

import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../../infrastructure/plugins/vrc_attachments_plugin/vrc_attachment.dart';
import '../../../../infrastructure/plugins/vrc_attachments_plugin/vrc_request_attachment.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.chatMessage` — triggers a contact sequence number
/// update so the app stays in sync with the channel's message sequence.
/// When the incoming chat item contains a VRC attachment,
/// `onVrcReceived` is called so the credential can be persisted.
/// When a VRC request attachment is detected, `onVrcRequestReceived` is called
/// so the responder's concierge prompt can be injected.
class ChatMessageProtocolHandler implements ChatProtocolHandler {
  ChatMessageProtocolHandler({
    required Future<void> Function(String channelDid) onUpdateSequenceNumber,
    required Future<void> Function(String vcBlob, String channelDid)
    onVrcReceived,
    required Future<void> Function(
      String channelDid,
      String? identityDid,
      String? identityName,
    )
    onVrcRequestReceived,
    required AppLogger logger,
  }) : _onUpdateSequenceNumber = onUpdateSequenceNumber,
       _onVrcReceived = onVrcReceived,
       _onVrcRequestReceived = onVrcRequestReceived,
       _logger = logger;

  static const _logKey = 'CHATMESSAGEPROTOCOLHANDLER';
  static const _vrcPluginFormat = VrcAttachment.pluginFormat;
  static const _vrcRequestPluginFormat = VrcRequestAttachment.pluginFormat;

  final Future<void> Function(String channelDid) _onUpdateSequenceNumber;
  final Future<void> Function(String vcBlob, String channelDid) _onVrcReceived;
  final Future<void> Function(
    String channelDid,
    String? identityDid,
    String? identityName,
  )
  _onVrcRequestReceived;
  final AppLogger _logger;

  @override
  bool canHandle(String protocolType) =>
      protocolType == ChatProtocol.chatMessage.value;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    _logger.info(
      'Received chat message, updating sequence number',
      name: _logKey,
    );
    unawaited(_onUpdateSequenceNumber(channelDid));

    final chatItem = data.chatItem;
    if (chatItem is! Message) return;

    // Only process incoming messages; echoes of own sends are ignored here.
    if (chatItem.isFromMe) return;

    final vrcRequestAttachment = chatItem.attachments
        .where((Attachment a) => a.format == _vrcRequestPluginFormat)
        .firstOrNull;

    if (vrcRequestAttachment != null) {
      _logger.info('Received VRC request from peer', name: _logKey);
      unawaited(
        _onVrcRequestReceived(
          channelDid,
          vrcRequestAttachment.vrcRequestIdentityDid,
          vrcRequestAttachment.vrcRequestIdentityName,
        ),
      );
      return;
    }

    final vrcAttachment = chatItem.attachments
        .where((Attachment a) => a.format == _vrcPluginFormat)
        .firstOrNull;

    if (vrcAttachment == null) return;

    final vcBlob = vrcAttachment.vrcVcBlob;
    if (vcBlob == null || vcBlob.isEmpty) return;

    unawaited(_onVrcReceived(vcBlob, channelDid));
  }
}
