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
    required void Function(String? senderDid) onTypingMember,
    required AppLogger logger,
  }) : _secondsToShow = secondsToShowChatActivityIndicator,
       _onTypingMember = onTypingMember,
       _logger = logger;

  static const _logKey = 'TYPINGPROTOCOLHANDLER';

  final int _secondsToShow;
  final void Function(String? senderDid) _onTypingMember;
  final AppLogger _logger;

  @override
  bool canHandle(ChatEvent event) => event is ChatActivityEvent;

  @override
  Future<void> handle(ChatEvent event, String channelDid) async {
    if (event is! ChatActivityEvent) {
      throw StateError('Unexpected event type: ${event.runtimeType}');
    }

    final createdTime = event.createdTime;
    if (createdTime == null) return;

    final differenceInSeconds = clock.now().difference(createdTime).inSeconds;
    final isExpired = (_secondsToShow - differenceInSeconds) < 0;
    if (isExpired) return;

    _logger.info('Received chat activity update', name: _logKey);
    _onTypingMember(event.senderDid);
  }
}
