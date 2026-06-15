import 'package:clock/clock.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.chatActivity` — validates the activity has not
/// expired and notifies the caller with the sender DID so they can update
/// the typing indicator.
class TypingProtocolHandler implements ChatProtocolHandler {
  TypingProtocolHandler({
    required int secondsToShowChatActivityIndicator,
    required this._onTypingMember,
    required this._logger,
  }) : _secondsToShow = secondsToShowChatActivityIndicator;

  static const _logKey = 'TYPINGPROTOCOLHANDLER';

  final int _secondsToShow;
  final void Function(String? senderDid) _onTypingMember;
  final AppLogger _logger;

  @override
  bool canHandle(ChatEvent event) => event is ChatActivityEvent;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    if (data.event is! ChatActivityEvent) {
      throw StateError('Unexpected event type: ${data.event.runtimeType}');
    }
    final event = data.event as ChatActivityEvent;

    final createdTime = event.createdTime;
    if (createdTime == null) return;

    final differenceInSeconds = clock.now().difference(createdTime).inSeconds;
    final isExpired = (_secondsToShow - differenceInSeconds) < 0;
    if (isExpired) return;

    _logger.info('Received chat activity update', name: _logKey);
    _onTypingMember(event.senderDid);
  }
}
