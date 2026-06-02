import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';

import '../../../application/services/chat_service/chat_service.dart';
import '../../../application/services/chat_service/chat_session_service.dart';
import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/extensions/event_message_extensions.dart';
import '../../../infrastructure/helpers/timed_action.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/services/unsent_messages_service/unsent_messages_service.dart';
import '../../effects/screen_effect.dart';
import '../../widgets/async_loaders/async_loading_controller.dart';
import 'attachment_cache_key.dart';
import 'chat_screen_state.dart';

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

  late final messageTextController = TextEditingController();
  late final _logger = ref.read(appLoggerProvider);

  TimedAction? _sendChatActivityTimedAction;
  Timer? _saveUnsentMessageDebouncer;
  bool _isPaused = false;
  late final _chatResumingLock = Lock();
  final Set<String> _attachmentsLoading = {};

  late final Map<String, ProviderSubscription<void>>
  _conciergeLoadingControllersSubscriptions = {};
  late final Map<
    String,
    AutoDisposeNotifierProvider<AsyncLoadingController, AsyncValue<void>>
  >
  _conciergeLoadingControllers = {};

  ChatService? _chatService;

  @override
  ChatScreenState build(String contactId) {
    WidgetsBinding.instance.addObserver(this);

    final contact = ref.read(contactsServiceProvider).getContactById(contactId);
    final channelDid = contact?.channelDid;

    if (channelDid != null) {
      _chatService = ref.read(chatSessionServiceProvider(channelDid).notifier);
      ref.listen(chatSessionServiceProvider(channelDid), (previous, next) {
        var newEffect = state.effect;
        if (next.effect != null && previous?.effect != next.effect) {
          newEffect = _mapEffect(next.effect!);
        } else if (next.effect == null) {
          newEffect = null;
        }

        state = state.copyWith(
          messages: next.messages,
          membersTyping: next.membersTyping,
          contactPresenceStatus: next.contactPresenceStatus,
          isActive: next.isActive,
          isInitialized: next.isInitialized,
          group: next.group ?? state.group,
          otherPartyCard: next.otherPartyCard ?? state.otherPartyCard,
          effect: newEffect,
        );
        _preloadHostedMediaAttachments(next.messages);
      });
    }

    ref.listen(
      contactsServiceProvider.select(
        (state) => state.getContactById(contactId),
      ),
      (previous, next) {
        if (next == null) return;
        Future.microtask(() {
          state = state.copyWith(contact: next);
        });
      },
      fireImmediately: true,
    );

    messageTextController.addListener(_onMessageTextChanged);

    ref.onDispose(() {
      _sendChatActivityTimedAction?.cancel();
      _saveUnsentMessageDebouncer?.cancel();
      unawaited(_chatService?.pauseChat());

      messageTextController.removeListener(_onMessageTextChanged);
      messageTextController.dispose();

      _disposeConciergeLoadingControllers();

      _logger.info('Chat session ended', name: _logKey);

      WidgetsBinding.instance.removeObserver(this);
    });

    return ChatScreenState(isActive: true, isInitialized: false);
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

    await _restoreUnsentMessage();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logger.info('didChangeAppLifecycleState: $state', name: _logKey);
    switch (state) {
      case AppLifecycleState.resumed:
        _chatResumingLock.synchronized(() async {
          await _resumeChatSession();
        });
        break;
      case AppLifecycleState.paused:
        _chatResumingLock.synchronized(() async {
          _pauseChatSession();
        });
        break;
      default:
        break;
    }
  }

  Future<void> _resumeChatSession() async {
    if (!_isPaused) return;

    _logger.info('Resuming chat session', name: _logKey);
    final contact = state.contact;
    if (contact == null) return;

    final channelDid = contact.channelDid;
    if (channelDid == null) return;

    try {
      await _chatService?.startChatSession();
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

  void _pauseChatSession() {
    if (_isPaused) return;

    _logger.info('Pausing chat session', name: _logKey);
    _isPaused = true;
    unawaited(_chatService?.pauseChat());
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

  AutoDisposeNotifierProvider<AsyncLoadingController, AsyncValue<void>>
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

  AutoDisposeNotifierProvider<AsyncLoadingController, AsyncValue<void>>
  conciergeApproveLoadingController(chat.ConciergeMessage message) {
    return _addConciergeSubscriptionIfNeeded('approve_${message.messageId}');
  }

  AutoDisposeNotifierProvider<AsyncLoadingController, AsyncValue<void>>
  conciergeRejectLoadingController(chat.ConciergeMessage message) {
    return _addConciergeSubscriptionIfNeeded('reject_${message.messageId}');
  }

  AutoDisposeNotifierProvider<AsyncLoadingController, AsyncValue<void>>
  conciergeSendProfileLoadingController(chat.ConciergeMessage message) {
    return _addConciergeSubscriptionIfNeeded(
      'send_profile_${message.messageId}',
    );
  }

  AutoDisposeNotifierProvider<AsyncLoadingController, AsyncValue<void>>
  conciergeAskLaterToSendProfileLoadingController(
    chat.ConciergeMessage message,
  ) {
    return _addConciergeSubscriptionIfNeeded(
      'ask_later_send_profile_${message.messageId}',
    );
  }

  AutoDisposeNotifierProvider<AsyncLoadingController, AsyncValue<void>>
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
    state = state.copyWith(
      otherPartyCard: srcCard == null
          ? null
          : ContactCardUtils.fromSdkContactCard(srcCard),
      notificationToken: channel.otherPartyNotificationToken,
    );

    final lastKeepAliveMessage = contact.lastKeepAliveMessage;
    if (lastKeepAliveMessage != null) {
      _chatService?.onPresenceUpdated(lastKeepAliveMessage);
    }

    await _chatService?.updateContactSequenceNumber(channelDid);
    await _chatService?.startChatSession();

    if (channel.type == ChannelType.group) {
      final group = await coreSdk.getGroupByOfferLink(channel.offerLink);
      final connection = await coreSdk.getConnectionOffer(channel.offerLink);
      state = state.copyWith(group: group, offerName: connection?.offerName);
    }

    _hideActivity();
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

    unawaited(_chatService?.sendTextMessage(trimmedMessage) ?? Future.value());
    _sendChatActivityTimedAction?.cancel();
    messageTextController.clear();
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

  /// Sends an attachment in the chat via media upload.
  ///
  /// Uploads each attachment to the Matrix homeserver with E2EE, then sends
  /// a media message containing the mxc:// reference. The recipient downloads
  /// and decrypts the media from the homeserver.
  Future<void> sendAttachment(
    String text,
    List<MessageAttachment> messageAttachment,
  ) async {
    messageTextController.clear();
    _sendChatActivityTimedAction?.cancel();

    for (final (index, attachment) in messageAttachment.indexed) {
      final chatAttachment = attachment.toAttachment();
      final caption = index == 0 ? text : '';

      unawaited(
        _chatService?.sendTextMessage(caption, attachments: [chatAttachment]),
      );
    }
  }

  /// Loads an image attachment into the chat screen.
  ///
  /// Handles both legacy base64-encoded attachments and hosted media
  /// attachments (downloaded from mxc:// URI via the SDK).
  void loadImageAttachment(ChatAttachment attachment) {
    final attachmentId = attachmentCacheKey(attachment);

    final attachmentsDataCache = Map.of(state.attachmentsDataCache);
    final existingData = attachmentsDataCache[attachmentId];
    if (existingData != null) return;

    final attachmentData = attachment.data?.base64;
    if (attachmentData != null) {
      attachmentsDataCache[attachmentId] = base64.decode(attachmentData);
      state = state.copyWith(attachmentsDataCache: attachmentsDataCache);
      return;
    }

    final links = attachment.data?.links;
    if (links != null && links.isNotEmpty) {
      _downloadAndCacheAttachment(attachmentId, attachment);
    }
  }

  void _preloadHostedMediaAttachments(List<chat.ChatItem> messages) {
    for (final message in messages.whereType<chat.Message>()) {
      for (final attachment in message.attachments) {
        if (attachment.format == AttachmentFormat.hostedMedia.value) {
          loadImageAttachment(attachment);
        }
      }
    }
  }

  Future<void> _downloadAndCacheAttachment(
    String cacheKey,
    ChatAttachment attachment,
  ) async {
    if (_attachmentsLoading.contains(cacheKey)) return;
    _attachmentsLoading.add(cacheKey);

    try {
      final bytes = await _chatService?.downloadMedia(attachment);
      if (bytes == null) {
        _logger.warning(
          'Chat service unavailable, skipping media download',
          name: _logKey,
        );
        final failedCache = Map.of(state.attachmentsDataCache);
        failedCache[cacheKey] = Uint8List(0);
        state = state.copyWith(attachmentsDataCache: failedCache);
        return;
      }

      final attachmentsDataCache = Map.of(state.attachmentsDataCache);
      attachmentsDataCache[cacheKey] = bytes;
      state = state.copyWith(attachmentsDataCache: attachmentsDataCache);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to download media attachment',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      final failedCache = Map.of(state.attachmentsDataCache);
      failedCache[cacheKey] = Uint8List(0);
      state = state.copyWith(attachmentsDataCache: failedCache);
    } finally {
      _attachmentsLoading.remove(cacheKey);
    }
  }

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

      return state.otherPartyCard?.firstName ?? '';
    });
  }

  ProviderListenable<bool> get isGroupChat {
    return select((state) => state.isGroupChat);
  }

  ProviderListenable<String?> get otherPartyName {
    return select((state) {
      if (state.contact?.isGroup ?? false) return null;

      return state.otherPartyCard?.firstName;
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
    return select((state) => !state.isInitialized || state.isGroupDeleted);
  }
}

extension _ChatScreenStateExtensions on ChatScreenState {
  bool get isGroupChat => contact?.isGroup ?? false;
  bool get isGroupDeleted {
    final groupDeleted = messages
        .whereType<chat.EventMessage>()
        .where(
          (message) =>
              message.eventType == chat.EventMessageType.groupDeleted &&
              message.status == chat.ChatItemStatus.received,
        )
        .map((message) => message.contactCard?.firstName)
        .where((firstName) => firstName != null)
        .cast<String>();

    return groupDeleted.isNotEmpty;
  }
}
