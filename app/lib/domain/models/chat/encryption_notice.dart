import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

/// Represents a chat item that displays an encryption notice to the user.
///
/// This class extends [chat.ChatItem] and is used to inform users about
/// the encryption status of their chat messages.
class EncryptionNotice extends chat.ChatItem {
  EncryptionNotice()
      : super(
          messageId: 'encryption-notice',
          chatId: 'encryption-notice',
          dateCreated: DateTime(2000),
          senderDid: '',
          isFromMe: false,
          status: chat.ChatItemStatus.confirmed,
          type: chat.ChatItemType.eventMessage,
        );
}
