import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../delegates/call_chat_item_manager.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles [CallOutcomeChatEvent] — a canonical call outcome delivered over the
/// chat transport. Reconciles the local call chat item by callId and converges
/// on the full call duration ([CallOutcomeChatEvent.endedAt] minus
/// [CallOutcomeChatEvent.startedAt]).
class CallOutcomeProtocolHandler implements ChatProtocolHandler {
  CallOutcomeProtocolHandler({
    required this._callChatItemManager,
    required this._logger,
  });

  static const _logKey = 'CALLOUTCOMEPROTOCOLHANDLER';

  final CallChatItemManager _callChatItemManager;
  final AppLogger _logger;

  @override
  bool canHandle(ChatEvent event) => event is CallOutcomeChatEvent;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    if (data.event is! CallOutcomeChatEvent) {
      throw AppException(
        'Unexpected event type: ${data.event.runtimeType}',
        code: AppExceptionType.unexpectedChatEventType.name,
      );
    }
    final event = data.event as CallOutcomeChatEvent;

    if (event.callId.isEmpty) {
      _logger.warning('Skipping outcome with empty callId', name: _logKey);
      return;
    }

    final messageId = await _callChatItemManager.resolveCallItemIdForOutcome(
      event.callId,
    );
    if (messageId == null) {
      _logger.info('No call item for callId ${event.callId}', name: _logKey);
      return;
    }

    final startedAt = event.startedAt;
    final duration = startedAt == null
        ? null
        : event.endedAt.difference(startedAt);

    await _callChatItemManager.reconcileCallOutcome(
      messageId,
      duration: duration,
    );
  }
}
