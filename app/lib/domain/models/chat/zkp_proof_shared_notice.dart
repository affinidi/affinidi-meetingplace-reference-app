import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:uuid/uuid.dart';

/// Represents a chat item that displays when user shares a ZKP proof.
///
/// This class extends [chat.ChatItem] and shows the user that they shared a proof.
class ZkpProofSharedNotice extends chat.ChatItem {
  ZkpProofSharedNotice({
    required String chatId,
    required DateTime dateCreated,
  }) : super(
        messageId: 'zkp-proof-shared-${const Uuid().v4()}',
        chatId: chatId,
        dateCreated: dateCreated,
        senderDid: '',
        isFromMe: true,
        status: chat.ChatItemStatus.confirmed,
        type: chat.ChatItemType.eventMessage,
      );
}
