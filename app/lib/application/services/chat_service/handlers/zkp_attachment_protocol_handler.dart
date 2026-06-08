import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart'
    show LivenessZkpAttachmentParser;

import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.chatMessage` events that contain liveness ZKP
/// attachments and delegates them to the configured callback.
class ZkpAttachmentProtocolHandler implements ChatProtocolHandler {
  ZkpAttachmentProtocolHandler({
    required void Function(StreamData data, String channelDid)? Function()
    getOnZkpAttachment,
    required AppLogger logger,
  }) : _getOnZkpAttachment = getOnZkpAttachment,
       _logger = logger;

  static const _logKey = 'ZKPATTCHDLR';

  final void Function(StreamData data, String channelDid)? Function()
  _getOnZkpAttachment;
  final AppLogger _logger;

  @override
  bool canHandle(String protocolType) =>
      protocolType == ChatProtocol.chatMessage.value;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    final onZkpAttachment = _getOnZkpAttachment();
    if (onZkpAttachment == null) return;

    final attachments = data.plainTextMessage?.attachments;
    if (attachments == null || attachments.isEmpty) return;

    final hasRequest =
        LivenessZkpAttachmentParser.tryParseRequestIn(attachments) != null;
    final hasProof =
        LivenessZkpAttachmentParser.tryParseProofIn(attachments) != null;
    if (!hasRequest && !hasProof) return;

    _logger.info(
      'Received chat message with liveness ZKP attachment',
      name: _logKey,
    );
    onZkpAttachment(data, channelDid);
  }
}
