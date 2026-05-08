import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:uuid/uuid.dart';

/// Represents a chat item that displays when user receives a liveness
/// check request.
///
/// This class extends [chat.ChatItem] and shows a concierge message
/// with action buttons.
class ZkpRequestReceivedNotice extends chat.ChatItem {
  ZkpRequestReceivedNotice({
    required super.chatId,
    required super.dateCreated,
    required String contactName,
    String? messageId,
  }) : _contactName = contactName,
       super(
         messageId: messageId ?? 'zkp-request-received-${const Uuid().v4()}',
         senderDid: '',
         isFromMe: false,
         status: chat.ChatItemStatus.confirmed,
         type: chat.ChatItemType.eventMessage,
       );

  final String _contactName;
  String get contactName => _contactName;
}
