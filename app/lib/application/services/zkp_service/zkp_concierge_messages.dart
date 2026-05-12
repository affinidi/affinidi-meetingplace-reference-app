import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:uuid/uuid.dart';

import 'zkp_constants.dart';

/// //TODO: move this to sdk SDK [chat.ConciergeMessage] rows for the ZKP
abstract final class ZkpConciergeMessages {
  static chat.ConciergeMessage humanZkpRequest({
    required String chatId,
    required String messageId,
    required DateTime dateCreated,
    required String contactName,
  }) {
    return chat.ConciergeMessage(
      chatId: chatId,
      messageId: messageId,
      senderDid: '',
      isFromMe: false,
      dateCreated: dateCreated,
      status: chat.ChatItemStatus.confirmed,
      data: {'contactName': contactName},
      conciergeType: chat.ConciergeMessageType.fromJson(
        ZkpConstants.conciergeHumanZkpRequest,
      ),
    );
  }

  static chat.ConciergeMessage humanZkpPaused({
    required String chatId,
    required DateTime dateCreated,
    String? pausedForRequestMessageId,
  }) {
    final messageId = pausedForRequestMessageId == null
        ? 'zkp-paused-${const Uuid().v4()}'
        : 'zkp-paused-$pausedForRequestMessageId';

    return chat.ConciergeMessage(
      chatId: chatId,
      messageId: messageId,
      senderDid: '',
      isFromMe: true,
      dateCreated: dateCreated,
      status: chat.ChatItemStatus.confirmed,
      data: const {},
      conciergeType: chat.ConciergeMessageType.fromJson(
        ZkpConstants.conciergeHumanZkpPaused,
      ),
    );
  }

  static chat.ConciergeMessage humanZkpProofShared({
    required String chatId,
    required String messageId,
    required DateTime dateCreated,
  }) {
    return chat.ConciergeMessage(
      chatId: chatId,
      messageId: messageId,
      senderDid: '',
      isFromMe: true,
      dateCreated: dateCreated,
      status: chat.ChatItemStatus.confirmed,
      data: const {},
      conciergeType: chat.ConciergeMessageType.fromJson(
        ZkpConstants.conciergeHumanZkpProofShared,
      ),
    );
  }

  static chat.ConciergeMessage humanZkpProofReceived({
    required String chatId,
    required String messageId,
    required DateTime dateCreated,
    required String contactName,
  }) {
    return chat.ConciergeMessage(
      chatId: chatId,
      messageId: messageId,
      senderDid: '',
      isFromMe: false,
      dateCreated: dateCreated,
      status: chat.ChatItemStatus.confirmed,
      data: {'contactName': contactName},
      conciergeType: chat.ConciergeMessageType.fromJson(
        ZkpConstants.conciergeHumanZkpProofReceived,
      ),
    );
  }
}
