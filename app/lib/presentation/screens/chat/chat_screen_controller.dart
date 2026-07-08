import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;
import 'package:meeting_place_core/meeting_place_core.dart' hide ContactCard;
import 'package:meeting_place_credentials/meeting_place_credentials.dart'
    show VrcExchangeRole;
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';

import '../../../application/services/chat_service/chat_service.dart';
import '../../../application/services/chat_service/chat_session_service.dart';
import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../application/services/identities_service/identities_service.dart';
import '../../../application/services/voice_playback_service/voice_playback_service.dart';
import '../../../application/services/vrc_service/vrc_service.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_presence_status.dart';
import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/extensions/event_message_extensions.dart';
import '../../../infrastructure/helpers/timed_action.dart';
import '../../../infrastructure/plugins/audio_attachments_plugin/local_voice_attachment_store.dart';
import '../../../infrastructure/plugins/r_card_attachments_plugin/r_card_attachments_plugin.dart';
import '../../../infrastructure/plugins/vrc_attachments_plugin/vrc_attachments_plugin.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/available_attachment_plugins_provider.dart';
import '../../../infrastructure/providers/credentials_sdk_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/services/unsent_messages_service/unsent_messages_service.dart';
import '../../effects/screen_effect.dart';
import '../../validators/max_length_validator_type.dart';
import '../../widgets/async_loaders/async_loading_controller.dart';
import 'chat_screen_state.dart';
import 'chat_zkp/chat_zkp_message_list_policy.dart';
import 'chat_zkp_handler.dart';
import 'proof_flow_controller.dart';

part 'chat_screen_controller.g.dart';

@riverpod
/// Controller class for managing the state and logic of the chat screen.
///
/// Extends [_$ChatScreenController] to provide reactive state management
/// and business logic for chat-related features, such as handling messages,
/// user interactions, and UI updates within the chat screen.
class ChatScreenController extends _$ChatScreenController
    with WidgetsBindingObserver {
  ChatScreenController() : super();

  static const _logKey = 'UXCHAT';
  static final _maxChatMessageLength = MaxLengthValidatorType.extraLong.value;

  late final messageTextController = TextEditingController();
  late final _logger = ref.read(appLoggerProvider);
  late final _zkpHandler = ChatZkpHandler(
    ref: ref,
    logger: _logger,
    logKey: _logKey,
    isHumanZkpSupported: _isHumanZkpSupported,
    getContact: () => state.contact,
    onUpsertChatItem: _upsertChatItemThroughService,
  );

  bool _isHumanZkpSupported() =>
      ref.read(environmentProvider).zkpEnabled &&
      (state.capabilities?.supports(chat.ChatFeature.humanZkp) ?? false);

  TimedAction? _sendChatActivityTimedAction;
  Timer? _saveUnsentMessageDebouncer;
  bool _isPaused = false;
  late final _chatResumingLock = Lock();
  StreamSubscription<void>? _vrcPluginSubscription;
  StreamSubscription<Identity>? _rCardPluginSubscription;
  bool _rCardListenerSet = false;

  late final Map<String, ProviderSubscription<void>>
  _conciergeLoadingControllersSubscriptions = {};
  late final Map<
    String,
    NotifierProvider<AsyncLoadingController, AsyncValue<void>>
  >
  _conciergeLoadingControllers = {};

  ChatService? _chatService;

  Future<Uint8List> downloadAttachmentForPlugin(
    ChatAttachment attachment,
  ) async {
    final chatService = _chatService;
    if (chatService == null) {
      throw AppException(
        'Chat service not initialized',
        code: AppExceptionType.chatSdkNotInitialized.name,
      );
    }
    return chatService.downloadMedia(attachment);
  }

  @override
  ChatScreenState build(String contactId) {
    WidgetsBinding.instance.addObserver(this);

    final contact = ref.read(contactsServiceProvider).getContactById(contactId);
    final channelDid = contact?.channelDid;
    var pendingState = ChatScreenState(
      contact: contact,
      isActive: true,
      isInitialized: false,
      contactPresenceStatus: ContactPresenceStatus.unknown,
    );
    var hasInitializedState = false;

    if (channelDid != null) {
      final chatSessionProvider = chatSessionServiceProvider(channelDid);
      final sessionService = ref.read(chatSessionProvider.notifier);
      _chatService = sessionService;
      ref.listen(chatSessionProvider, (previous, next) {
        Future.microtask(() {
          if (hasInitializedState) {
            pendingState = state;
          }

          var newEffect = pendingState.effect;
          if (next.effect != null && previous?.effect != next.effect) {
            newEffect = _mapEffect(next.effect!);
          } else if (next.effect == null) {
            newEffect = null;
          }

          final zkpAttachmentEvent = next.zkpAttachmentEvent;
          if (zkpAttachmentEvent != null &&
              previous?.zkpAttachmentEvent != zkpAttachmentEvent) {
            _zkpHandler.handleZkpAttachment(
              zkpAttachmentEvent.chatItem,
              zkpAttachmentEvent.channelDid,
            );
          }

          // Auto-hide the VRC banner when the peer's request concierge arrives.
          final hasVrcRequestConcierge = next.messages.any(
            (m) =>
                m is chat.ConciergeMessage &&
                m.conciergeType ==
                    chat.ConciergeMessageType.fromJson(
                      'permissionToVerifyRelationship',
                    ),
          );
          final wasAlreadyPresent =
              previous?.messages.any(
                (m) =>
                    m is chat.ConciergeMessage &&
                    m.conciergeType ==
                        chat.ConciergeMessageType.fromJson(
                          'permissionToVerifyRelationship',
                        ),
              ) ??
              false;
          final shouldHideBanner =
              hasVrcRequestConcierge &&
              !wasAlreadyPresent &&
              pendingState.shouldShowVrcBanner;

          final hasVrcExchangeInitiated = next.messages.any(
            (m) =>
                m is chat.EventMessage &&
                m.eventType ==
                    chat.EventMessageType.fromJson('vrcExchangeInitiated'),
          );
          final hasVrcExchangeDoLater = next.messages.any(
            (m) =>
                m is chat.EventMessage &&
                m.eventType ==
                    chat.EventMessageType.fromJson('vrcExchangeDoLater'),
          );
          final hasVrcExchangeCompleted = next.messages.any(
            (m) =>
                m is chat.EventMessage &&
                m.eventType ==
                    chat.EventMessageType.fromJson('vrcExchangeCompleted'),
          );

          final messages = ref
              .read(localVoiceAttachmentStoreProvider)
              .withLocalVoiceMetadata(next.messages);

          pendingState = pendingState.copyWith(
            messages: messages,
            membersTyping: next.membersTyping,
            contactPresenceStatus: next.contactPresenceStatus,
            isActive: next.isActive,
            isInitialized: next.isInitialized,
            group: next.group ?? pendingState.group,
            otherPartyCard: next.otherPartyCard ?? pendingState.otherPartyCard,
            effect: newEffect,
            shouldShowVrcBanner:
                (shouldHideBanner ||
                    hasVrcExchangeInitiated ||
                    hasVrcExchangeDoLater)
                ? false
                : pendingState.shouldShowVrcBanner,
            shouldEnableVrcAttachment:
                (hasVrcExchangeInitiated || hasVrcExchangeCompleted)
                ? false
                : pendingState.shouldEnableVrcAttachment,
          );

          if (hasInitializedState) {
            state = pendingState;
          }
        });
      }, fireImmediately: true);

      if (!_rCardListenerSet) {
        _rCardListenerSet = true;
        final plugins = ref.read(availableAttachmentPluginsProvider);
        final rCardPlugin = plugins
            .whereType<RCardAttachmentsPlugin>()
            .firstOrNull;
        _rCardPluginSubscription = rCardPlugin?.onRCardFromAttachment.listen((
          identity,
        ) {
          unawaited(_chatService?.sendRCardFromPlugin(identity));
        });
      }
    }

    ref.listen(
      contactsServiceProvider.select(
        (state) => state.getContactById(contactId),
      ),
      (previous, next) {
        if (next == null) return;
        Future.microtask(() {
          if (!ref.mounted) return;
          state = state.copyWith(contact: next);
        });
      },
      fireImmediately: true,
    );

    messageTextController.addListener(_onMessageTextChanged);
    _subscribeToVrcPlugin();

    final voicePlaybackController = ref.read(
      voicePlaybackServiceProvider(contactId).notifier,
    );

    ref.onDispose(() {
      _vrcPluginSubscription?.cancel();
      _rCardPluginSubscription?.cancel();
      _sendChatActivityTimedAction?.cancel();
      _saveUnsentMessageDebouncer?.cancel();

      messageTextController.removeListener(_onMessageTextChanged);
      messageTextController.dispose();

      _disposeConciergeLoadingControllers();

      voicePlaybackController.disposePlaybackResources();

      _logger.info('Chat session ended', name: _logKey);

      WidgetsBinding.instance.removeObserver(this);
    });

    hasInitializedState = true;
    return pendingState;
  }

  ScreenEffect? _mapEffect(chat.Effect effect) {
    switch (effect) {
      case chat.Effect.confetti:
        return ScreenEffect.confetti();
      case chat.Effect.balloons:
        return ScreenEffect.balloons();
      case chat.Effect.fireworks:
      case chat.Effect.hearts:
        return null;
    }
  }

  Future<void>? initializing;

  /// Initializes the chat screen controller.
  ///
  /// This method performs any necessary setup or data loading required
  /// before the chat screen can be used. It should be called before
  /// interacting with the controller's functionality.
  ///
  /// Returns a [Future] that completes when initialization is finished.
  Future<void> initialize() async {
    initializing ??= loadContact(contactId);

    await initializing;
  }

  Future<void> onScreenOpened() async {
    if (!state.isInitialized) return;

    if (_isHumanZkpSupported()) {
      ref.read(proofFlowControllerProvider(contactId).notifier).resetSession();
    }

    await _restoreUnsentMessage();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!ref.mounted) return;

    _logger.info('didChangeAppLifecycleState: $state', name: _logKey);
    switch (state) {
      case AppLifecycleState.resumed:
        _chatResumingLock.synchronized(() async {
          if (!ref.mounted) return;
          await _resumeChatSession();
        });
        break;
      case AppLifecycleState.paused:
        _chatResumingLock.synchronized(() async {
          if (!ref.mounted) return;
          await _pauseChatSession();
        });
        break;
      default:
        break;
    }
  }

  Future<void> _resumeChatSession() async {
    if (!ref.mounted) return;
    if (!_isPaused) return;

    _logger.info('Resuming chat session', name: _logKey);
    final contact = state.contact;
    if (contact == null) return;

    final channelDid = contact.channelDid;
    if (channelDid == null) return;

    try {
      await _chatService?.startChatSession();
      if (!ref.mounted) return;
      _isPaused = false;
    } catch (e, st) {
      _logger.error(
        'Failed to resume chat session',
        error: e,
        stackTrace: st,
        name: _logKey,
      );
    }
  }

  Future<void> _pauseChatSession() async {
    if (_isPaused) return;

    _logger.info('Pausing chat session', name: _logKey);
    _isPaused = true;
    await _chatService?.pauseChat();
  }

  void _onMessageTextChanged() {
    _saveUnsentMessageDebouncer?.cancel();

    final contact = state.contact;
    if (contact == null) return;

    _saveUnsentMessageDebouncer = Timer(const Duration(milliseconds: 500), () {
      final text = messageTextController.text;
      ref
          .read(unsentMessagesServiceProvider.notifier)
          .saveUnsentMessage(contact.id, text.isEmpty ? null : text);
    });
  }

  void _disposeConciergeLoadingControllers() {
    for (final entry in _conciergeLoadingControllersSubscriptions.entries) {
      entry.value.close();
    }
  }

  NotifierProvider<AsyncLoadingController, AsyncValue<void>>
  _addConciergeSubscriptionIfNeeded(String id) {
    var existing = _conciergeLoadingControllers[id];
    if (existing == null) {
      existing = AsyncLoadingController.provider(id);
      _conciergeLoadingControllers[id] = existing;
      _conciergeLoadingControllersSubscriptions[id] = ref.listen(
        existing,
        (prev, next) {},
      );
    }
    return existing;
  }

  NotifierProvider<AsyncLoadingController, AsyncValue<void>>
  conciergeApproveLoadingController(chat.ConciergeMessage message) {
    return _addConciergeSubscriptionIfNeeded('approve_${message.messageId}');
  }

  NotifierProvider<AsyncLoadingController, AsyncValue<void>>
  conciergeRejectLoadingController(chat.ConciergeMessage message) {
    return _addConciergeSubscriptionIfNeeded('reject_${message.messageId}');
  }

  NotifierProvider<AsyncLoadingController, AsyncValue<void>>
  conciergeSendProfileLoadingController(chat.ConciergeMessage message) {
    return _addConciergeSubscriptionIfNeeded(
      'send_profile_${message.messageId}',
    );
  }

  NotifierProvider<AsyncLoadingController, AsyncValue<void>>
  conciergeAskLaterToSendProfileLoadingController(
    chat.ConciergeMessage message,
  ) {
    return _addConciergeSubscriptionIfNeeded(
      'ask_later_send_profile_${message.messageId}',
    );
  }

  NotifierProvider<AsyncLoadingController, AsyncValue<void>>
  conciergeCancelSendProfileLoadingController(chat.ConciergeMessage message) {
    return _addConciergeSubscriptionIfNeeded(
      'cancel_send_profile_${message.messageId}',
    );
  }

  /// Loads the contact details for the given [contactId].
  ///
  /// This method asynchronously fetches and initializes the contact information
  /// associated with the provided [contactId]. It may update the state of the
  /// chat screen to reflect the loaded contact's data.
  ///
  /// Throws an exception if the contact cannot be loaded.
  Future<void> loadContact(String contactId) async {
    await ref.read(contactsServiceProvider.notifier).ensureInitialized();
    await ref.read(identitiesServiceProvider.notifier).ensureInitialized();

    final contact = ref.read(contactsServiceProvider).getContactById(contactId);
    if (contact == null) {
      throw AppException(
        'Unable to find contact with identifier $contactId',
        code: AppExceptionType.missingContact.name,
      );
    }

    state = state.copyWith(contact: contact);

    final channelDid = contact.channelDid;
    if (channelDid == null) {
      throw AppException(
        'Contact has not been associated to any channels',
        code: AppExceptionType.missingChannel.name,
      );
    }
    _logger.info('ChannelID: $channelDid', name: _logKey);

    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
      channelDid,
    );
    if (channel == null) {
      throw AppException(
        'Unable to find channel associated to contact',
        code: AppExceptionType.missingChannel.name,
      );
    }
    final srcCard = channel.otherPartyContactCard;
    final ownCard = channel.contactCard;
    final ownIdentity = ref
        .read(identitiesServiceProvider)
        .getIdentityById(channel.externalRef);
    state = state.copyWith(
      otherPartyCard: srcCard == null
          ? null
          : ContactCardUtils.fromSdkContactCard(srcCard),
      myCard:
          ownIdentity?.card ??
          (ownCard == null
              ? null
              : ContactCardUtils.fromSdkContactCard(ownCard)),
      notificationToken: channel.otherPartyNotificationToken,
      myDid: channel.permanentChannelDid,
    );

    final lastKeepAliveMessage = contact.lastKeepAliveMessage;
    if (lastKeepAliveMessage != null) {
      _chatService?.onPresenceUpdated(lastKeepAliveMessage);
    }

    await _chatService?.updateContactSequenceNumber(channelDid);
    await _chatService?.startChatSession();
    final capabilities = _chatService?.capabilities;
    state = state.copyWith(
      capabilities: capabilities,
      isCallSupported:
          coreSdk.isCallSupported &&
          (capabilities?.supports(chat.ChatFeature.audioVideoCalling) ?? false),
    );

    if (channel.type == sdk.ChannelType.group) {
      final group = await coreSdk.getGroupByOfferLink(channel.offerLink);
      final connection = await coreSdk.getConnectionOffer(channel.offerLink);
      state = state.copyWith(group: group, offerName: connection?.offerName);
    } else if (channel.type == ChannelType.individual) {
      final hasVrc = await ref
          .read(vrcServiceProvider.notifier)
          .hasVrcInChannel(channelDid);
      final hasVrcExchangeInitiated = state.hasVrcExchangeInitiated;
      final hasVrcExchangeDoLater = state.hasVrcExchangeDoLater;
      final hasVrcRequestReceived = state.hasVrcRequestReceived;
      final hasPendingVrcConcierge = state.hasPendingVrcConcierge;
      final suppressBanner =
          hasVrc ||
          hasVrcExchangeInitiated ||
          hasVrcExchangeDoLater ||
          hasPendingVrcConcierge;
      final shouldEnableAttachment =
          !hasVrc &&
          !hasVrcExchangeInitiated &&
          (!hasPendingVrcConcierge ||
              hasVrcRequestReceived ||
              hasVrcExchangeDoLater);
      state = state.copyWith(
        shouldShowVrcBanner: !suppressBanner,
        shouldEnableVrcAttachment: shouldEnableAttachment,
      );
    }

    _hideActivity();
  }

  /// Insert a ZKP paused notice into the chat (local only, not sent)
  Future<void> insertZkpPausedNotice({String? pausedForNoticeMessageId}) async {
    await _zkpHandler.insertZkpPausedNotice(
      pausedForNoticeMessageId: pausedForNoticeMessageId,
    );
  }

  Future<void> pauseHumanZkpRequestFlow() async {
    await ref
        .read(proofFlowControllerProvider(contactId).notifier)
        .sendDeclined();
    final requestNoticeId =
        ChatZkpMessageListPolicy.latestHumanZkpRequestNoticeMessageId(
          state.messages,
        );
    await insertZkpPausedNotice(pausedForNoticeMessageId: requestNoticeId);
  }

  /// Routes a chat item through the service to persist it in the service state.
  /// This ensures ZKP notices survive ref.listen state overwrites.
  void _upsertChatItemThroughService(chat.ChatItem item) {
    final service = _chatService;
    if (service == null) {
      _logger.warning(
        'Skipping ZKP notice upsert: chat service not initialized yet',
        name: _logKey,
      );
      return;
    }
    service.upsertChatItem(item);
  }

  Future<void> _updateGroupContactPendingStatus() async {
    final contact = state.contact;
    final group = state.group;
    if (contact == null) return;
    if (group == null) return;

    final refreshedGroup = await _chatService?.refreshGroup(group.id) ?? group;
    await _chatService?.updateGroupContactPendingStatus(
      contact,
      refreshedGroup,
    );
  }

  /// Sends a text message to the chat.
  ///
  /// The message text is trimmed and validated before sending.
  /// Clears the input field upon successful send.
  Future<void> sendMessage() async {
    final originalText = messageTextController.text;
    final trimmedMessage = originalText.trimRight();
    if (trimmedMessage.isEmpty) return;
    if (trimmedMessage.length > _maxChatMessageLength) return;

    unawaited(_chatService?.sendTextMessage(trimmedMessage) ?? Future.value());
    _sendChatActivityTimedAction?.cancel();
    messageTextController.clear();
  }

  /// Sends a message directly with optional attachments
  Future<void> sendMessageDirect(
    String message, {
    List<ChatAttachment>? attachments,
  }) async {
    final trimmedMessage = message.trimRight();
    // Allow empty messages if attachments are present
    if (trimmedMessage.isEmpty &&
        (attachments == null || attachments.isEmpty)) {
      return;
    }

    await (_chatService?.sendTextMessage(
          trimmedMessage,
          attachments: attachments,
        ) ??
        Future<void>.value());
  }

  Future<void> sendChatActivity() async {
    _sendChatActivityTimedAction ??= TimedAction(
      onRun: (args) async {
        await _chatService?.sendChatActivity();
      },
      // NOTE: Subtracting 1 second from this time, so that there is overlap
      duration: Duration(
        seconds: (_chatService?.secondsToShowChatActivityIndicator ?? 10) - 1,
      ),
    );
    _sendChatActivityTimedAction?.start();
  }

  /// Clears the currently selected reaction in the chat screen.
  ///
  /// This method resets any reaction that has been selected by the user,
  /// typically used to update the UI and internal state after a reaction
  /// has been processed or cancelled.
  void clearSelectedReaction() {
    if (state.selectedReactionIndex == -1) return;
    state = state.copyWith(selectedReactionIndex: -1);
  }

  /// Selects a reaction at the specified [index] in the list of available
  /// reactions.
  ///
  /// This method updates the current selection to the reaction at the
  /// given [index].
  /// Typically used to handle user interaction when choosing a reaction in
  /// the chat UI.
  ///
  /// [index] The position of the reaction to select.
  void selectReactionAtIndex(int index) {
    state = state.copyWith(selectedReactionIndex: index);
  }

  /// Rejects a membership request represented by the given [chatItem].
  ///
  /// This method performs the necessary actions to reject a membership,
  /// such as updating the chat state or notifying relevant parties.
  ///
  /// [chatItem] The concierge message containing membership request details.
  ///
  /// Returns a [Future] that completes when the rejection process is finished.
  Future<void> rejectMembership(chat.ConciergeMessage chatItem) async {
    try {
      _showActivity();
      await ref.read(conciergeRejectLoadingController(chatItem).notifier).start(
        () async {
          _logger.info(
            '''Rejecting membership for messageId: ${chatItem.messageId}''',
            name: _logKey,
          );
          await _chatService?.rejectConnectionRequest(chatItem);
          await _updateGroupContactPendingStatus();
        },
      );
    } finally {
      _hideActivity();
    }
  }

  Future<void> approveMembership(chat.ConciergeMessage chatItem) async {
    try {
      _showActivity();

      final contact = state.contact;
      if (contact == null) return;

      await ref
          .read(conciergeApproveLoadingController(chatItem).notifier)
          .start(() async {
            _logger.info(
              '''Approving membership for messageId: ${chatItem.messageId}''',
              name: _logKey,
            );
            await _chatService?.approveConnectionRequest(chatItem);
            await _updateGroupContactPendingStatus();
          });
    } finally {
      _hideActivity();
    }
  }

  /// Sends an update containing contact details as a concierge message.
  ///
  /// This method takes a [chat.ConciergeMessage] object representing the
  /// contact details update and performs the necessary actions to send it.
  ///
  /// Throws an exception if the update fails.
  ///
  /// [message]: The concierge message containing the contact details to be
  /// updated.
  Future<void> sendContactDetailsUpdate(chat.ConciergeMessage message) async {
    final profileLoadingController = ref.read(
      conciergeSendProfileLoadingController(message).notifier,
    );

    await profileLoadingController.start(() async {
      _logger.info(
        '''Sending contact details update for messageId: ${message.messageId}''',
        name: _logKey,
      );
      await _chatService?.sendChatContactDetailsUpdate(message);
    });
  }

  /// Prompts the user at a later time to send updated contact details.
  ///
  /// This method can be used to defer the action of sending contact details
  /// update, allowing the user to be reminded or asked again in the future.
  ///
  /// Returns a [Future] that completes when the operation is finished.
  Future<void> askMeLaterToSendContactDetailsUpdate(
    chat.ConciergeMessage message,
  ) async {
    await ref
        .read(conciergeAskLaterToSendProfileLoadingController(message).notifier)
        .start(() async {
          _logger.info(
            '''Hiding profile update message till later for messageId: ${message.messageId}''',
            name: _logKey,
          );
          final msgs = List.of(state.messages)
            ..removeWhere((m) => m.messageId == message.messageId);
          state = state.copyWith(messages: msgs);
        });
  }

  /// Cancels the ongoing process of updating contact details.
  ///
  /// This method should be called to abort any changes made to the contact
  /// details before they are saved or finalized. It ensures that the contact
  /// details remain unchanged if the update process is interrupted or
  /// cancelled.
  Future<void> cancelUpdatingContactDetails(
    chat.ConciergeMessage message,
  ) async {
    await ref
        .read(conciergeCancelSendProfileLoadingController(message).notifier)
        .start(() async {
          _logger.info(
            '''Decided to not send profile update message for messageId: ${message.messageId}''',
            name: _logKey,
          );
          await _chatService?.rejectChatContactDetailsUpdate(message);
        });
  }

  /// Sets a reaction for a specific message.
  ///
  /// Takes the [messageId] of the message to react to and the [reaction] string
  /// representing the reaction (e.g., emoji or text).
  ///
  /// This method performs the operation asynchronously.
  Future<void> setMessageReaction(String messageId, String reaction) async {
    try {
      _showActivity();
      final message =
          state.messages.firstWhereOrNull((m) => m.messageId == messageId)
              as chat.Message?;

      if (message == null) {
        throw AppException(
          'Unable to find message with id $messageId',
          code: AppExceptionType.missingMessage.name,
        );
      }

      await _chatService?.reactOnMessage(message, reaction: reaction);
    } finally {
      _hideActivity();
    }
  }

  /// Maximum age at which the original sender can still delete their own
  /// message for everyone. Defers to the chat service (SDK option, falling
  /// back to the environment-configured default before the SDK is ready).
  Duration get deleteMessageWindow =>
      _chatService?.deleteMessageWindow ?? Duration.zero;

  /// Deletes a previously-sent message.
  ///
  /// When [deleteForMeOnly] is true the message is hidden only for the current
  /// user and no wire traffic is generated. Otherwise the SDK broadcasts a
  /// redaction so all participants drop the message, subject to the
  /// sender-only / delivery / `deleteMessageWindow` rules enforced by the SDK.
  Future<void> deleteMessage(
    String messageId, {
    bool deleteForMeOnly = false,
  }) async {
    try {
      _showActivity();
      final message =
          state.messages.firstWhereOrNull((m) => m.messageId == messageId)
              as chat.Message?;

      if (message == null) {
        throw AppException(
          'Unable to find message with id $messageId',
          code: AppExceptionType.missingMessage.name,
        );
      }

      await _chatService?.deleteMessage(
        message,
        deleteForMeOnly: deleteForMeOnly,
      );
    } finally {
      _hideActivity();
    }
  }

  Future<void> editTextMessage(String messageId, String newText) async {
    final idx = state.messages.indexWhere((m) => m.messageId == messageId);
    final message = idx == -1 ? null : state.messages[idx] as chat.Message?;

    if (message == null) {
      throw AppException(
        'Unable to find message with id $messageId',
        code: AppExceptionType.missingMessage.name,
      );
    }

    await _chatService?.editTextMessage(message, newText);
  }

  /// Sends a [ScreenEffect] to the chat screen.
  ///
  /// This method handles the logic for triggering a visual or interactive
  /// effect on the chat screen, such as animations or notifications.
  /// The specific behavior depends on the implementation of [ScreenEffect].
  ///
  /// [effect] - The effect to be sent to the chat screen.
  ///
  /// Returns a [Future] that completes when the effect has been processed.
  Future<void> sendEffect(ScreenEffect effect) async {
    try {
      _showActivity();
      await _chatService?.sendEffect(effect.type);
    } finally {
      _hideActivity();
    }
  }

  /// Clears any currently set effect in the chat screen controller.
  ///
  /// This method resets the effect state, typically used to remove
  /// temporary UI effects or notifications after they have been handled.
  void clearEffect() {
    _chatService?.clearEffect();
  }

  void _showActivity() {
    state = state.copyWith(isActive: true);
  }

  void _hideActivity() {
    state = state.copyWith(isActive: false);
  }

  /// Sends an attachment in the chat.
  ///
  /// This method handles the process of sending an attachment, such as an
  /// image or file, to the chat. It performs necessary validations and updates
  /// the chat state accordingly.
  ///
  /// Returns a [Future] that completes when the attachment has been sent.
  Future<void> sendAttachment(
    String text,
    List<MessageAttachment> messageAttachment,
  ) async {
    final supportsImages =
        state.capabilities?.supports(chat.ChatFeature.imageAttachments) ??
        false;
    final supportsVideos =
        state.capabilities?.supports(chat.ChatFeature.videoAttachments) ??
        false;
    final supportsMedia = supportsImages || supportsVideos;
    if (!supportsMedia) {
      _logger.warning(
        'Media attachments are not supported on this chat transport; '
        'dropping send request.',
        name: _logKey,
      );
      return;
    }
    messageTextController.clear();
    unawaited(
      _chatService?.sendTextMessage(
        text,
        attachments: messageAttachment.map((a) => a.toAttachment()).toList(),
      ),
    );
    _sendChatActivityTimedAction?.cancel();
  }

  /// Loads an image attachment into the chat screen.
  ///
  /// This method handles the process of displaying or processing an image
  /// attachment provided by the [attachment] parameter. It may involve
  /// updating the UI, storing the attachment, or triggering further actions
  /// related to the image.
  ///
  /// [attachment] - The image attachment to be loaded.
  void loadImageAttachment(ChatAttachment attachment) {
    final attachmentId = attachment.id;

    final attachmentData = attachment.data?.base64;
    if (attachmentData == null) {
      _logger.info(
        'Attachment cannot be displayed as it does not have data',
        name: _logKey,
      );
      return;
    }

    final attachmentsDataCache = Map.of(state.attachmentsDataCache);
    final existingData = attachmentsDataCache[attachmentId];
    if (existingData != null) return;

    attachmentsDataCache[attachmentId] = base64.decode(attachmentData);
    state = state.copyWith(attachmentsDataCache: attachmentsDataCache);
  }

  /// Records and sends a voice message: builds the attachment, caches the
  /// recording locally so the sender can replay it immediately, then sends it.
  Future<bool> sendVoiceMessage({
    required String filePath,
    required String mediaType,
    required Duration duration,
    required List<int> waveform,
  }) async {
    messageTextController.clear();
    _sendChatActivityTimedAction?.cancel();

    final chatService = _chatService;
    if (chatService == null) {
      _logger.warning('Chat service unavailable', name: _logKey);
      return false;
    }

    final voiceMessage = await chatService.buildVoiceMessageAttachment(
      filePath: filePath,
      mediaType: mediaType,
      duration: duration,
      waveform: waveform,
    );
    if (voiceMessage == null) return false;

    final localVoiceStore = ref.read(localVoiceAttachmentStoreProvider);
    localVoiceStore.cacheLocalVoiceMessage(
      voiceMessage.attachment,
      voiceMessage.bytes,
      durationMs: duration.inMilliseconds,
      waveform: waveform,
    );

    try {
      await chatService.sendTextMessage(
        '',
        attachments: [voiceMessage.attachment],
      );
      return true;
    } catch (e, st) {
      localVoiceStore.removeLocalVoiceMessage(voiceMessage.attachment);
      _logger.error(
        'Failed to send voice message',
        error: e,
        stackTrace: st,
        name: _logKey,
      );
      return false;
    }
  }

  Future<void> toggleVoicePlayback({
    required String clipId,
    Uint8List? bytes,
    String? filePath,
    String? mediaType,
    Duration initialDuration = Duration.zero,
  }) {
    return ref
        .read(voicePlaybackServiceProvider(contactId).notifier)
        .toggle(
          clipId: clipId,
          bytes: bytes,
          filePath: filePath,
          mediaType: mediaType,
          initialDuration: initialDuration,
        );
  }

  Future<void> stopVoicePlayback() {
    return ref.read(voicePlaybackServiceProvider(contactId).notifier).stop();
  }

  void disposeVoicePlaybackResources() {
    ref
        .read(voicePlaybackServiceProvider(contactId).notifier)
        .disposePlaybackResources();
  }

  ProviderListenable<bool> voicePlaybackIsPlaying(String clipId) {
    return voicePlaybackServiceProvider(contactId).isPlaying(clipId);
  }

  ProviderListenable<double> voicePlaybackProgress(String clipId) {
    return voicePlaybackServiceProvider(contactId).progress(clipId);
  }

  ProviderListenable<Duration> voicePlaybackDuration(
    String clipId,
    Duration fallback,
  ) {
    return voicePlaybackServiceProvider(contactId).duration(clipId, fallback);
  }

  String voiceClipId(String attachmentCacheKey) =>
      VoicePlaybackService.clipId(contactId, attachmentCacheKey);

  Future<void> _restoreUnsentMessage() async {
    final contact = state.contact;
    if (contact == null) return;

    final unsentMessage = await _chatService?.restoreUnsentMessage(contact.id);
    if (unsentMessage != null) {
      messageTextController.text = unsentMessage;
    }
  }

  Future<void> dismissNotificationBanner() async {
    final contact = state.contact;
    if (contact == null) return;

    final updatedContact = contact.copyWith(notificationBannerDismissed: true);
    await ref
        .read(contactsServiceProvider.notifier)
        .updateContact(updatedContact);
  }

  Future<void> selectIdentityAndApproveVrcExchange({
    required Identity identity,
    required VrcExchangeRole role,
  }) async {
    try {
      final credentialsSdk = await ref.read(credentialsSdkProvider.future);

      if (role == VrcExchangeRole.initiator) {
        final channelDid = state.contact?.channelDid;
        if (channelDid == null) return;
        await credentialsSdk.requestVrcExchange(
          channelDid: channelDid,
          identityDid: identity.did,
          identityName: identity.card.displayName,
        );
        state = state.copyWith(
          shouldShowVrcBanner: false,
          shouldEnableVrcAttachment: false,
        );
        await _chatService?.persistLocalEventMessage(
          chat.EventMessageType.fromJson('vrcExchangeInitiated'),
          data: {
            'identityDid': identity.did,
            'identityName': identity.card.displayName,
          },
        );
      } else {
        final peerIdentityDid = state.vrcRequestIdentityDid ?? '';
        final peerIdentityName = state.vrcRequestIdentityName ?? '';
        final channelDid = state.contact?.channelDid;
        if (channelDid == null) return;
        final sentVcBlob = await credentialsSdk.sendVrc(
          channelDid: channelDid,
          issuerDid: identity.did,
          issuerName: identity.card.displayName,
          peerDid: peerIdentityDid,
          peerName: peerIdentityName,
        );
        if (sentVcBlob.isNotEmpty) {
          final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
          final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
            channelDid,
          );
          final senderDid = channel?.permanentChannelDid;
          if (senderDid == null || senderDid.isEmpty) return;
          await _chatService?.showSentVrcAttachment(
            vcBlob: sentVcBlob,
            senderDid: senderDid,
          );
        }
        await _chatService?.dismissVrcConciergeMessages();

        state = state.copyWith(
          shouldEnableVrcAttachment: false,
          shouldShowVrcBanner: false,
        );
      }
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to approve VRC exchange',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }

  Future<void> doLaterVrcExchangeFromConcierge() async {
    await _chatService?.dismissVrcConciergeMessages();
    state = state.copyWith(
      shouldShowVrcBanner: false,
      shouldEnableVrcAttachment: true,
    );
    await _chatService?.persistLocalEventMessage(
      chat.EventMessageType.fromJson('vrcExchangeDoLater'),
    );
  }

  Future<void> doLaterVrcExchangeFromBanner() async {
    await _chatService?.persistLocalEventMessage(
      chat.EventMessageType.fromJson('vrcExchangeDoLater'),
    );
    state = state.copyWith(
      shouldShowVrcBanner: false,
      shouldEnableVrcAttachment: true,
    );
  }

  void resetShouldStartVrcExchangeFromAttachment() {
    state = state.copyWith(shouldStartVrcExchangeFromAttachment: false);
  }

  void _subscribeToVrcPlugin() {
    _vrcPluginSubscription?.cancel();
    final plugins = ref.read(availableAttachmentPluginsProvider);
    final vrcPlugin = plugins.whereType<VrcAttachmentsPlugin>().firstOrNull;
    _vrcPluginSubscription = vrcPlugin?.onPick.listen((_) {
      state = state.copyWith(shouldStartVrcExchangeFromAttachment: true);
    });
  }
}

extension ChatScreenControllerProviderSelectors
    on ChatScreenControllerProvider {
  ProviderListenable<String> get navigationBarTitle {
    return select((state) {
      if (state.contact != null &&
          (state.contact?.displayName?.isNotEmpty ?? false)) {
        return state.contact?.displayName ?? '';
      }

      if (state.isGroupChat) {
        return state.offerName ?? '';
      }

      return state.otherPartyCard?.firstName ??
          state.contact?.card.firstName ??
          '';
    });
  }

  ProviderListenable<bool> get isGroupChat {
    return select((state) => state.isGroupChat);
  }

  ProviderListenable<String?> get otherPartyName {
    return select((state) {
      if (state.contact?.isGroup ?? false) return null;

      return state.otherPartyCard?.firstName ?? state.contact?.card.firstName;
    });
  }

  ProviderListenable<int> get indexOfLastMessageFromMe {
    return select(
      (state) => state.messages.indexWhere((message) => message.isFromMe),
    );
  }

  ProviderListenable<List<String>> get awaitingMemberNames {
    return select((state) {
      final awaitingMembers = state.messages
          .whereType<chat.EventMessage>()
          .where(
            (message) =>
                message.eventType ==
                    chat.EventMessageType.awaitingGroupMemberToJoin &&
                message.status == chat.ChatItemStatus.received,
          );

      final memberDidsWhoLeft = state.messages
          .whereType<chat.EventMessage>()
          .where(
            (message) =>
                message.eventType == chat.EventMessageType.groupMemberLeftGroup,
          )
          .map((message) => message.memberDid)
          .where((did) => did != null)
          .toSet();

      final awaitingMemberNames = awaitingMembers
          .where((message) => !memberDidsWhoLeft.contains(message.memberDid))
          .map((message) => message.contactCard?.firstName)
          .where((firstName) => firstName != null)
          .cast<String>();

      return awaitingMemberNames.toList();
    });
  }

  ProviderListenable<bool> get isGroupDeleted {
    return select((state) => state.isGroupDeleted);
  }

  ProviderListenable<bool> get shouldShowProgress {
    return select(
      (state) =>
          state.isActive ||
          state.messages.any(
            (message) => message.status == chat.ChatItemStatus.queued,
          ),
    );
  }

  ProviderListenable<bool> get shouldDisable {
    return select(
      (state) =>
          !state.isInitialized ||
          state.isGroupDeleted ||
          state.isRemovedFromGroup,
    );
  }

  ProviderListenable<bool> get supportsVideos {
    return select(
      (state) =>
          state.capabilities?.supports(chat.ChatFeature.videoAttachments) ??
          false,
    );
  }

  ProviderListenable<bool> get supportsMedia {
    return select(
      (state) =>
          (state.capabilities?.supports(chat.ChatFeature.imageAttachments) ??
              false) ||
          (state.capabilities?.supports(chat.ChatFeature.videoAttachments) ??
              false),
    );
  }

  ProviderListenable<bool> get supportsImages {
    return select(
      (state) =>
          state.capabilities?.supports(chat.ChatFeature.imageAttachments) ??
          false,
    );
  }

  ProviderListenable<bool> get supportsVoiceMessages {
    return select(
      (state) =>
          state.capabilities?.supports(chat.ChatFeature.voiceMessages) ?? false,
    );
  }

  ProviderListenable<bool> get supportsMessageDelete {
    return select(
      (state) =>
          state.capabilities?.supports(chat.ChatFeature.messageDelete) ?? false,
    );
  }

  ProviderListenable<bool> get supportsMessageEdit {
    return select(
      (state) =>
          state.capabilities?.supports(chat.ChatFeature.messageEdit) ?? false,
    );
  }

  ProviderListenable<bool> get supportsPresence {
    return select(
      (state) =>
          state.capabilities?.supports(chat.ChatFeature.presence) ?? false,
    );
  }
}

extension _ChatScreenStateExtensions on ChatScreenState {
  bool get isGroupChat => contact?.isGroup ?? false;
  bool get isGroupDeleted {
    if (group?.isDeleted ?? false) return true;

    return messages.whereType<chat.EventMessage>().any(
      (message) =>
          message.eventType == chat.EventMessageType.groupDeleted &&
          message.status == chat.ChatItemStatus.received,
    );
  }

  bool get isRemovedFromGroup {
    final did = myDid;
    if (did == null) return false;

    if (getGroupMemberByDid(did)?.status == GroupMemberStatus.deleted) {
      return true;
    }

    return messages.whereType<chat.EventMessage>().any(
      (message) =>
          message.eventType == chat.EventMessageType.groupMemberLeftGroup &&
          message.status == chat.ChatItemStatus.received &&
          message.memberDid == did &&
          message.isGroupMemberRemoved,
    );
  }
}
