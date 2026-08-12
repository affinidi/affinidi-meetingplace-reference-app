import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_core/meeting_place_core.dart' hide ContactCard;

import '../../../application/services/chat_service/chat_service_state.dart';
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
    ContactCard? myCard,
    @Default([]) List<chat.ChatItem> messages,
    ChatSuggestion? latestSuggestion,
    String? pendingSuggestionMessageId,
    @Default([]) List<String> membersTyping,
    @Default(-1) int selectedReactionIndex,
    @Default(false) bool isActive,
    @Default(false) bool isInitialized,
    @Default(ContactPresenceStatus.unknown)
    ContactPresenceStatus contactPresenceStatus,
    ScreenEffect? effect,
    @Default({}) Map<String, Uint8List> attachmentsDataCache,
    String? notificationToken,
    String? myDid,
    @Default(false) bool shouldEnableVrcAttachment,
    @Default(false) bool isPersonalAgentReady,
    @Default(false) bool shouldShowVrcBanner,
    @Default(false) bool shouldStartVrcExchangeFromAttachment,
    chat.TransportCapabilities? capabilities,
    @Default(false) bool isCallSupported,
  }) = _ChatScreenState;

  bool get hasPendingVrcConcierge => messages.any(
    (m) =>
        m is chat.ConciergeMessage &&
        m.conciergeType ==
            chat.ConciergeMessageType.fromJson(
              'permissionToVerifyRelationship',
            ) &&
        m.status == chat.ChatItemStatus.userInput,
  );

  bool get hasVrcExchangeDoLater => messages.any(
    (m) =>
        m is chat.EventMessage &&
        m.eventType == chat.EventMessageType.fromJson('vrcExchangeDoLater'),
  );

  bool get hasVrcExchangeInitiated => messages.any(
    (m) =>
        m is chat.EventMessage &&
        m.eventType == chat.EventMessageType.fromJson('vrcExchangeInitiated'),
  );

  bool get hasVrcRequestReceived => messages.any(
    (m) =>
        m is chat.EventMessage &&
        m.eventType == chat.EventMessageType.fromJson('vrcRequestReceived'),
  );

  bool get hasVrcExchangeCompleted => messages.any(
    (m) =>
        m is chat.EventMessage &&
        m.eventType == chat.EventMessageType.fromJson('vrcExchangeCompleted'),
  );

  String? get vrcRequestIdentityDid {
    final event = messages.whereType<chat.EventMessage>().firstWhereOrNull(
      (m) =>
          m.eventType == chat.EventMessageType.fromJson('vrcRequestReceived'),
    );
    return event?.data['identityDid'] as String?;
  }

  String? get vrcRequestIdentityName {
    final event = messages.whereType<chat.EventMessage>().firstWhereOrNull(
      (m) =>
          m.eventType == chat.EventMessageType.fromJson('vrcRequestReceived'),
    );
    return event?.data['identityName'] as String?;
  }

  String? get vrcInitiatorIdentityDid {
    final event = messages.whereType<chat.EventMessage>().firstWhereOrNull(
      (m) =>
          m.eventType == chat.EventMessageType.fromJson('vrcExchangeInitiated'),
    );
    return event?.data['identityDid'] as String?;
  }

  String? get vrcInitiatorIdentityName {
    final event = messages.whereType<chat.EventMessage>().firstWhereOrNull(
      (m) =>
          m.eventType == chat.EventMessageType.fromJson('vrcExchangeInitiated'),
    );
    return event?.data['identityName'] as String?;
  }

  int getIndexOfNextMessageFromMe(int startingFrom) {
    if (startingFrom >= messages.length) return -1;

    return messages.indexWhere((message) => message.isFromMe, startingFrom);
  }

  int getIndexOfNextMessageFromThem(int startingFrom) {
    if (startingFrom >= messages.length) return -1;

    return messages.indexWhere((message) => !message.isFromMe, startingFrom);
  }

  GroupMember? getGroupMemberByDid(String did) =>
      group?.members.firstWhereOrNull((gm) => gm.did == did);
}
