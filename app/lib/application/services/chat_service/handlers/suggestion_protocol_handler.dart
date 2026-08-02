import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.suggestion` events and forwards the latest incoming
/// suggestion to the chat session state.
class SuggestionProtocolHandler implements ChatProtocolHandler {
  SuggestionProtocolHandler({required this.onSuggestion, required this.logger});

  static const _logKey = 'SUGGESTIONPROTOCOLHANDLER';

  final void Function(ChatSuggestionEvent event, String channelDid)
  onSuggestion;
  final AppLogger logger;

  @override
  bool canHandle(ChatEvent event) => event is ChatSuggestionEvent;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    if (data.event is! ChatSuggestionEvent) {
      throw AppException(
        'Unexpected event type: ${data.event.runtimeType}',
        code: AppExceptionType.unexpectedChatEventType.name,
      );
    }

    if (channelDid.isEmpty) {
      logger.warning(
        'Invalid suggestion data: channelDid=$channelDid',
        name: _logKey,
      );
      return;
    }

    final event = data.event as ChatSuggestionEvent;
    logger.info('Received chat suggestion', name: _logKey);
    onSuggestion(event, channelDid);
  }
}
