import 'dart:async';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../application/services/contacts_service/contacts_service.dart';
import '../../../domain/models/chat/encryption_notice.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_presence_status.dart';
import '../../../domain/models/contacts/contact_status.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/exceptions/app_exception.dart';
import '../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../infrastructure/extensions/event_message_extentions.dart';
import '../../../infrastructure/extensions/list_extensions.dart';
import '../../../infrastructure/extensions/plain_text_message_extensions.dart';
import '../../../infrastructure/extensions/vcard_extensions.dart';
import '../../../infrastructure/helpers/timed_action.dart';
import '../../../infrastructure/providers/app_badge_provider.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/chat_sdk_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/services/unsent_messages_service/unsent_messages_service.dart';
import '../../effects/screen_effect.dart';
import '../../widgets/async_loaders/async_loading_controller.dart';
import 'chat_screen_state.dart';

part 'chat_screen_controller.g.dart';

@riverpod

/// Controller class for managing the state and logic of the chat screen.
///
/// Extends [_$ChatScreenController] to provide reactive state management
/// and business logic for chat-related features, such as handling messages,
/// user interactions, and UI updates within the chat screen.
class ChatScreenController extends _$ChatScreenController {
  ChatScreenController() : super();

  late final int _secondsToShowChatActivityIndicator =
      ref.read(environmentProvider).chatActivityExpiresInSeconds;
  late final int chatPresenceIntervalInSeconds =
      ref.read(environmentProvider).chatPresenceIntervalInSeconds;
  // Maximum typing indicators to prevent UI overflow on small screens
  static const int _maxNumberOfTypingMembersVisible = 4;
  static const _logKey = 'UXCHAT';

  late final messageTextController = TextEditingController();
  late final _logger = ref.read(appLoggerProvider);

  chat.MeetingPlaceChatSDK? _chatSDK;
  chat.ChatStream? messagesSubscription;
  TimedAction? _sendChatActivityTimedAction;
  TimedAction? _membersTypingTimedAction;
  TimedAction? _updateContactPresenceStatusTimedAction;

  late final Map<String, ProviderSubscription<void>>
      _conciergeLoadingControllersSubscriptions = {};
  late final Map<String,
          AutoDisposeNotifierProvider<AsyncLoadingController, AsyncValue<void>>>
      _conciergeLoadingControllers = {};

  @override
  ChatScreenState build(String contactId) {
    ref.listen(
        contactsServiceProvider.select(
          (state) => state.getContactById(contactId),
        ), (previous, next) {
      if (next == null) {
        return;
      }

      Future.microtask(() {
        state = state.copyWith(contact: next);
      });
    }, fireImmediately: true);

    ref.onDispose(() {
      messagesSubscription?.dispose();
      messageTextController.dispose();

      _disposeConciergeLoadingControllers();
    });

    return ChatScreenState(
      isActive: true,
      isInitialized: false,
    );
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

  Future<void> cleanup() async {
    final unsentMessage = messageTextController.text;
    _sendChatActivityTimedAction?.cancel();
    _membersTypingTimedAction?.cancel();
    _updateContactPresenceStatusTimedAction?.cancel();

    final contact = state.contact;
    if (contact == null) {
      return;
    }

    await ref
        .read(unsentMessagesServiceProvider.notifier)
        .saveUnsentMessage(contact.id, unsentMessage);

    _chatSDK?.endChatSession();

    _logger.info(
      'Chat session ended',
      name: _logKey,
    );
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
      _conciergeLoadingControllersSubscriptions[id] =
          ref.listen(existing, (prev, next) {});
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
        'send_profile_${message.messageId}');
  }

  AutoDisposeNotifierProvider<AsyncLoadingController, AsyncValue<void>>
      conciergeAskLaterToSendProfileLoadingController(
          chat.ConciergeMessage message) {
    return _addConciergeSubscriptionIfNeeded(
        'ask_later_send_profile_${message.messageId}');
  }

  AutoDisposeNotifierProvider<AsyncLoadingController, AsyncValue<void>>
      conciergeCancelSendProfileLoadingController(
          chat.ConciergeMessage message) {
    return _addConciergeSubscriptionIfNeeded(
        'cancel_send_profile_${message.messageId}');
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
      throw AppException('Unable to find contact with identifier $contactId',
          code: AppExceptionType.missingContact.name);
    }

    state = state.copyWith(contact: contact);

    final channelDid = contact.channelDid;
    if (channelDid == null) {
      throw AppException('Contact has not been associated to any channels',
          code: AppExceptionType.missingChannel.name);
    }
    _logger.info(
      'ChannelID: $channelDid',
      name: _logKey,
    );

    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    final channel =
        await coreSdk.getChannelByOtherPartyPermanentDid(channelDid);
    if (channel == null) {
      throw AppException('Unable to find channel associated to contact',
          code: AppExceptionType.missingChannel.name);
    }
    state = state.copyWith(
      otherPartyVCard: channel.otherPartyVCard,
      notificationToken: channel.otherPartyNotificationToken,
    );

    _chatSDK = await ref.watch(chatSdkProvider(channel).future);

    final lastKeepAliveMessage = contact.lastKeepAliveMessage;
    if (lastKeepAliveMessage != null) {
      _updateContactPresenceStatus(lastKeepAliveMessage);
    }

    unawaited(_updateContactSequenceNumber(channelDid));

    final chatSDK = _chatSDK;
    if (chatSDK == null) {
      throw AppException('Unable to find initialized chat sdk',
          code: AppExceptionType.other.name);
    }

    final chat = await chatSDK.startChatSession();
    _logger.info(
      'Chat SDK started and ready for messaging',
      name: _logKey,
    );

    unawaited(chatSDK.chatStreamSubscription.then(
      (stream) {
        if (stream == null) return;
        messagesSubscription = stream.listen(
          (data) => _onChannelMessagesData(data, channelDid),
          onError: (Object error, StackTrace stackTrace) {
            _logger.error(
              'Error in message stream',
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
    ));

    final messages = [EncryptionNotice(), ...chat.messages];
    _logger.info(
      'Existing messages: ${messages.length}',
      name: _logKey,
    );
    await _startChatSession(contact);

    // TODO(MA): Remove sorting when it's added to sdk
    state = state.copyWith(
      messages: messages.sortedBy((item) => item.dateCreated).reversed.toList(),
    );

    if (channel.type == ChannelType.group) {
      final group = await coreSdk.getGroupByOfferLink(channel.offerLink);
      final connection = await coreSdk.getConnectionOffer(channel.offerLink);
      state = state.copyWith(group: group, offerName: connection?.offerName);
    }
    _hideActivity();
  }

  Future<void> _onChannelMessagesData(
    chat.StreamData data,
    String channelDid,
  ) async {
    _showActivity();
    _logger.info(
      '''[MessagesStream] Received message type: ${data.plainTextMessage?.type.toString()}''',
      name: _logKey,
    );
    _logger.info(
      '''[MessagesStream] body: ${json.encode(data.plainTextMessage?.toJson())}''',
      name: _logKey,
    );

    final plainTextMessage = data.plainTextMessage;
    if (plainTextMessage != null) {
      if (plainTextMessage.type.toString() ==
          chat.ChatProtocol.chatPresence.value) {
        _updateContactPresenceIfNeeded(data, channelDid);
      }

      if (plainTextMessage.type.toString() ==
          chat.ChatProtocol.chatMessage.value) {
        unawaited(_updateContactSequenceNumber(channelDid));
      }

      if (plainTextMessage.type.toString() ==
          chat.ChatProtocol.chatActivity.value) {
        final groupMessageSenderName =
            _getGroupMemberNameFromMessage(plainTextMessage);
        final contactName = state.contact?.vCard.firstName;

        _updateMembersTypingActivityIfNeeded(
          plainTextMessage: plainTextMessage,
          groupMessageSenderName: groupMessageSenderName,
          contactName: contactName,
        );

        _updateContactPresenceIfNeeded(data, channelDid);
      }

      if (plainTextMessage.type.toString() ==
          chat.ChatProtocol.chatEffect.value) {
        _applyEffect(data);
      }

      if (plainTextMessage.type.toString() ==
          chat.ChatProtocol.chatContactDetailsUpdate.value) {
        _updateContactCardIfNeeded(data, channelDid);
      }

      if (plainTextMessage.type.toString() ==
          chat.ChatProtocol.chatGroupDetailsUpdate.value) {
        _updateGroupDetails(data, channelDid);
      }
    }

    final chatItem = data.chatItem;
    if (chatItem != null) {
      if (chatItem is chat.Message ||
          chatItem is chat.ConciergeMessage ||
          chatItem is chat.EventMessage) {
        _upsertChatItem(chatItem);
      }

      if (chatItem is chat.Message && !chatItem.isFromMe) {
        final groupMessageSenderName = plainTextMessage != null
            ? _getGroupMemberNameFromMessage(plainTextMessage)
            : null;
        final contactName = state.contact?.vCard.firstName;
        _clearMembersTypingActivity(
          groupMessageSenderName: groupMessageSenderName,
          contactName: contactName,
        );
      }
    }
    _hideActivity();
  }

  String? _getGroupMemberNameFromMessage(
      chat.PlainTextMessage plainTextMessage) {
    if (!state.isGroupChat) return null;

    final senderDid = plainTextMessage.from;
    if (senderDid == null) return null;

    return state.getGroupMemberByDid(senderDid)?.vCard.firstName;
  }

  void _applyEffect(chat.StreamData data) {
    if (state.effect != null) return;
    final plainTextMessage = data.plainTextMessage;
    if (plainTextMessage == null) return;

    final effectName = plainTextMessage.effectName;
    if (effectName == null) return;

    final effect =
        chat.Effect.values.firstWhereOrNull((item) => item.name == effectName);
    if (effect == null) return;

    switch (effect) {
      case chat.Effect.confetti:
        state = state.copyWith(effect: ScreenEffect.confetti());
      case chat.Effect.balloons:
        state = state.copyWith(effect: ScreenEffect.balloons());
      case chat.Effect.fireworks:
      case chat.Effect.hearts:
        break;
    }
  }

  void _updateContactPresenceIfNeeded(chat.StreamData data, String channelDid) {
    final plainTextMessage = data.plainTextMessage;
    if (plainTextMessage == null) return;

    final datePresence = DateTime.tryParse(
      plainTextMessage.body?['timestamp'] as String? ?? '',
    );

    if (datePresence != null) {
      unawaited(ref
          .read(contactsServiceProvider.notifier)
          .updateContactLastKeepAliveMessage(channelDid, datePresence));
      _updateContactPresenceStatus(datePresence);
    }
  }

  void _updateGroupDetails(chat.StreamData data, String channelDid) {
    _logger.info(
      'Updating group details',
      name: _logKey,
    );
    unawaited(_refreshGroup());
  }

  void _updateContactCardIfNeeded(chat.StreamData data, String channelDid) {
    if (state.isGroupChat) {
      _updateGroupDetails(data, channelDid);
      return;
    }

    final plainTextMessage = data.plainTextMessage;
    if (plainTextMessage == null) {
      _logger.info(
        'Received a contact details update without a message',
        name: _logKey,
      );
      return;
    }

    final contactDid = plainTextMessage.from;
    if (contactDid == null || contactDid.isEmpty) {
      _logger.info(
        'Received a contact details update without a from',
        name: _logKey,
      );
      return;
    }

    final body = plainTextMessage.body;
    if (body == null) {
      _logger.info(
        'Received a contact details update without a body',
        name: _logKey,
      );
      return;
    }

    final vCardValues = body['values'] as Map<String, dynamic>?;
    if (vCardValues == null) {
      _logger.info(
        'Received a contact details update without a vCard',
        name: _logKey,
      );
      return;
    }

    _logger.info(
      'Updating Contact Card',
      name: _logKey,
    );
    final updatedVCard = VCard(values: vCardValues);
    state = state.copyWith(otherPartyVCard: updatedVCard);
    ref
        .read(contactsServiceProvider.notifier)
        .updateContactVcard(contactDid, updatedVCard);
  }

  Future<void> _refreshGroup() async {
    final currentGroup = state.group;
    if (currentGroup == null) return;

    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    final refreshedGroup = await coreSdk.getGroupById(currentGroup.id);
    if (refreshedGroup == null) return;

    state = state.copyWith(group: refreshedGroup);
  }

  void _updateContactPresenceStatus(DateTime datePresence) {
    _updateContactPresenceStatusTimedAction?.cancel();

    _updateContactPresenceStatusTimedAction ??= TimedAction(
      onRun: (args) {
        final now = clock.now();
        final datePresence = args?[0] as DateTime? ?? now;
        final hasReceivedAnyActivity = datePresence.toLocal().isAfter(
            now.subtract(Duration(seconds: chatPresenceIntervalInSeconds)));

        state = state.copyWith(
            contactPresenceStatus: hasReceivedAnyActivity
                ? ContactPresenceStatus.online
                : ContactPresenceStatus.offline);
      },
      onCancel: () {
        state = state.copyWith(
            contactPresenceStatus: ContactPresenceStatus.offline);
      },
      onComplete: () {
        state = state.copyWith(
            contactPresenceStatus: ContactPresenceStatus.offline);
      },
      duration: Duration(seconds: chatPresenceIntervalInSeconds),
    );
    _updateContactPresenceStatusTimedAction?.start(args: [datePresence]);
  }

  void _clearMembersTypingActivity({
    required String? groupMessageSenderName,
    required String? contactName,
  }) {
    _logger.info(
      '_clearMembersTypingActivity',
      name: _logKey,
    );
    final memberNames = [...state.membersTyping];
    if (memberNames.isEmpty) {
      return;
    }

    memberNames.removeWhere(
        (name) => name == groupMessageSenderName || name == contactName);
    state = state.copyWith(membersTyping: memberNames);
  }

  void _updateMembersTypingActivityIfNeeded({
    required chat.PlainTextMessage plainTextMessage,
    required String? groupMessageSenderName,
    required String? contactName,
  }) {
    final messageCreatedTime = plainTextMessage.createdTime;
    if (messageCreatedTime == null) return;

    final differenceInSeconds =
        clock.now().difference(messageCreatedTime).inSeconds;
    final isChatActivityExpired =
        (_secondsToShowChatActivityIndicator - differenceInSeconds) < 0;
    if (isChatActivityExpired) return;

    _logger.info(
      '_updateUserTypingActivity',
      name: _logKey,
    );
    _membersTypingTimedAction?.cancel();
    _membersTypingTimedAction ??= TimedAction(
      onRun: (args) {
        var memberNames = <String>[];
        final groupMessageSenderName = args?[0] as String?;
        if (groupMessageSenderName != null &&
            groupMessageSenderName.isNotEmpty) {
          memberNames = [...state.membersTyping];
          if (memberNames.length < _maxNumberOfTypingMembersVisible &&
              !memberNames.contains(groupMessageSenderName)) {
            memberNames.add(groupMessageSenderName);
          }
        } else {
          if (contactName != null && contactName.isNotEmpty) {
            memberNames = [contactName];
          }
        }

        if (memberNames.isEmpty) {
          return;
        }

        state = state.copyWith(membersTyping: memberNames);
      },
      onCancel: () {
        if (state.isGroupChat) return;
        state = state.copyWith(membersTyping: []);
      },
      onComplete: () {
        state = state.copyWith(membersTyping: []);
      },
      duration: Duration(seconds: _secondsToShowChatActivityIndicator),
    );
    _membersTypingTimedAction?.start(args: [groupMessageSenderName]);
  }

  void _upsertChatItem(chat.ChatItem item) {
    final existingMessages = state.messages;
    final existingItemIndex =
        existingMessages.indexWhere((m) => m.messageId == item.messageId);

    final messages = (existingItemIndex == -1)
        ? [item, ...existingMessages]
        : existingMessages.replaceItemAtIndex(existingItemIndex, item);
    state = state.copyWith(messages: messages);
  }

  void _removeChatItem(chat.ChatItem item) {
    final existingMessages = state.messages;
    final existingItemIndex =
        existingMessages.indexWhere((m) => m.messageId == item.messageId);

    if (existingItemIndex == -1) return;

    state = state.copyWith(
      messages: List.of(existingMessages)..removeAt(existingItemIndex),
    );
  }

  Future<void> _updateGroupContactPendingStatus() async {
    if (state.group == null) return;

    final contact = state.contact;
    if (contact == null) return;

    final moreMembersPendingApproval = state.group?.members
            .any((m) => m.status == GroupMemberStatus.pendingApproval) ??
        false;
    await ref.read(contactsServiceProvider.notifier).updateContact(
          contact.copyWith(
            status: moreMembersPendingApproval
                ? ContactStatus.pendingApproval
                : ContactStatus.active,
          ),
        );
  }

  /// Sends a text message to the chat.
  ///
  /// The message text is trimmed and validated before sending.
  /// Clears the input field upon successful send.
  Future<void> sendMessage() async {
    final trimmedMessage = messageTextController.text.trimRight();
    if (trimmedMessage.isEmpty) return;

    unawaited(_chatSDK?.sendTextMessage(trimmedMessage));
    _sendChatActivityTimedAction?.cancel();
    messageTextController.text = '';
  }

  Future<void> sendChatActivity() async {
    _sendChatActivityTimedAction ??= TimedAction(
      onRun: (args) async {
        await _chatSDK?.sendChatActivity();
      },
      // NOTE: Subtracting 1 second from this time, so that there is overlap
      duration: Duration(seconds: _secondsToShowChatActivityIndicator - 1),
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
      await ref
          .read(conciergeRejectLoadingController(chatItem).notifier)
          .start(() async {
        _logger.info(
          '''Rejecting membership for messageId: ${chatItem.messageId}''',
          name: _logKey,
        );
        await _chatSDK?.rejectConnectionRequest(chatItem);
        await _refreshGroup();
        await _updateGroupContactPendingStatus();
      });
    } finally {
      _hideActivity();
    }
  }

  /// Approves a membership request based on the provided [chatItem].
  ///
  /// This method performs the necessary actions to approve a membership,
  /// typically triggered by a concierge message in the chat.
  ///
  /// [chatItem] - The concierge message containing membership request details.
  ///
  /// Returns a [Future] that completes when the approval process is finished.
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
        await _chatSDK?.approveConnectionRequest(chatItem);
        await _refreshGroup();
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
    await ref
        .read(conciergeSendProfileLoadingController(message).notifier)
        .start(() async {
      _logger.info(
        '''Sending contact details update for messageId: ${message.messageId}''',
        name: _logKey,
      );
      await _chatSDK?.sendChatContactDetailsUpdate(message);
    });
  }

  /// Prompts the user at a later time to send updated contact details.
  ///
  /// This method can be used to defer the action of sending contact details
  /// update, allowing the user to be reminded or asked again in the future.
  ///
  /// Returns a [Future] that completes when the operation is finished.
  Future<void> askMeLaterToSendContactDetailsUpdate(
      chat.ConciergeMessage message) async {
    await ref
        .read(conciergeAskLaterToSendProfileLoadingController(message).notifier)
        .start(() async {
      _logger.info(
        '''Hiding profile update message till later for messageId: ${message.messageId}''',
        name: _logKey,
      );
      _removeChatItem(message);
    });
  }

  /// Cancels the ongoing process of updating contact details.
  ///
  /// This method should be called to abort any changes made to the contact
  /// details before they are saved or finalized. It ensures that the contact
  /// details remain unchanged if the update process is interrupted or
  /// cancelled.
  Future<void> cancelUpdatingContactDetails(
      chat.ConciergeMessage message) async {
    await ref
        .read(conciergeCancelSendProfileLoadingController(message).notifier)
        .start(() async {
      _logger.info(
        '''Decided to not send profile update message for messageId: ${message.messageId}''',
        name: _logKey,
      );
      await _chatSDK?.rejectChatContactDetailsUpdate(message);
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
      final message = state.messages
          .firstWhereOrNull((m) => m.messageId == messageId) as chat.Message?;

      if (message == null) {
        throw AppException('Unable to find message with id $messageId',
            code: AppExceptionType.missingMessage.name);
      }

      await _chatSDK?.reactOnMessage(message, reaction: reaction);
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
      await _chatSDK?.sendEffect(effect.type);
    } finally {
      _hideActivity();
    }
  }

  /// Clears any currently set effect in the chat screen controller.
  ///
  /// This method resets the effect state, typically used to remove
  /// temporary UI effects or notifications after they have been handled.
  void clearEffect() {
    state = state.copyWith(effect: null);
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
      String text, List<MessageAttachment> messageAttachment) async {
    messageTextController.clear();
    unawaited(_chatSDK?.sendTextMessage(
      text,
      attachments: messageAttachment.map((a) => a.toAttachment()).toList(),
    ));
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
  void loadImageAttachment(Attachment attachment) {
    final attachmentId = attachment.id;
    if (attachmentId == null) {
      _logger.info(
        'Attachment cannot be displayed as it does not have an id',
        name: _logKey,
      );
      return;
    }

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

  Future<void> _updateContactSequenceNumber(String channelDid) async {
    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    final channel =
        await coreSdk.getChannelByOtherPartyPermanentDid(channelDid);
    if (channel == null) {
      _logger.warning(
          'Cannot update contact sequence number: channel cannot be found',
          name: _logKey);
      return;
    }

    unawaited(ref
        .read(contactsServiceProvider.notifier)
        .updateContactSequenceNumber(channelDid, channel.seqNo));
  }

  Future<void> _startChatSession(Contact contact) async {
    // Restore unsent message from in-memory service
    final unsentMessage = ref
        .read(unsentMessagesServiceProvider.notifier)
        .getUnsentMessage(contact.id);
    if (unsentMessage != null) {
      messageTextController.text = unsentMessage;
    }

    state = state.copyWith(isInitialized: true);

    await ref.read(contactsServiceProvider.notifier).updateContact(
          contact.copyWith(
            badgeCount: 0,
            hasBeenOpened: true,
          ),
        );

    await ref.read(appBadgeServiceProvider).clearBadge();

    _logger.info(
      'Chat session started',
      name: _logKey,
    );
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

      return state.otherPartyVCard?.firstName ?? '';
    });
  }

  ProviderListenable<bool> get isGroupChat {
    return select((state) => state.isGroupChat);
  }

  ProviderListenable<String?> get otherPartyName {
    return select((state) {
      if (state.contact?.isGroup ?? false) return null;

      return state.otherPartyVCard?.firstName;
    });
  }

  ProviderListenable<int> get indexOfLastMessageFromMe {
    return select(
        (state) => state.messages.indexWhere((message) => message.isFromMe));
  }

  ProviderListenable<List<String>> get awaitingMemberNames {
    return select((state) {
      final awaitingMembers = state.messages
          .whereType<chat.EventMessage>()
          .where((message) =>
              message.eventType ==
                  chat.EventMessageType.awaitingGroupMemberToJoin &&
              message.status == chat.ChatItemStatus.received);

      final memberDidsWhoLeft = state.messages
          .whereType<chat.EventMessage>()
          .where((message) =>
              message.eventType == chat.EventMessageType.groupMemberLeftGroup)
          .map((message) => message.memberDid)
          .where((did) => did != null)
          .toSet();

      final awaitingMemberNames = awaitingMembers
          .where((message) => !memberDidsWhoLeft.contains(message.memberDid))
          .map((message) => message.vCard?.firstName)
          .where((firstName) => firstName != null)
          .cast<String>();

      return awaitingMemberNames.toList();
    });
  }

  ProviderListenable<bool> get isGroupDeleted {
    return select((state) => state.isGroupDeleted);
  }

  ProviderListenable<bool> get shouldShowProgress {
    return select((state) =>
        state.isActive ||
        state.messages
            .any((message) => message.status == chat.ChatItemStatus.queued));
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
        .where((message) =>
            message.eventType == chat.EventMessageType.groupDeleted &&
            message.status == chat.ChatItemStatus.received)
        .map((message) => message.vCard?.firstName)
        .where((firstName) => firstName != null)
        .cast<String>();

    return groupDeleted.isNotEmpty;
  }
}
