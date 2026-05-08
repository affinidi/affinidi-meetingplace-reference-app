import 'dart:async';

import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.chatMessage` — triggers a contact sequence number
/// update so the app stays in sync with the channel's message sequence.
class ChatMessageProtocolHandler implements ChatProtocolHandler {
  ChatMessageProtocolHandler({
    required Future<void> Function(String channelDid) onUpdateSequenceNumber,
    required AppLogger logger,
  }) : _onUpdateSequenceNumber = onUpdateSequenceNumber,
       _logger = logger;

  static const _logKey = 'CHATMESSAGEPROTOCOLHANDLER';

  final Future<void> Function(String channelDid) _onUpdateSequenceNumber;
  final AppLogger _logger;

  @override
  bool canHandle(ChatEvent event) => event is ChatMessageEvent;

  @override
  Future<void> handle(ChatEvent event, String channelDid) async {
    if (event is! ChatMessageEvent) {
      throw StateError('Unexpected event type: ${event.runtimeType}');
    }

    _logger.info(
      'Received chat message, updating sequence number',
      name: _logKey,
    );
    unawaited(_onUpdateSequenceNumber(channelDid));
  }
}
