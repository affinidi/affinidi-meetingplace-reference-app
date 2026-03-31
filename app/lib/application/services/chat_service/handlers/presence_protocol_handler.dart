import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../services/contacts_service/contacts_service.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.chatPresence` and the presence side-effect of
/// `ChatProtocol.chatActivity` — extracts the sender timestamp, persists it
/// to the contacts service, and notifies the caller.
class PresenceProtocolHandler implements ChatProtocolHandler {
  PresenceProtocolHandler({
    required Ref ref,
    required void Function(DateTime timestamp) onPresenceUpdated,
    required AppLogger logger,
  }) : _ref = ref,
       _onPresenceUpdated = onPresenceUpdated,
       _logger = logger;

  static const _logKey = 'PRESENCEHANDLER';

  final Ref _ref;
  final void Function(DateTime timestamp) _onPresenceUpdated;
  final AppLogger _logger;

  @override
  bool canHandle(String protocolType) =>
      protocolType == ChatProtocol.chatPresence.value;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    final plainTextMessage = data.plainTextMessage;
    if (plainTextMessage == null) {
      _logger.warning('Presence message is null', name: _logKey);
      return;
    }

    final timestamp = DateTime.tryParse(
      plainTextMessage.body?['timestamp'] as String? ?? '',
    );
    if (timestamp == null || channelDid.isEmpty) {
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
