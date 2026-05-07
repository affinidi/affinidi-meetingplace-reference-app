import 'package:meeting_place_chat/meeting_place_chat.dart';

/// Strategy interface for handling a single incoming chat protocol message.
///
/// Each handler is responsible for one protocol type (e.g. presence, typing,
/// effects). Register handlers in `ChatProtocolRouter`; the router will call
/// the first handler whose `canHandle` returns `true`.
abstract class ChatProtocolHandler {
  /// Returns `true` if this handler should process the given [ChatEvent].
  bool canHandle(ChatEvent event);

  /// Processes the incoming [ChatEvent] for the channel identified by
  /// [channelDid].
  Future<void> handle(ChatEvent event, String channelDid);
}
