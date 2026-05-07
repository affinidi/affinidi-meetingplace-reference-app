import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.chatEffect` — extracts the effect name from the
/// incoming message and notifies the caller.
class EffectProtocolHandler implements ChatProtocolHandler {
  EffectProtocolHandler({
    required void Function(String? effectName) onEffect,
    required AppLogger logger,
  }) : _onEffect = onEffect,
       _logger = logger;

  static const _logKey = 'EFFECTPROTOCOLHANDLER';

  final void Function(String? effectName) _onEffect;
  final AppLogger _logger;

  @override
  bool canHandle(ChatEvent event) => event is ChatEffectEvent;

  @override
  Future<void> handle(ChatEvent event, String channelDid) async {
    if (event is! ChatEffectEvent) return;

    _logger.info('Received chat effect update', name: _logKey);
    _onEffect(event.effectName);
  }
}
