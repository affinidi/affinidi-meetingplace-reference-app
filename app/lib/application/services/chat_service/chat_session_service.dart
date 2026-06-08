import 'dart:async';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/chat/encryption_notice.dart';
import '../../../domain/models/contact_card/contact_card.dart' as domain;
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_presence_status.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/extensions/chat_items_extensions.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/extensions/did_extensions.dart';
import '../../../infrastructure/extensions/list_extensions.dart';
import '../../../infrastructure/helpers/timed_action.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
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
import 'handlers/chat_message_protocol_handler.dart';
import 'handlers/contact_card_protocol_handler.dart';
import 'handlers/effect_protocol_handler.dart';
import 'handlers/group_details_protocol_handler.dart';
import 'handlers/presence_protocol_handler.dart';
import 'handlers/typing_protocol_handler.dart';

part 'chat_session_service.g.dart';

@riverpod
class ChatSessionService extends _$ChatSessionService implements ChatService {
  static const _logKey = 'CHATSVC';
  // Maximum typing indicators to prevent UI overflow on small screens
  static const _maxTypingMembersVisible = 4;
  // Grace period to avoid blinking of presence indicator
  static const _presenceGracePeriodSeconds = 1;

  late AppLogger _logger;
  late String _channelDid;

  MeetingPlaceChatSDK? _chatSDK;
  bool _isGroupChat = false;
  String? _otherPartyFirstName;
  ChatStream? _messageSubscription;

  late ConciergeMessaging _conciergeMessenger;
  late GroupManaging _groupManager;
  late ChatProtocolRouter _router;

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
    _channelDid = channelDid;
    _logger = ref.read(appLoggerProvider);

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
      _messageSubscription?.dispose();
      unawaited(_chatSDK?.endChatSession());
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

  // ---------------------------------------------------------------------------
  // Session management
  // ---------------------------------------------------------------------------

  Future<void> _ensureChatSdkInitialized() async {
    if (_chatSDK != null) return;

    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
      _channelDid,
    );
    if (channel == null) return;

    _chatSDK = await ref.read(chatSdkProvider(channel).future);
    _conciergeMessenger = ChatConciergeMessenger(chatSdk: _chatSDK!);
    _isGroupChat =
        ref
            .read(contactsServiceProvider)
            .getContactByChannelDid(_channelDid)
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
    _messageSubscription?.dispose();
    _messageSubscription = null;

    await _ensureChatSdkInitialized();
    if (_chatSDK == null) return;

    try {
      final chatSession = await _chatSDK!.startChatSession();

      final messages = [
        EncryptionNotice(),
        ...chatSession.messages,
      ].sortedBy((item) => item.dateCreated).reversed.toList();
      state = state.copyWith(messages: messages, isInitialized: true);

      // Reset must be fully committed before the stream listener is attached.
      // Buffered events flush as soon as the listener attaches and would
      // otherwise race with this update on a stale Contact snapshot, causing
      // a seqNo write to clobber badgeCount=0 back to its previous value.
      await _resetBadgeCount();
      unawaited(ref.read(appBadgeServiceProvider).clearBadge());

      unawaited(
        _chatSDK!.chatStreamSubscription.then(
          (chatStream) {
            if (_chatSDK == null) {
              // pauseChat ran while we were waiting for the transport
              // subscription. Drop the listener attachment to avoid leaking
              // a subscription that has no disposal path.
              return;
            }
            if (chatStream == null) {
              _logger.warning('Chat stream is null', name: _logKey);
              return;
            }

            _messageSubscription = chatStream.listen(
              (data) => _onChannelMessagesData(data, _channelDid),
              onError: (Object error, StackTrace stackTrace) {
                _logger.error(
                  'Error in chat stream subscription',
                  error: error,
                  stackTrace: stackTrace,
                  name: _logKey,
                );
              },
            );
          },
          onError: (Object error, StackTrace stackTrace) {
            _logger.error(
              'Failed to get chat stream subscription',
              error: error,
              stackTrace: stackTrace,
              name: _logKey,
            );
          },
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
  Future<void> removeMember({
    required String groupId,
    required String memberDid,
  }) async {
    await _ensureChatSdkInitialized();
    if (!_isGroupChat) {
      _logger.error(
        'Attempted to remove member from non-group chat',
        name: _logKey,
      );
      return;
    }

    await _chatSDK?.removeMember(memberDid);
  }

  @override
  Future<void> pauseChat() async {
    final sdk = _chatSDK;
    _chatSDK = null;
    _messageSubscription?.dispose();
    _messageSubscription = null;
    await sdk?.endChatSession();
  }

  @override
  Future<void> sendTextMessage(
    String message, {
    List<ChatAttachment>? attachments,
  }) async {
    await _chatSDK?.sendTextMessage(
      message,
      attachments: attachments ?? const [],
    );
  }

  @override
  Future<Uint8List> downloadMedia(ChatAttachment attachment) async {
    final sdk = _chatSDK;
    if (sdk == null) {
      throw StateError('Chat SDK not initialized');
    }
    return sdk.downloadMedia(attachment);
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
    state = state.copyWith(isActive: isLoading);
  }

  Future<void> _resetBadgeCount() async {
    await ref
        .read(contactsServiceProvider.notifier)
        .resetContactBadgeCount(_channelDid);
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
      if (chatItem is Message ||
          chatItem is ConciergeMessage ||
          chatItem is EventMessage) {
        _upsertChatItem(chatItem);
      }
      if (chatItem is Message && !chatItem.isFromMe) {
        _clearMembersTypingActivity(chatItem.senderDid);
      }
    }

    _toggleChatLoading(false);
  }

  void _upsertChatItem(ChatItem item) {
    final existing = state.messages;
    final idx = existing.indexWhere((m) => m.messageId == item.messageId);
    final messages = idx == -1
        ? existing.insertSorted(item)
        : existing.replaceItemAtIndex(idx, item);
    state = state.copyWith(messages: messages);
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
                .getContactByChannelDid(_channelDid)
                ?.card
                .firstName;
    }

    _logger.info(
      '_onTypingMember called with senderDid: $senderDid, '
      'resolved name: ${groupMessageSenderName ?? contactName}',
      name: _logKey,
    );

    _typingTimedAction?.cancel();
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
      onCancel: () {
        state = state.copyWith(membersTyping: []);
        _logger.info('_onTypingMember onCancel', name: _logKey);
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

  Future<void> _refreshGroup() async {
    final currentGroup = state.group;
    if (currentGroup == null) return;

    final refreshedGroup = await _groupManager.refreshGroup(currentGroup.id);
    if (refreshedGroup == null) return;

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
                .getContactByChannelDid(_channelDid)
                ?.card
                .firstName;
    }

    memberNames.removeWhere(
      (name) => name == groupMessageSenderName || name == contactName,
    );
    state = state.copyWith(membersTyping: memberNames);
  }
}
