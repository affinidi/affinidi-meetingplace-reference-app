import 'package:meeting_place_chat/meeting_place_chat.dart';

import 'handlers/interfaces/chat_protocol_handler.dart';

/// Routes an incoming `StreamData` message to all registered
/// `ChatProtocolHandler`s whose `canHandle` returns `true`.
///
/// Handlers are evaluated in registration order. Multiple handlers may match
/// a single event (e.g. chatActivity triggers both `TypingProtocolHandler`
/// and `PresenceProtocolHandler`). To add support for a new event,
/// create a `ChatProtocolHandler` and register it here.
class ChatProtocolRouter {
  ChatProtocolRouter({required this._handlers});

  final List<ChatProtocolHandler> _handlers;

  /// Dispatches [ChatEvent] to every handler that can process the type of
  /// [ChatEvent].
  Future<void> route(StreamData data, String channelDid) async {
    if (data.event case final event?) {
      for (final handler in _handlers) {
        if (handler.canHandle(event)) {
          await handler.handle(data, channelDid);
        }
      }
    }
  }
}
