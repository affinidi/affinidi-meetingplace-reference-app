import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/chat/encryption_notice.dart';
import '../../../domain/models/contact_card/contact_card.dart' as domain;
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_presence_status.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/extensions/chat_items_extensions.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/extensions/did_extensions.dart';
import '../../../infrastructure/extensions/list_extensions.dart';
import '../../../infrastructure/helpers/keyed_lock.dart';
import '../../../infrastructure/helpers/timed_action.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/plugins/audio_attachments_plugin/audio_attachments_plugin.dart';
import '../../../infrastructure/plugins/vrc_attachments_plugin/vrc_request_attachment.dart';
import '../../../infrastructure/providers/app_badge_provider.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/chat_sdk_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/services/unsent_messages_service/unsent_messages_service.dart';
import '../contacts_service/contacts_service.dart';
import '../identities_service/identities_service.dart';
import '../network_connectivity_service/network_connectivity_service.dart';
import 'chat_protocol_router.dart';
import 'chat_service.dart';
import 'chat_service_state.dart';
import 'delegates/call_chat_item_manager.dart';
import 'delegates/chat_concierge_messenger.dart';
import 'delegates/chat_group_manager.dart';
import 'delegates/interfaces/concierge_messaging.dart';
import 'delegates/interfaces/group_managing.dart';
import 'delegates/r_card_manager.dart';
import 'delegates/vdip_manager.dart';
import 'delegates/vrc_manager.dart';
import 'handlers/call_outcome_protocol_handler.dart';
import 'handlers/chat_message_protocol_handler.dart';
import 'handlers/contact_card_protocol_handler.dart';
import 'handlers/effect_protocol_handler.dart';
import 'handlers/group_details_protocol_handler.dart';
import 'handlers/presence_protocol_handler.dart';
import 'handlers/typing_protocol_handler.dart';
import 'handlers/zkp_attachment_protocol_handler.dart';
import 'missed_call_manager.dart';
import 'open_chat_registry.dart';
import 'typing_timer.dart';

part 'chat_session_service.g.dart';

@riverpod
class ChatSessionService extends _$ChatSessionService implements ChatService {
  static const _logKey = 'CHATSVC';
  // Maximum typing indicators to prevent UI overflow on small screens
  static const _maxTypingMembersVisible = 4;
  // Grace period to avoid blinking of presence indicator
  static const _presenceGracePeriodSeconds = 1;

  // Serializes session lifecycle (init/teardown) per channel across notifier
  // instances. ref.onDispose is `void`, so a freshly-built notifier needs a
  // way to wait for the previous instance's still-in-flight endChatSession
  // before constructing a new SDK. Locks are retained for the process
  // lifetime; bound is the set of channels the user has opened.
  static final _channelLocks = KeyedLock<String>();

  late AppLogger _logger;
  late String _otherPartyPermanentChannelDid;
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
  late CallChatItemManager _callChatItemManager;
  MissedCallManager? _missedCallManager;

  TimedAction? _presenceTimedAction;
  final Map<String, TypingTimer> _typingTimedActions = {};
  static const _oneToOneTypingKey = '_one_to_one_';
  final List<_BufferedOutboundMessage> _bufferedOutboundMessages = [];
  Future<void>? _bufferFlushInFlight;

  @override
  int get secondsToShowChatActivityIndicator =>
      ref.read(environmentProvider).chatActivityExpiresInSeconds;

  @override
  int get chatPresenceIntervalInSeconds =>
      ref.read(environmentProvider).chatPresenceIntervalInSeconds;

  @override
  Duration get deleteMessageWindow => Duration(
    seconds: ref.read(environmentProvider).deleteMessageWindowInSeconds,
  );

  @override
  TransportCapabilities? get capabilities => _chatSDK?.capabilities;

  bool get _isHumanZkpActive =>
      ref.read(environmentProvider).zkpEnabled &&
      (_chatSDK?.capabilities.supports(ChatFeature.humanZkp) ?? false);

  bool get isGroupChat => _isGroupChat;

  @override
  ChatServiceState build(String channelDid) {
    _otherPartyPermanentChannelDid = channelDid;
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

    _callChatItemManager = CallChatItemManager(
      ensureInitialized: _ensureChatSdkInitialized,
      getChatSdk: () => _chatSDK,
      logger: _logger,
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
      for (final action in _typingTimedActions.values) {
        action.cancel();
      }

      unawaited(_disposeChatSession());
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
        CallOutcomeProtocolHandler(
          callChatItemManager: _callChatItemManager,
          logger: _logger,
        ),
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

  void _onZkpAttachment(ChatItem chatItem, String channelDid) {
    if (!_isHumanZkpActive) return;
    state = state.copyWith(
      zkpAttachmentEvent: ZkpAttachmentEvent(
        chatItem: chatItem,
        channelDid: channelDid,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Session management
  // ---------------------------------------------------------------------------

  Future<void> _ensureChatSdkInitialized() async {
    if (_chatSDK != null) return;
    await _channelLocks.synchronized(_otherPartyPermanentChannelDid, () async {
      if (_chatSDK != null) return;
      if (!ref.mounted) return;

      final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
      if (!ref.mounted) return;

      final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
        _otherPartyPermanentChannelDid,
      );
      if (channel == null) {
        _logger.warning(
          '_ensureChatSdkInitialized: channel not found for '
          '${_otherPartyPermanentChannelDid.topAndTail()} — '
          'SDK may not have synced yet',
          name: _logKey,
        );
        return;
      }
      if (!ref.mounted) return;

      _chatSDK = await ref.read(chatSdkProvider(channel).future);
      if (!ref.mounted) {
        _chatSDK = null;
        return;
      }

      _conciergeMessenger = ChatConciergeMessenger(chatSdk: _chatSDK!);
      _isGroupChat =
          ref
              .read(contactsServiceProvider)
              .getContactByChannelDid(_otherPartyPermanentChannelDid)
              ?.isGroup ??
          false;

      final srcCard = channel.otherPartyContactCard;
      final initialCard = srcCard != null
          ? ContactCardUtils.fromSdkContactCard(srcCard)
          : null;
      _otherPartyFirstName = initialCard?.firstName;

      if (_isGroupChat) {
        final group = await coreSdk.getGroupByOfferLink(channel.offerLink);
        if (!ref.mounted) return;
        if (group != null) {
          state = state.copyWith(group: group);
        }
      }

      ref.listen(identitiesServiceProvider, (previous, next) {
        if (!ref.mounted || _chatSDK == null) return;

        final previousCard = previous
            ?.getIdentityById(channel.externalRef)
            ?.card;
        final nextCard = next.getIdentityById(channel.externalRef)?.card;
        if (previousCard == nextCard) return;

        unawaited(
          _chatSDK?.refreshCurrentContactCard(nextCard?.toSdkContactCard()) ??
              Future<void>.value(),
        );
      });
    });
  }

  @override
  Future<void> startChatSession() async {
    _chatStreamRef?.dispose();
    _chatStreamRef = null;

    await _ensureChatSdkInitialized();
    if (_chatSDK == null) return;

    _missedCallManager = MissedCallManager(
      ref: ref,
      otherPartyPermanentChannelDid: _otherPartyPermanentChannelDid,
      callChatItemManager: _callChatItemManager,
      onUpsertChatItem: upsertChatItem,
    );

    await _vdipManager.subscribe();

    try {
      final chatSession = await _chatSDK!.startChatSession();
      _chatId = chatSession.id;

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
      await _flushBufferedOutboundMessages();

      final chatStreamAttached = _chatSDK!.chatStreamSubscription.then((
        chatStream,
      ) {
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

        _chatStreamRef = chatStream
          ..listen(
            (data) =>
                _onChannelMessagesData(data, _otherPartyPermanentChannelDid),
            onError: (Object error, StackTrace stackTrace) {
              _logger.error(
                'Error in chat stream subscription',
                error: error,
                stackTrace: stackTrace,
                name: _logKey,
              );
            },
          );
      });

      unawaited(chatStreamAttached);

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

      unawaited(
        _rCardManager.subscribeToIncomingRCards().then((_) async {
          if (!ref.mounted) return;
          await _rCardManager.replayPendingRCard();
        }),
      );

      await chatStreamAttached;

      if (_missedCallManager != null) {
        await _missedCallManager!.reconcilePendingMissedCall();
      }

      await _resetBadgeCount();
      unawaited(ref.read(appBadgeServiceProvider).clearBadge());

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
  Future<void> pauseChat() => _disposeChatSession();

  Future<void> _disposeChatSession() async {
    final sdk = _chatSDK;
    _chatSDK = null;
    _chatId = null;

    _chatStreamRef?.dispose();
    _chatStreamRef = null;

    _rCardManager.cancelSubscription();
    await _vdipManager.cancelSubscriptions();

    if (sdk == null) return Future.value();

    await _channelLocks.synchronized(
      _otherPartyPermanentChannelDid,
      sdk.endChatSession,
    );
  }

  @override
  Future<void> sendRCardFromPlugin(Identity identity) =>
      _rCardManager.sendRCardFromPlugin(identity);

  @override
  Future<void> sendTextMessage(
    String message, {
    List<ChatAttachment>? attachments,
  }) async {
    final sdk = _chatSDK;
    if (sdk == null) {
      final bufferedMessage = _BufferedOutboundMessage(
        id: const Uuid().v4(),
        text: message,
        attachments: List<ChatAttachment>.from(attachments ?? const []),
      );
      _bufferedOutboundMessages.add(bufferedMessage);
      _logger.info(
        '''Buffered outbound message ${bufferedMessage.id} while chat SDK was unavailable''',
        name: _logKey,
      );
      return;
    }

    await sdk.sendTextMessage(message, attachments: attachments ?? const []);
  }

  Future<void> _flushBufferedOutboundMessages() async {
    final flushInFlight = _bufferFlushInFlight;
    if (flushInFlight != null) {
      await flushInFlight;
      return;
    }

    final flushFuture = _flushBufferedOutboundMessagesInternal();
    _bufferFlushInFlight = flushFuture;

    try {
      await flushFuture;
    } finally {
      if (identical(_bufferFlushInFlight, flushFuture)) {
        _bufferFlushInFlight = null;
      }
    }
  }

  Future<void> _flushBufferedOutboundMessagesInternal() async {
    final sdk = _chatSDK;
    if (sdk == null || _bufferedOutboundMessages.isEmpty) return;

    final batch = List<_BufferedOutboundMessage>.from(
      _bufferedOutboundMessages,
    );
    _bufferedOutboundMessages.clear();

    for (var index = 0; index < batch.length; index++) {
      final bufferedMessage = batch[index];
      final currentSdk = _chatSDK;
      if (currentSdk == null) {
        _bufferedOutboundMessages.insertAll(0, batch.skip(index));
        return;
      }

      try {
        await currentSdk.sendTextMessage(
          bufferedMessage.text,
          attachments: bufferedMessage.attachments,
        );
      } catch (error, stackTrace) {
        _bufferedOutboundMessages.insertAll(0, batch.skip(index));
        _logger.error(
          'Failed to flush buffered outbound message ${bufferedMessage.id}',
          error: error,
          stackTrace: stackTrace,
          name: _logKey,
        );
        return;
      }
    }
  }

  @override
  Future<({ChatAttachment attachment, Uint8List bytes})?>
  buildVoiceMessageAttachment({
    required String filePath,
    required String mediaType,
    required Duration duration,
    required List<int> waveform,
  }) async {
    if (!(_chatSDK?.capabilities.supports(ChatFeature.voiceMessages) ??
        false)) {
      throw AppException(
        'Voice messages are not supported on this chat transport.',
        code: AppExceptionType.voiceMessagesNotSupported.name,
      );
    }
    late final Uint8List bytes;
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _logger.warning('Voice message file missing', name: _logKey);
        return null;
      }

      bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        _logger.warning('Voice message file is empty', name: _logKey);
        return null;
      }
    } catch (e, st) {
      _logger.error(
        'Failed to read voice message file',
        error: e,
        stackTrace: st,
        name: _logKey,
      );
      return null;
    }

    final attachment = VoiceMessageMetadata.buildAttachment(
      id: const Uuid().v4(),
      base64: base64.encode(bytes),
      durationMs: duration.inMilliseconds,
      waveform: waveform,
      filename: path.basename(filePath),
      mediaType: mediaType,
      format: AudioAttachmentsPlugin.pluginName,
      lastModifiedTime: clock.now(),
      byteCount: bytes.length,
    );
    return (attachment: attachment, bytes: bytes);
  }

  @override
  Future<Uint8List> downloadMedia(ChatAttachment attachment) async {
    final sdk = _chatSDK;
    if (sdk == null) {
      throw AppException(
        'Chat SDK not initialized',
        code: AppExceptionType.chatSdkNotInitialized.name,
      );
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
    if (!_isGroupChat) {
      await _rCardManager.sendProfileUpdateWithRCard(message);
    }
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
  Future<void> deleteMessage(
    Message message, {
    bool deleteForMeOnly = false,
  }) async {
    if (!deleteForMeOnly &&
        !(_chatSDK?.capabilities.supports(ChatFeature.messageDelete) ??
            false)) {
      throw AppException(
        'Delete for everyone is not supported on this chat transport.',
        code: AppExceptionType.deleteForEveryoneNotSupported.name,
      );
    }
    await _chatSDK?.deleteMessage(message, localOnly: deleteForMeOnly);
  }

  @override
  Future<void> editTextMessage(Message message, String newText) async {
    await _chatSDK?.editTextMessage(message, newText);
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
        .resetContactBadgeCount(_otherPartyPermanentChannelDid);
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
      '[MessagesStream] Received event: ${data.event.runtimeType} '
      'chatItem=${data.chatItem.runtimeType}',
      name: _logKey,
    );

    await _router.route(data, channelDid);

    final chatItem = data.chatItem;
    if (chatItem != null) {
      // VRC request messages are protocol signals; they must not appear as
      // chat bubbles on either side of the conversation.
      final isVrcRequest =
          (data.event is ChatRequestIssuanceEvent ||
              data.event is ChatIssuedCredentialEvent) &&
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
        if (_missedCallManager != null) {
          unawaited(
            _missedCallManager!.healArrivedStaleCallItemIfPending(chatItem),
          );
        }
      }
      if (chatItem is Message &&
          _isHumanZkpActive &&
          LivenessZkpConciergeDeriver.messageHasZkpAttachments(chatItem)) {
        _syncHumanZkpNotices();
      }
    }

    _toggleChatLoading(false);
  }

  @override
  void upsertChatItem(ChatItem item) {
    final existing = state.messages;
    final idx = _indexOfChatItem(existing, item);
    if (idx != -1 && _shouldKeepExistingChatItem(existing[idx], item)) {
      _logger.info(
        'upsertChatItem: Keeping final call item ${item.messageId} over '
        'non-final stream update',
        name: _logKey,
      );
      return;
    }
    final prior = idx == -1 ? null : existing[idx];
    final messages = idx == -1
        ? existing.insertSorted(item)
        : existing.replaceItemAtIndex(idx, item);
    state = state.copyWith(messages: messages);
    _syncOpenCallActivityReadSeqNo(item);
    _maybeBumpMissedCallBadge(prior, item);
  }

  void _syncOpenCallActivityReadSeqNo(ChatItem item) {
    if (_isGroupChat || item is! Message || _callMetadataOf(item) == null) {
      return;
    }
    final contact = ref
        .read(contactsServiceProvider)
        .getContactByChannelDid(_otherPartyPermanentChannelDid);
    if (contact == null ||
        !ref.read(openChatRegistryProvider.notifier).isOpen(contact.id)) {
      return;
    }
    unawaited(
      ref
          .read(contactsServiceProvider.notifier)
          .syncOpenChannelReadSeqNo(_otherPartyPermanentChannelDid),
    );
  }

  /// Bumps the contact's unread badge once when a call chat item first reaches
  /// the `declined` status while the chat is not open, keyed by the call item
  /// message id so repeated terminal upserts of the same call count once.
  ///
  /// This owns the CALLER side: when the local user cancels an outgoing call,
  /// or the callee declines it, the call item transitions to `declined`
  /// locally, so leaving that chat surfaces a badge just as an open chat would
  /// show the call widget update. The recipient's missed call is badged by
  /// `IncomingCallService` instead (its `missed` item is often not synced at
  /// miss time), so `missed` is deliberately not badged here to avoid a
  /// double-count.
  void _maybeBumpMissedCallBadge(ChatItem? prior, ChatItem next) {
    if (_isGroupChat || next is! Message) return;
    final nextCall = _callMetadataOf(next);
    if (nextCall == null || nextCall.status != CallStatus.declined) return;

    final priorCall = prior is Message ? _callMetadataOf(prior) : null;
    if (priorCall != null && _isFinalCallStatus(priorCall.status)) return;

    unawaited(
      ref
          .read(contactsServiceProvider.notifier)
          .incrementMissedCallBadge(
            _otherPartyPermanentChannelDid,
            callId: next.messageId,
          ),
    );
  }

  /// Locates the slot [item] should occupy in [existing].
  ///
  /// Matches by `messageId` first. For call items it also matches by the
  /// shared `callId`, so an optimistic copy and its transport-confirmed copy
  /// (persisted under different ids) collapse into a single bubble instead of
  /// duplicating. Returns `-1` when [item] is new.
  int _indexOfChatItem(List<ChatItem> existing, ChatItem item) {
    final byId = existing.indexWhere((m) => m.messageId == item.messageId);
    if (byId != -1) return byId;

    if (item is! Message) return -1;
    final callId = _callMetadataOf(item)?.callId;
    if (callId == null || callId.isEmpty) return -1;

    return existing.indexWhere(
      (m) => m is Message && _callMetadataOf(m)?.callId == callId,
    );
  }

  /// Returns whether [existing] should win over a newer non-final call item.
  bool _shouldKeepExistingChatItem(ChatItem existing, ChatItem next) {
    if (existing is! Message || next is! Message) return false;

    final existingCall = _callMetadataOf(existing);
    final nextCall = _callMetadataOf(next);
    if (existingCall == null || nextCall == null) return false;

    return _isFinalCallStatus(existingCall.status) &&
        !_isFinalCallStatus(nextCall.status);
  }

  /// Returns the call metadata attachment carried by [message], if any.
  CallMetadata? _callMetadataOf(Message message) {
    for (final attachment in message.attachments) {
      if (!CallMetadata.isCall(attachment)) continue;
      return CallMetadata.maybeOf(attachment);
    }
    return null;
  }

  /// Returns whether [status] is terminal for a call chat item.
  bool _isFinalCallStatus(CallStatus status) {
    return status == CallStatus.missed ||
        status == CallStatus.declined ||
        status == CallStatus.ended;
  }

  String _peerFirstNameForZkpUi() {
    return _otherPartyFirstName?.isNotEmpty == true
        ? _otherPartyFirstName!
        : ref
                  .read(contactsServiceProvider)
                  .getContactByChannelDid(_otherPartyPermanentChannelDid)
                  ?.card
                  .firstName ??
              '';
  }

  String? _resolveGroupMemberName(String senderDid) =>
      state.getGroupMemberByDid(senderDid)?.contactCard.firstName;

  String _typingTimerKey(String? senderDid) =>
      _isGroupChat ? senderDid! : _oneToOneTypingKey;

  void _cancelTypingTimer(String timerKey) {
    _typingTimedActions[timerKey]?.cancel();
    _typingTimedActions.remove(timerKey);
  }

  List<ChatItem> _appendDerivedZkpNotices(List<ChatItem> existing) {
    if (!_isHumanZkpActive) return existing;

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
      groupMessageSenderName = _resolveGroupMemberName(senderDid);
    }

    if (!_isGroupChat) {
      contactName = _otherPartyFirstName?.isNotEmpty == true
          ? _otherPartyFirstName
          : ref
                .read(contactsServiceProvider)
                .getContactByChannelDid(_otherPartyPermanentChannelDid)
                ?.card
                .firstName;
    }

    _logger.info(
      '_onTypingMember called with senderDid: $senderDid, '
      'resolved name: ${groupMessageSenderName ?? contactName}',
      name: _logKey,
    );

    final timerKey = _typingTimerKey(senderDid);
    _cancelTypingTimer(timerKey);

    final timer = TypingTimer(
      memberName: groupMessageSenderName ?? contactName ?? '',
      maxVisible: _maxTypingMembersVisible,
      duration: Duration(seconds: secondsToShowChatActivityIndicator),
      getNames: () => state.membersTyping,
      setNames: (names) => state = state.copyWith(membersTyping: names),
      onExpired: () {
        _typingTimedActions.remove(timerKey);
        _logger.info('_onTypingMember onComplete', name: _logKey);
      },
    );
    _typingTimedActions[timerKey] = timer;
    timer.start();
    _logger.info(
      '_onTypingMember timer started for: '
      '${groupMessageSenderName ?? contactName}',
      name: _logKey,
    );
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

  @override
  Future<String?> sendOutgoingCallMessage({
    required CallMediaType mediaType,
    required String callId,
  }) => _callChatItemManager.sendOutgoingCallMessage(
    mediaType: mediaType,
    callId: callId,
    onSent: upsertChatItem,
  );

  @override
  Future<String?> resolveIncomingCallChatItemId({String? callId}) =>
      _callChatItemManager.resolveIncomingCallChatItemId(callId: callId);

  @override
  Future<String?> resolveOutgoingCallChatItemId({String? callId}) =>
      _callChatItemManager.resolveOutgoingCallChatItemId(callId: callId);

  @override
  Future<bool> markCallAsMissed({String? callId}) {
    if (_chatId == null || _missedCallManager == null) {
      return Future.value(false);
    }
    if (callId != null && callId.isNotEmpty) {
      return _callChatItemManager.markCallAsMissed(callId: callId);
    }
    return _missedCallManager!.reconcilePendingMissedCall();
  }

  @override
  Future<void> updateCallChatItem(
    String messageId, {
    required CallStatus status,
    Duration? duration,
    CallParticipation? participation,
  }) async {
    final updated = await _callChatItemManager.updateCallChatItem(
      messageId,
      status: status,
      duration: duration,
      participation: participation,
    );
    if (updated != null) upsertChatItem(updated);
  }

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
    // For group chats, senderDid is required to identify which member to remove
    if (_isGroupChat && (senderDid == null || senderDid.isEmpty)) return;

    final timerKey = _typingTimerKey(senderDid);
    _cancelTypingTimer(timerKey);

    final memberNames = [...state.membersTyping];
    if (memberNames.isEmpty) return;

    final groupMessageSenderName = _isGroupChat && senderDid != null
        ? _resolveGroupMemberName(senderDid)
        : null;

    String? contactName;
    if (!_isGroupChat) {
      contactName = _otherPartyFirstName?.isNotEmpty == true
          ? _otherPartyFirstName
          : ref
                .read(contactsServiceProvider)
                .getContactByChannelDid(_otherPartyPermanentChannelDid)
                ?.card
                .firstName;
    }

    memberNames.removeWhere(
      (name) => name == groupMessageSenderName || name == contactName,
    );
    state = state.copyWith(membersTyping: memberNames);
  }
}

class _BufferedOutboundMessage {
  const _BufferedOutboundMessage({
    required this.id,
    required this.text,
    required this.attachments,
  });

  final String id;
  final String text;
  final List<ChatAttachment> attachments;
}
