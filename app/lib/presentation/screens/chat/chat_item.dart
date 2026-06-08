part of 'chat_screen.dart';

class ChatItem extends StatelessWidget {
  const ChatItem({
    super.key,
    required this._chatItem,
    required this._index,
    required this._contactId,
    required this._chatItemColor,
  });

  final chat.ChatItem _chatItem;
  final int _index;
  final String _contactId;
  final Color _chatItemColor;

  @override
  Widget build(BuildContext context) {
    if (_chatItem is EncryptionNotice) {
      return const ChatEncryptionNotice();
    }

    if (ChatZkpConciergeItem.matches(_chatItem)) {
      return ChatZkpConciergeItem(
        chatItem: _chatItem as chat.ConciergeMessage,
        contactId: _contactId,
      );
    }

    if (_chatItem is chat.Message) {
      return _PlainTextChatItem(
        chatItem: _chatItem,
        contactId: _contactId,
        index: _index,
        chatItemColor: _chatItemColor,
      );
    }

    if (_chatItem is chat.ConciergeMessage &&
        _chatItem.conciergeType ==
            chat.ConciergeMessageType.permissionToUpdateProfile) {
      return _ConciergeUpdateProfileRequestChatItem(
        chatItem: _chatItem,
        contactId: _contactId,
      );
    }

    if (_chatItem is chat.ConciergeMessage &&
        _chatItem.conciergeType ==
            chat.ConciergeMessageType.permissionToJoinGroup) {
      return ConciergeJoinGroupRequestChatItem(
        chatItem: _chatItem,
        contactId: _contactId,
      );
    }

    if (_chatItem is chat.ConciergeMessage &&
        _chatItem.conciergeType ==
            chat.ConciergeMessageType.fromJson(
              'permissionToVerifyRelationship',
            )) {
      return _ConciergeVrcChatItem(chatItem: _chatItem, contactId: _contactId);
    }

    if (_chatItem is chat.EventMessage &&
        _chatItem.eventType == chat.EventMessageType.groupMemberJoinedGroup) {
      return JoiningGroupChatItem(chatItem: _chatItem);
    }

    if (_chatItem is chat.EventMessage &&
        _chatItem.eventType == chat.EventMessageType.groupMemberLeftGroup) {
      return LeavingGroupChatItem(chatItem: _chatItem);
    }

    if (_chatItem is chat.EventMessage &&
        _chatItem.eventType == chat.EventMessageType.groupDeleted) {
      return GroupDeletedChatItem(chatItem: _chatItem);
    }

    if (_chatItem is chat.EventMessage &&
        _chatItem.eventType ==
            chat.EventMessageType.awaitingGroupMemberToJoin) {
      return const SizedBox.shrink();
    }

    if (_chatItem is chat.EventMessage &&
        _chatItem.eventType ==
            chat.EventMessageType.fromJson('vrcExchangeInitiated')) {
      return ChatVrcExchangeInitiatedNotice(
        chatItem: _chatItem,
        contactId: _contactId,
      );
    }

    if (_chatItem is chat.EventMessage &&
        _chatItem.eventType ==
            chat.EventMessageType.fromJson('vrcRequestReceived')) {
      return ChatVrcRequestReceivedNotice(
        chatItem: _chatItem,
        contactId: _contactId,
      );
    }

    if (_chatItem is chat.EventMessage &&
        _chatItem.eventType ==
            chat.EventMessageType.fromJson('vrcExchangeDoLater')) {
      return ChatVrcExchangeDoLaterNotice(
        chatItem: _chatItem,
        contactId: _contactId,
      );
    }

    if (_chatItem is chat.EventMessage &&
        _chatItem.eventType ==
            chat.EventMessageType.fromJson('vrcExchangeCompleted')) {
      return ChatVrcExchangeCompleteNotice(
        chatItem: _chatItem,
        contactId: _contactId,
      );
    }

    return UnknownChatItem();
  }
}
