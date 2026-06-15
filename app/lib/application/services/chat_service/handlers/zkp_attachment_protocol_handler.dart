import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart'
    show LivenessZkpAttachmentParser;

import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.chatMessage` events that contain liveness ZKP
/// attachments and reports them via callback for state propagation.
class ZkpAttachmentProtocolHandler implements ChatProtocolHandler {
  ZkpAttachmentProtocolHandler({
    required this._onZkpAttachment,
    required this._logger,
  });

  static const _logKey = 'ZKPATTCHDLR';

  final void Function(StreamData data, String channelDid) _onZkpAttachment;
  final AppLogger _logger;

  @override
  bool canHandle(ChatEvent event) => event is ChatMessageEvent;

  @override
  Future<void> handle(ChatEvent event, String channelDid) async {
    if (event is! ChatMessageEvent) return;

    final attachments = event.data.plainTextMessage?.attachments;
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
    _onZkpAttachment(event.data, channelDid);
  }
}
