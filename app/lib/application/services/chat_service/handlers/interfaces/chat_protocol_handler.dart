import 'package:meeting_place_chat/meeting_place_chat.dart';

/// Strategy interface for handling a single incoming chat protocol message.
///
/// Each handler is responsible for one protocol type (e.g. presence, typing,
/// effects). Register handlers in `ChatProtocolRouter`; the router will call
/// every handler whose `canHandle` returns `true`.
abstract class ChatProtocolHandler {
  /// Returns `true` if this handler should process the given `protocolType`.
  bool canHandle(String protocolType);

  /// Processes the incoming `data` for the channel identified by `channelDid`.
  Future<void> handle(StreamData data, String channelDid);
}
