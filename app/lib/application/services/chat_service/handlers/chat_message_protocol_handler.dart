import 'dart:async';

import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.chatMessage` — triggers a contact sequence number
/// update so the app stays in sync with the channel's message sequence.
class ChatMessageProtocolHandler implements ChatProtocolHandler {
  ChatMessageProtocolHandler({
    required this._onUpdateSequenceNumber,
    required this._logger,
  });

  static const _logKey = 'CHATMESSAGEPROTOCOLHANDLER';

  final Future<void> Function(String channelDid) _onUpdateSequenceNumber;
  final AppLogger _logger;

  @override
  bool canHandle(ChatEvent event) => event is ChatMessageEvent;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    if (data.event is! ChatMessageEvent) {
      throw AppException(
        'Unexpected event type: ${data.event.runtimeType}',
        code: AppExceptionType.unexpectedChatEventType.name,
      );
    }

    _logger.info(
      'Received chat message, updating sequence number',
      name: _logKey,
    );
    unawaited(_onUpdateSequenceNumber(channelDid));
  }
}
