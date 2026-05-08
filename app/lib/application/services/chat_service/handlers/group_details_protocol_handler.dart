import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.chatGroupDetailsUpdate` — notifies the caller to
/// trigger a group refresh. Add new group-details-update logic here.
class GroupDetailsProtocolHandler implements ChatProtocolHandler {
  GroupDetailsProtocolHandler({
    required void Function(ChatEvent event, String channelDid)
    onGroupDetailsUpdated,
    required AppLogger logger,
  }) : _onGroupDetailsUpdated = onGroupDetailsUpdated,
       _logger = logger;

  static const _logKey = 'GROUPDETAILSPROTOCOLHANDLER';

  final void Function(ChatEvent event, String channelDid)
  _onGroupDetailsUpdated;
  final AppLogger _logger;

  @override
  bool canHandle(ChatEvent event) => event is ChatGroupDetailsUpdateEvent;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    if (data.event is! ChatGroupDetailsUpdateEvent) {
      throw AppException(
        'Unexpected event type: ${data.event.runtimeType}',
        code: AppExceptionType.unexpectedChatEventType.name,
      );
    }

    _logger.info('Received group details update', name: _logKey);
    _onGroupDetailsUpdated(
      data.event as ChatGroupDetailsUpdateEvent,
      channelDid,
    );
  }
}
