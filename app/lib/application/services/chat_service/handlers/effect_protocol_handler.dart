import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/extensions/plain_text_message_extensions.dart';
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
  bool canHandle(String protocolType) =>
      protocolType == ChatProtocol.chatEffect.value;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    _logger.info('Received chat effect update', name: _logKey);
    final effectName = data.plainTextMessage?.effectName;
    _onEffect(effectName);
  }
}
