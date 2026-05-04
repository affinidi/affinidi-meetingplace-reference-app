import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:uuid/uuid.dart';

/// Represents a chat item that displays a notice when user pauses ZKP request.
///
/// This class extends [chat.ChatItem] and is used to inform the user that
/// they paused the Human ZKP request.
class ZkpPausedNotice extends chat.ChatItem {
  ZkpPausedNotice({required super.chatId, required super.dateCreated})
    : super(
        messageId: 'zkp-paused-${const Uuid().v4()}',
        senderDid: '',
        isFromMe: true,
        status: chat.ChatItemStatus.confirmed,
        type: chat.ChatItemType.eventMessage,
      );
}
