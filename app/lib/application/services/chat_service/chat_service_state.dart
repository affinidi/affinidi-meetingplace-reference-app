import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_core/meeting_place_core.dart' hide ContactCard;

import '../../../domain/models/contact_card/contact_card.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_presence_status.dart';

part 'chat_service_state.freezed.dart';

class ZkpAttachmentEvent {
  const ZkpAttachmentEvent({required this.chatItem, required this.channelDid});

  final chat.ChatItem chatItem;
  final String channelDid;
}

/// Contains all chat-session data that the controller observes. UI-only fields
/// (selectedReactionIndex, attachmentsDataCache) live in `ChatScreenState`.
@Freezed(fromJson: false, toJson: false)
abstract class ChatServiceState with _$ChatServiceState {
  ChatServiceState._();

  factory ChatServiceState({
    Contact? contact,
    Group? group,
    ContactCard? otherPartyCard,
    @Default([]) List<chat.ChatItem> messages,
    ZkpAttachmentEvent? zkpAttachmentEvent,
    @Default([]) List<String> membersTyping,
    @Default(false) bool isActive,
    @Default(false) bool isInitialized,
    @Default(ContactPresenceStatus.unknown)
    ContactPresenceStatus contactPresenceStatus,
    chat.Effect? effect,
  }) = _ChatServiceState;

  GroupMember? getGroupMemberByDid(String did) =>
      group?.members.firstWhereOrNull((gm) => gm.did == did);
}
