import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import 'interfaces/chat_protocol_handler.dart';

/// Handles `ChatProtocol.chatGroupDetailsUpdate` — notifies the caller to
/// trigger a group refresh. Add new group-details-update logic here.
class GroupDetailsProtocolHandler implements ChatProtocolHandler {
  GroupDetailsProtocolHandler({
    required void Function(StreamData data, String channelDid)
    onGroupDetailsUpdated,
    required AppLogger logger,
  }) : _onGroupDetailsUpdated = onGroupDetailsUpdated,
       _logger = logger;

  static const _logKey = 'GROUPDETAILSHANDLER';

  final void Function(StreamData data, String channelDid)
  _onGroupDetailsUpdated;
  final AppLogger _logger;

  @override
  bool canHandle(String protocolType) =>
      protocolType == ChatProtocol.chatGroupDetailsUpdate.value;

  @override
  Future<void> handle(StreamData data, String channelDid) async {
    _logger.info('Received group details update', name: _logKey);
    _onGroupDetailsUpdated(data, channelDid);
  }
}
