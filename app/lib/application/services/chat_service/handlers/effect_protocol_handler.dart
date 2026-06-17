import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.chatEffect` — extracts the effect name from the
/// incoming message and notifies the caller.
class EffectProtocolHandler implements ChatProtocolHandler {
  EffectProtocolHandler({required this._onEffect, required this._logger});

  static const _logKey = 'EFFECTPROTOCOLHANDLER';

  final void Function(String? effectName) _onEffect;
  final AppLogger _logger;

  @override
  bool canHandle(ChatEvent event) => event is ChatEffectEvent;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    if (data.event is! ChatEffectEvent) {
      throw AppException(
        'Unexpected event type: ${data.event.runtimeType}',
        code: AppExceptionType.unexpectedChatEventType.name,
      );
    }
    final event = data.event as ChatEffectEvent;

    _logger.info('Received chat effect update', name: _logKey);
    _onEffect(event.effectName);
  }
}
