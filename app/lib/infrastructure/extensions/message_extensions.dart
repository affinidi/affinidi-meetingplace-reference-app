import 'package:meeting_place_chat/meeting_place_chat.dart';

extension MessageActions on Message {
  bool get canDelete => isFromMe && !isDeleted && !isDeletedLocally;

  bool get canEdit =>
      isFromMe && !isDeleted && !isDeletedLocally && value.isNotEmpty;
}
