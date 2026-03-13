import 'package:meeting_place_chat/meeting_place_chat.dart';

import 'handlers/interfaces/chat_protocol_handler.dart';

/// Routes an incoming `StreamData` message to all registered
/// `ChatProtocolHandler`s whose `canHandle` returns `true`.
///
/// Handlers are evaluated in registration order. Multiple handlers may match
/// a single message (e.g. chatActivity triggers both `TypingProtocolHandler`
/// and `PresenceProtocolHandler`). To add support for a new protocol type,
/// create a `ChatProtocolHandler` and register it here.
class ChatProtocolRouter {
  ChatProtocolRouter({required List<ChatProtocolHandler> handlers})
    : _handlers = handlers;

  final List<ChatProtocolHandler> _handlers;

  /// Dispatches `data` to every handler that can process its protocol type.
  Future<void> route(StreamData data, String channelDid) async {
    final protocolType = data.plainTextMessage?.type.toString();
    if (protocolType == null) return;

    for (final handler in _handlers) {
      if (handler.canHandle(protocolType)) {
        await handler.handle(data, channelDid);
      }
    }
  }
}
