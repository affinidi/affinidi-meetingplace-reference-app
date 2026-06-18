import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../services/contacts_service/contacts_service.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.chatPresence` and the presence side-effect of
/// `ChatProtocol.chatActivity` — extracts the sender timestamp, persists it
/// to the contacts service, and notifies the caller.
///
/// Both protocols are handled because an actively typing user must remain
/// online; before the handler split, `chatActivity` also refreshed presence.
class PresenceProtocolHandler implements ChatProtocolHandler {
  PresenceProtocolHandler({
    required this._ref,
    required this._onPresenceUpdated,
    required this._logger,
  });

  static const _logKey = 'PRESENCEPROTOCOLHANDLER';

  final Ref _ref;
  final void Function(DateTime timestamp) _onPresenceUpdated;
  final AppLogger _logger;

  @override
  bool canHandle(ChatEvent event) =>
      event is ChatPresenceEvent || event is ChatActivityEvent;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    final event = data.event;
    final timestamp = switch (event) {
      ChatPresenceEvent(:final timestamp) => timestamp,
      ChatActivityEvent(:final timestamp) => timestamp,
      _ => throw AppException(
        'Unexpected event type: ${event.runtimeType}',
        code: AppExceptionType.unexpectedChatEventType.name,
      ),
    };

    if (channelDid.isEmpty) {
      _logger.warning(
        'Invalid presence data: timestamp=$timestamp, channelDid=$channelDid',
        name: _logKey,
      );
      return;
    }

    _logger.info('Received chat presence update', name: _logKey);
    unawaited(
      _ref
          .read(contactsServiceProvider.notifier)
          .updateContactLastKeepAliveMessage(channelDid, timestamp),
    );

    _onPresenceUpdated(timestamp);
  }
}
