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

  final void Function(ChatItem chatItem, String channelDid) _onZkpAttachment;
  final AppLogger _logger;

  @override
  bool canHandle(ChatEvent event) => event is ChatMessageEvent;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    if (data.event is! ChatMessageEvent) return;
    if (data.chatItem is! Message) return;
    final chatItem = data.chatItem as Message;

    final attachments = chatItem.attachments.map((a) => a.toCoreAttachment());
    if (attachments.isEmpty) return;

    final hasRequest =
        LivenessZkpAttachmentParser.tryParseRequestIn(attachments) != null;
    final hasProof =
        LivenessZkpAttachmentParser.tryParseProofIn(attachments) != null;
    final hasDeclined =
        LivenessZkpAttachmentParser.tryParseDeclinedIn(attachments) != null;
    if (!hasRequest && !hasProof && !hasDeclined) return;

    _logger.info(
      'Received chat message with liveness ZKP attachment',
      name: _logKey,
    );
    _onZkpAttachment(chatItem, channelDid);
  }
}
