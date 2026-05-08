import 'dart:async';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/chat/encryption_notice.dart';
import '../../../domain/models/contact_card/contact_card.dart' as domain;
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_presence_status.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/extensions/chat_items_extensions.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/extensions/did_extensions.dart';
import '../../../infrastructure/extensions/list_extensions.dart';
import '../../../infrastructure/helpers/timed_action.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/plugins/vrc_attachments_plugin/vrc_request_attachment.dart';
import '../../../infrastructure/providers/app_badge_provider.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/chat_sdk_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/services/unsent_messages_service/unsent_messages_service.dart';
import '../contacts_service/contacts_service.dart';
import '../network_connectivity_service/network_connectivity_service.dart';
import 'chat_protocol_router.dart';
import 'chat_service.dart';
import 'chat_service_state.dart';
import 'delegates/chat_concierge_messenger.dart';
import 'delegates/chat_group_manager.dart';
import 'delegates/interfaces/concierge_messaging.dart';
import 'delegates/interfaces/group_managing.dart';
import 'delegates/r_card_manager.dart';
import 'delegates/vdip_manager.dart';
import 'delegates/vrc_manager.dart';
import 'handlers/chat_message_protocol_handler.dart';
import 'handlers/contact_card_protocol_handler.dart';
import 'handlers/effect_protocol_handler.dart';
import 'handlers/group_details_protocol_handler.dart';
import 'handlers/presence_protocol_handler.dart';
import 'handlers/typing_protocol_handler.dart';
import 'handlers/zkp_attachment_protocol_handler.dart';

part 'chat_session_service.g.dart';

@riverpod
class ChatSessionService extends _$ChatSessionService implements ChatService {
  static const _logKey = 'CHATSVC';
  // Maximum typing indicators to prevent UI overflow on small screens
  static const _maxTypingMembersVisible = 4;
  // Grace period to avoid blinking of presence indicator
  static const _presenceGracePeriodSeconds = 1;

  late AppLogger _logger;
  late String _otherPartyPermanentDid;
  late VdipManager _vdipManager;

  MeetingPlaceChatSDK? _chatSDK;
  String? _chatId;
  bool _isGroupChat = false;
  String? _otherPartyFirstName;
  ChatStream? _chatStreamRef;

  late ConciergeMessaging _conciergeMessenger;
  late GroupManaging _groupManager;
  late ChatProtocolRouter _router;
  late RCardManager _rCardManager;
  late VrcManager _vrcManager;

  TimedAction? _presenceTimedAction;
  TimedAction? _typingTimedAction;

  @override
  int get secondsToShowChatActivityIndicator =>
      ref.read(environmentProvider).chatActivityExpiresInSeconds;

  @override
  int get chatPresenceIntervalInSeconds =>
      ref.read(environmentProvider).chatPresenceIntervalInSeconds;

  bool get isGroupChat => _isGroupChat;

  @override
  ChatServiceState build(String channelDid) {
    _otherPartyPermanentDid = channelDid;
    _logger = ref.read(appLoggerProvider);
    _rCardManager = RCardManager(
      ref: ref,
      otherPartyPermanentDid: channelDid,
      logger: _logger,
      getChatSdk: () => _chatSDK,
      upsertChatItem: upsertChatItem,
    );
    _vrcManager = VrcManager(
      ref: ref,
      getChatId: () => _chatId,
      logger: _logger,
      getChatSdk: () => _chatSDK,
      getMessages: () => state.messages,
      upsertChatItem: upsertChatItem,
      removeChatItem: _removeChatItem,
    );
    _vdipManager = VdipManager(
      ref: ref,
      otherPartyPermanentDid: channelDid,
      logger: _logger,
      getChatSdk: () => _chatSDK,
      getMessages: () => state.messages,
      persistLocalEventMessage: _vrcManager.persistLocalEventMessage,
      onVrcRequestReceived: _vrcManager.onVrcRequestReceived,
    );

    _groupManager = ChatGroupManager(ref: ref);
    _setupChatProtocolRouter();

    ref.listen(networkConnectivityServiceProvider, (previous, next) {
      if (previous?.isConnected == false && next.isConnected) {
        _logger.info(
          'Network reconnected - resuming chat presence updates',
          name: _logKey,
        );
        _chatSDK?.startChatPresenceUpdates();
      }
    }, fireImmediately: true);

    ref.onDispose(() {
      _presenceTimedAction?.cancel();
      _typingTimedAction?.cancel();
      _rCardManager.cancelSubscription();
      _chatStreamRef?.dispose();
      _chatStreamRef = null;
      unawaited(_vdipManager.cancelSubscriptions());
      _chatSDK?.endChatSession();
      _logger.info('ChatSessionService disposed', name: _logKey);
    });

    return ChatServiceState();
  }

  void _setupChatProtocolRouter() {
    final env = ref.read(environmentProvider);
    _router = ChatProtocolRouter(
      handlers: [
        PresenceProtocolHandler(
          ref: ref,
          onPresenceUpdated: onPresenceUpdated,
          logger: _logger,
        ),
        ChatMessageProtocolHandler(
          onUpdateSequenceNumber: updateContactSequenceNumber,
          logger: _logger,
        ),
        ZkpAttachmentProtocolHandler(
          onZkpAttachment: _onZkpAttachment,
          logger: _logger,
        ),
        TypingProtocolHandler(
          secondsToShowChatActivityIndicator: env.chatActivityExpiresInSeconds,
          onTypingMember: _onTypingMember,
          logger: _logger,
        ),
        EffectProtocolHandler(onEffect: _onEffect, logger: _logger),
        ContactCardProtocolHandler(
          ref: ref,
          isGroupChat: () => _isGroupChat,
          onGroupDetailsUpdated: _onGroupDetailsUpdated,
          onOtherPartyCardUpdated: _onOtherPartyCardUpdated,
          logger: _logger,
        ),
        GroupDetailsProtocolHandler(
          onGroupDetailsUpdated: _onGroupDetailsUpdated,
          logger: _logger,
        ),
      ],
    );
  }

  void _onZkpAttachment(StreamData data, String channelDid) {
    state = state.copyWith(
      zkpAttachmentEvent: ZkpAttachmentEvent(
        data: data,
        channelDid: channelDid,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Session management
  // ---------------------------------------------------------------------------

  Future<void> _ensureChatSdkInitialized() async {
    if (_chatSDK != null) return;

    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
      _otherPartyPermanentDid,
    );
    if (channel == null) return;

    _chatSDK = await ref.read(chatSdkProvider(channel).future);
    _conciergeMessenger = ChatConciergeMessenger(chatSdk: _chatSDK!);
    _isGroupChat =
        ref
            .read(contactsServiceProvider)
            .getContactByChannelDid(_otherPartyPermanentDid)
            ?.isGroup ??
        false;

    final srcCard = channel.otherPartyContactCard;
    final initialCard = srcCard != null
        ? ContactCardUtils.fromSdkContactCard(srcCard)
        : null;
    _otherPartyFirstName = initialCard?.firstName;

    if (_isGroupChat) {
      final group = await coreSdk.getGroupByOfferLink(channel.offerLink);
      if (group != null) {
        state = state.copyWith(group: group);
      }
    }
  }

  @override
  Future<void> startChatSession() async {
    _chatStreamRef?.dispose();
    _chatStreamRef = null;

    await _ensureChatSdkInitialized();
    if (_chatSDK == null) return;

    await _vdipManager.subscribe();

    try {
      final chatSession = await _chatSDK!.startChatSession();
      _chatId = chatSession.id;

      final chatStream = await _chatSDK!.chatStreamSubscription;
      if (chatStream == null) {
        _logger.warning('Chat stream is null', name: _logKey);
      } else {
        _chatStreamRef = chatStream
          ..listen(
            (data) => _onChannelMessagesData(data, _otherPartyPermanentDid),
            onError: (Object error, StackTrace stackTrace) {
              _logger.error(
                'Error in chat stream subscription',
                error: error,
                stackTrace: stackTrace,
                name: _logKey,
              );
            },
          );
      }

      final dbMessageIds = {
        EncryptionNotice().messageId,
        for (final m in chatSession.messages) m.messageId,
      };
      final replayMessages = state.messages
          .where((m) => !dbMessageIds.contains(m.messageId))
          .toList();
      final baseMessages = [
        EncryptionNotice(),
        ...chatSession.messages,
        ...replayMessages,
      ].sortedBy((item) => item.dateCreated).reversed.toList();
      final messages = _appendDerivedZkpNotices(baseMessages);
      state = state.copyWith(messages: messages, isInitialized: true);

      // Replay any VRC events that fired before the chat was opened
      // (e.g. while the user was offline). Must run AFTER:
      // 1. The stream listener is attached — so messages pushed via
      //    chatStream reach the UI immediately.
      // 2. state.messages is updated with the loaded chat history — so
      //    _hasVrcExchangeInitiated, _vrcInitiatorIdentityDid and related
      //    flags correctly reflect the persisted exchange state. Without
      //    this ordering, the reciprocation step is skipped because the
      //    initiator's state appears empty on a cold start.
      if (_chatStreamRef != null) {
        await _vdipManager.replayPending();
      }

      await _resetBadgeCount();
      unawaited(ref.read(appBadgeServiceProvider).clearBadge());

      unawaited(
        _rCardManager.subscribeToIncomingRCards().then(
          (_) => _rCardManager.replayPendingRCard(),
        ),
      );
      _logger.info('Chat session started', name: _logKey);
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to start chat session',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }

  @override
  Future<String?> restoreUnsentMessage(String contactId) async {
    final unsentMessagesService = ref.read(
      unsentMessagesServiceProvider.notifier,
    );
    await unsentMessagesService.ensureInitialized();
    return unsentMessagesService.getUnsentMessage(contactId);
  }

  @override
  Future<ContactPresenceStatus> calculateContactPresenceStatus(
    DateTime datePresence,
    int presenceIntervalInSeconds,
  ) async {
    final now = clock.now();
    final hasReceivedAnyActivity = datePresence.toLocal().isAfter(
      now.subtract(Duration(seconds: presenceIntervalInSeconds)),
    );
    return hasReceivedAnyActivity
        ? ContactPresenceStatus.online
        : ContactPresenceStatus.offline;
  }

  @override
  Future<void> updateGroupContactPendingStatus(
    Contact contact,
    Group group,
  ) async {
    await _groupManager.updateGroupContactPendingStatus(contact, group);
  }

  @override
  Future<Group?> refreshGroup(String groupId) =>
      _groupManager.refreshGroup(groupId);

  @override
  void pauseChat() {
    _chatStreamRef?.dispose();
    _chatStreamRef = null;
    _chatSDK?.endChatSession();
    _rCardManager.cancelSubscription();
    unawaited(_vdipManager.cancelSubscriptions());
  }

  @override
  Future<void> sendRCardFromPlugin(Identity identity) =>
      _rCardManager.sendRCardFromPlugin(identity);

  @override
  Future<void> sendTextMessage(
    String message, {
    List<ChatAttachment>? attachments,
  }) async {
    await _chatSDK?.sendTextMessage(message, attachments: attachments ?? []);
  }

  @override
  Future<void> sendChatActivity() async {
    await _chatSDK?.sendChatActivity();
  }

  @override
  Future<void> rejectConnectionRequest(ConciergeMessage message) async {
    await _conciergeMessenger.rejectConnectionRequest(message);
  }

  @override
  Future<void> approveConnectionRequest(ConciergeMessage message) async {
    await _conciergeMessenger.approveConnectionRequest(message);
  }

  @override
  Future<void> sendChatContactDetailsUpdate(ConciergeMessage message) async {
    await _conciergeMessenger.sendChatContactDetailsUpdate(message);
    await _rCardManager.sendProfileUpdateWithRCard(message);
  }

  @override
  Future<void> rejectChatContactDetailsUpdate(ConciergeMessage message) async {
    await _conciergeMessenger.rejectChatContactDetailsUpdate(message);
  }

  @override
  Future<void> reactOnMessage(
    Message message, {
    required String reaction,
  }) async {
    await _chatSDK?.reactOnMessage(message, reaction: reaction);
  }

  @override
  Future<void> sendEffect(Effect effectType) async {
    await _chatSDK?.sendEffect(effectType);
  }

  @override
  Future<void> updateContactSequenceNumber(String channelDid) async {
    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
      channelDid,
    );
    if (channel == null) {
      _logger.warning(
        'Cannot update contact sequence number: channel cannot be found',
        name: _logKey,
      );
      return;
    }

    await ref
        .read(contactsServiceProvider.notifier)
        .updateContactSequenceNumber(channelDid, channel.seqNo);
  }

  @override
  Future<void> resetBadgeCount() => _resetBadgeCount();

  void _toggleChatLoading(bool isLoading) {
    if (!ref.mounted) return;
    state = state.copyWith(isActive: isLoading);
  }

  Future<void> _resetBadgeCount() async {
    await ref
        .read(contactsServiceProvider.notifier)
        .resetContactBadgeCount(_otherPartyPermanentDid);
  }

  // ---------------------------------------------------------------------------
  // Incoming message routing
  // ---------------------------------------------------------------------------

  Future<void> _onChannelMessagesData(
    StreamData data,
    String channelDid,
  ) async {
    _toggleChatLoading(true);
    _logger.info(
      '[MessagesStream] Received event: ${data.event.runtimeType}',
      name: _logKey,
    );

    await _router.route(data, channelDid);

    final chatItem = data.chatItem;
    if (chatItem != null) {
      // VRC request messages are protocol signals; they must not appear as
      // chat bubbles on either side of the conversation.
      final isVrcRequest =
          chatItem is Message &&
          chatItem.attachments.isNotEmpty &&
          chatItem.attachments.every(
            (a) => a.format == VrcRequestAttachment.pluginFormat,
          );

      if (!isVrcRequest &&
          (chatItem is Message ||
              chatItem is ConciergeMessage ||
              chatItem is EventMessage)) {
        upsertChatItem(chatItem);
      }
      if (chatItem is Message && !chatItem.isFromMe) {
        _clearMembersTypingActivity(chatItem.senderDid);
      }
      if (chatItem is Message &&
          LivenessZkpConciergeDeriver.messageHasZkpAttachments(chatItem)) {
        _syncHumanZkpNotices();
      }
    }

    _toggleChatLoading(false);
  }

  @override
  void upsertChatItem(ChatItem item) {
    final existing = state.messages;
    final idx = existing.indexWhere((m) => m.messageId == item.messageId);
    final messages = idx == -1
        ? existing.insertSorted(item)
        : existing.replaceItemAtIndex(idx, item);
    state = state.copyWith(messages: messages);
  }

  String _peerFirstNameForZkpUi() {
    return _otherPartyFirstName?.isNotEmpty == true
        ? _otherPartyFirstName!
        : ref
                  .read(contactsServiceProvider)
                  .getContactByChannelDid(_otherPartyPermanentDid)
                  ?.card
                  .firstName ??
              '';
  }

  List<ChatItem> _appendDerivedZkpNotices(List<ChatItem> existing) {
    return LivenessZkpConciergeDeriver.appendDerivedHumanZkpConciergeMessages(
      existing,
      contactName: _peerFirstNameForZkpUi(),
    );
  }

  void _syncHumanZkpNotices() {
    state = state.copyWith(messages: _appendDerivedZkpNotices(state.messages));
  }

  // ---------------------------------------------------------------------------
  // Protocol callbacks (invoked by handlers via ChatProtocolRouter)
  // ---------------------------------------------------------------------------

  @override
  void onPresenceUpdated(DateTime datePresence) {
    _presenceTimedAction?.cancel();
    _presenceTimedAction ??= TimedAction(
      onRun: (args) async {
        final datePresence = args?[0] as DateTime? ?? clock.now();
        final status = await calculateContactPresenceStatus(
          datePresence,
          chatPresenceIntervalInSeconds,
        );
        state = state.copyWith(contactPresenceStatus: status);
      },
      onComplete: () {
        Future.microtask(() {
          state = state.copyWith(
            contactPresenceStatus: ContactPresenceStatus.offline,
          );
        });
      },
      duration: Duration(
        seconds: chatPresenceIntervalInSeconds + _presenceGracePeriodSeconds,
      ),
    );
    _presenceTimedAction!.start(args: [datePresence]);
  }

  void _onTypingMember(String? senderDid) {
    String? groupMessageSenderName;
    String? contactName;

    if (_isGroupChat && senderDid != null) {
      groupMessageSenderName = state
          .getGroupMemberByDid(senderDid)
          ?.contactCard
          .firstName;
    }

    if (!_isGroupChat) {
      contactName = _otherPartyFirstName?.isNotEmpty == true
          ? _otherPartyFirstName
          : ref
                .read(contactsServiceProvider)
                .getContactByChannelDid(_otherPartyPermanentDid)
                ?.card
                .firstName;
    }

    _logger.info(
      '_onTypingMember called with senderDid: $senderDid, '
      'resolved name: ${groupMessageSenderName ?? contactName}',
      name: _logKey,
    );

    _typingTimedAction?.cancel();
    state = state.copyWith(membersTyping: []);
    _typingTimedAction = TimedAction(
      onRun: (args) {
        var memberNames = <String>[];
        if (groupMessageSenderName != null &&
            groupMessageSenderName.isNotEmpty) {
          memberNames = [...state.membersTyping];
          if (memberNames.length < _maxTypingMembersVisible &&
              !memberNames.contains(groupMessageSenderName)) {
            memberNames.add(groupMessageSenderName);
          }
        } else if (contactName != null && contactName.isNotEmpty) {
          memberNames = [contactName];
        }
        if (memberNames.isEmpty) return;
        state = state.copyWith(membersTyping: memberNames);

        _logger.info(
          '_onTypingMember onRun: membersTyping updated: $memberNames',
          name: _logKey,
        );
      },
      onComplete: () {
        state = state.copyWith(membersTyping: []);
        _logger.info('_onTypingMember onComplete', name: _logKey);
      },
      duration: Duration(seconds: secondsToShowChatActivityIndicator),
    );
    _typingTimedAction!.start(args: [groupMessageSenderName]);
  }

  void _onEffect(String? effectName) {
    if (effectName == null || state.effect != null) return;
    final effect = Effect.values.firstWhereOrNull((e) => e.name == effectName);
    if (effect != null &&
        effect != Effect.fireworks &&
        effect != Effect.hearts) {
      state = state.copyWith(effect: effect);
    }
    _logger.info(
      '_onEffect: effectName=$effectName, '
      'resolved effect=$effect',
      name: _logKey,
    );
  }

  @override
  void clearEffect() {
    state = state.copyWith(effect: null);
  }

  void _onGroupDetailsUpdated(ChatEvent event, String channelDid) {
    _logger.info(
      'Updating group details for channel ${channelDid.topAndTail()}',
      name: _logKey,
    );
    unawaited(_refreshGroup());
  }

  void _onOtherPartyCardUpdated(domain.ContactCard domainCard) {
    _otherPartyFirstName = domainCard.firstName;
    state = state.copyWith(otherPartyCard: domainCard);
    _logger.info('Updated other party contact card', name: _logKey);
  }

  @override
  Future<void> persistLocalEventMessage(
    EventMessageType eventType, {
    Map<String, dynamic> data = const {},
  }) => _vrcManager.persistLocalEventMessage(eventType, data: data);

  @override
  Future<void> dismissVrcConciergeMessages() =>
      _vrcManager.dismissVrcConciergeMessages();

  @override
  Future<void> showSentVrcAttachment({
    required String vcBlob,
    required String senderDid,
  }) => _vrcManager.showSentVrcAttachment(vcBlob: vcBlob, senderDid: senderDid);

  void _removeChatItem(ChatItem item) {
    final messages = state.messages
        .where((m) => m.messageId != item.messageId)
        .toList();
    state = state.copyWith(messages: messages);
  }

  Future<void> _refreshGroup() async {
    final currentGroup = state.group;
    if (currentGroup == null) return;

    final refreshedGroup = await _groupManager.refreshGroup(currentGroup.id);
    if (!ref.mounted || refreshedGroup == null) return;

    state = state.copyWith(group: refreshedGroup);
  }

  void _clearMembersTypingActivity(String? senderDid) {
    final memberNames = [...state.membersTyping];
    if (memberNames.isEmpty) return;

    // For group chats, senderDid is required to identify which member to remove
    if (_isGroupChat && (senderDid == null || senderDid.isEmpty)) return;

    final groupMessageSenderName = _isGroupChat && senderDid != null
        ? state.getGroupMemberByDid(senderDid)?.contactCard.firstName
        : null;

    String? contactName;
    if (!_isGroupChat) {
      contactName = _otherPartyFirstName?.isNotEmpty == true
          ? _otherPartyFirstName
          : ref
                .read(contactsServiceProvider)
                .getContactByChannelDid(_otherPartyPermanentDid)
                ?.card
                .firstName;
    }

    memberNames.removeWhere(
      (name) => name == groupMessageSenderName || name == contactName,
    );
    state = state.copyWith(membersTyping: memberNames);
  }
}
