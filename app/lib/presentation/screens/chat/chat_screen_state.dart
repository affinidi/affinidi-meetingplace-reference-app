import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_core/meeting_place_core.dart' hide ContactCard;

import '../../../domain/models/contact_card/contact_card.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_presence_status.dart';
import '../../effects/screen_effect.dart';

part 'chat_screen_state.freezed.dart';

@Freezed(fromJson: false, toJson: false)
abstract class ChatScreenState with _$ChatScreenState {
  ChatScreenState._();

  factory ChatScreenState({
    Contact? contact,
    Group? group,
    String? offerName,
    ContactCard? otherPartyCard,
    @Default([]) List<chat.ChatItem> messages,
    @Default([]) List<String> membersTyping,
    @Default(-1) int selectedReactionIndex,
    @Default(false) bool isActive,
    @Default(false) bool isInitialized,
    @Default(ContactPresenceStatus.unknown)
    ContactPresenceStatus contactPresenceStatus,
    ScreenEffect? effect,
    @Default({}) Map<String, Uint8List> attachmentsDataCache,
    String? notificationToken,
  }) = _ChatScreenState;

  int getIndexOfNextMessageFromMe(int startingFrom) {
    if (startingFrom >= messages.length) return -1;

    return messages.indexWhere(
      (message) => message.isFromMe,
      startingFrom,
    );
  }

  int getIndexOfNextMessageFromThem(int startingFrom) {
    if (startingFrom >= messages.length) return -1;

    return messages.indexWhere(
      (message) => !message.isFromMe,
      startingFrom,
    );
  }

  GroupMember? getGroupMemberByDid(String did) =>
      group?.members.firstWhereOrNull((gm) => gm.did == did);
}
