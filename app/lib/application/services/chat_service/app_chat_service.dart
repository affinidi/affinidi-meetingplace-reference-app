import 'dart:async';
import 'dart:convert';
import 'package:clock/clock.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/models/contact_card/contact_card.dart' as domain;
import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_presence_status.dart';
import '../../../domain/models/contacts/contact_status.dart';
import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/extensions/did_extensions.dart';
import '../../../infrastructure/extensions/plain_text_message_extensions.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_badge_provider.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/chat_sdk_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/services/unsent_messages_service/unsent_messages_service.dart';
import '../contacts_service/contacts_service.dart';
import '../network_connectivity_service/network_connectivity_service.dart';
import 'chat_service.dart';

part 'app_chat_service.g.dart';

@riverpod
class AppChatService extends _$AppChatService implements ChatService {
  static const _logKey = 'CHATSVC';
  late final AppLogger _logger = ref.read(appLoggerProvider);

  @override
  late final int secondsToShowChatActivityIndicator = ref
      .read(environmentProvider)
      .chatActivityExpiresInSeconds;
  @override
  late final int chatPresenceIntervalInSeconds = ref
      .read(environmentProvider)
      .chatPresenceIntervalInSeconds;

  final _loadingActivityController = StreamController<bool>.broadcast();
  final _presenceController = StreamController<DateTime>.broadcast();
  final _typingController = StreamController<String?>.broadcast();
  final _effectController = StreamController<String?>.broadcast();
  final _groupDetailsController = StreamController<StreamData>.broadcast();
  final _otherPartyContactCardUpdateController =
      StreamController<domain.ContactCard>.broadcast();
  final _clearTypingController = StreamController<String>.broadcast();
  final _chatItemController = StreamController<ChatItem>.broadcast();
  final _sessionController = StreamController<Chat>.broadcast();

  MeetingPlaceChatSDK? _chatSDK;
  bool _isGroupChat = false;
  StreamSubscription? _messageSubscription;
  String? _channelDid;

  @override
  Stream<bool> get loadingActivity => _loadingActivityController.stream;
  @override
  Stream<DateTime> get presence => _presenceController.stream;
  @override
  Stream<String?> get typingMembers => _typingController.stream;
  @override
  Stream<String?> get effect => _effectController.stream;
  @override
  Stream<StreamData> get groupDetails => _groupDetailsController.stream;
  @override
  Stream<domain.ContactCard> get otherPartyContactCardUpdate =>
      _otherPartyContactCardUpdateController.stream;
  @override
  Stream<String> get clearTyping => _clearTypingController.stream;
  @override
  Stream<ChatItem> get chatItem => _chatItemController.stream;
  @override
  Stream<Chat> get session => _sessionController.stream;

  bool get isGroupChat => _isGroupChat;

  @override
  void build() {
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
      _loadingActivityController.close();
      _presenceController.close();
      _typingController.close();
      _effectController.close();
      _groupDetailsController.close();
      _otherPartyContactCardUpdateController.close();
      _clearTypingController.close();
      _chatItemController.close();
      _sessionController.close();

      _messageSubscription?.cancel();
      _chatSDK?.endChatSession();

      _logger.info('AppChatService disposed', name: _logKey);
    });
  }

  @override
  Future<void> startChatSession({required Contact contact}) async {
    await _messageSubscription?.cancel();
    _messageSubscription = null;

    _channelDid = contact.channelDid;
    if (_channelDid == null) return;
    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
      _channelDid!,
    );
    if (channel == null) return;

    _chatSDK = await ref.watch(chatSdkProvider(channel).future);
    _isGroupChat = contact.isGroup;

    try {
      final chatSession = await _chatSDK!.startChatSession();

      unawaited(
        _chatSDK!.chatStreamSubscription.then(
          (chatStream) {
            if (chatStream == null) {
              _logger.warning('Chat stream is null', name: _logKey);
              _messageSubscription = null;
              return;
            }

            _messageSubscription = chatStream.stream.listen(
              (data) => _onChannelMessagesData(data, _channelDid!),
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

      _sessionController.add(chatSession);

      await resetBadgeCount();
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
  Future<Group?> refreshGroup(String groupId) async {
    final coreSdk = await ref.read(meetingPlaceSdkProvider.future);
    return await coreSdk.getGroupById(groupId);
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
    Group? group,
  ) async {
    if (group == null) return;

    final moreMembersPendingApproval = group.members.any(
      (m) => m.status == GroupMemberStatus.pendingApproval,
    );

    await ref
        .read(contactsServiceProvider.notifier)
        .updateContact(
          contact.copyWith(
            status: moreMembersPendingApproval
                ? ContactStatus.pendingApproval
                : ContactStatus.active,
          ),
        );
  }

  @override
  void disposeChat() {
    _chatSDK?.endChatSession();
    _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  @override
  Future<void> sendTextMessage(
    String message, {
    List<Attachment>? attachments,
  }) async {
    await _chatSDK?.sendTextMessage(message, attachments: attachments);
  }

  @override
  Future<void> sendChatActivity() async {
    await _chatSDK?.sendChatActivity();
  }

  @override
  Future<void> rejectConnectionRequest(ConciergeMessage chatItem) async {
    await _chatSDK?.rejectConnectionRequest(chatItem);
  }

  @override
  Future<void> approveConnectionRequest(ConciergeMessage chatItem) async {
    await _chatSDK?.approveConnectionRequest(chatItem);
  }

  @override
  Future<void> sendChatContactDetailsUpdate(ConciergeMessage message) async {
    await _chatSDK?.sendChatContactDetailsUpdate(message);
  }

  @override
  Future<void> rejectChatContactDetailsUpdate(ConciergeMessage message) async {
    await _chatSDK?.rejectChatContactDetailsUpdate(message);
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

  Future<void> _onChannelMessagesData(
    StreamData data,
    String channelDid,
  ) async {
    _loadingActivityController.add(true);
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
      // Presence
      if (plainTextMessage.type.toString() == ChatProtocol.chatPresence.value) {
        _updateContactPresenceIfNeeded(data, channelDid);
      }

      // Sequence number update
      if (plainTextMessage.type.toString() == ChatProtocol.chatMessage.value) {
        unawaited(updateContactSequenceNumber(channelDid));
      }

      // Typing activity
      if (plainTextMessage.type.toString() == ChatProtocol.chatActivity.value) {
        final senderDid = plainTextMessage.from;
        _updateMembersTypingActivityIfNeeded(
          plainTextMessage: plainTextMessage,
          senderDid: senderDid,
          secondsToShowChatActivityIndicator: ref
              .read(environmentProvider)
              .chatActivityExpiresInSeconds,
        );
        _updateContactPresenceIfNeeded(data, channelDid);
      }

      // Effects
      if (plainTextMessage.type.toString() == ChatProtocol.chatEffect.value) {
        _effectController.add(plainTextMessage.effectName);
      }

      // Contact card update
      if (plainTextMessage.type.toString() ==
          ChatProtocol.chatContactDetailsUpdate.value) {
        _updateContactCardIfNeeded(data, channelDid);
      }

      // Group details update
      if (plainTextMessage.type.toString() ==
          ChatProtocol.chatGroupDetailsUpdate.value) {
        _updateGroupDetails(data, channelDid);
      }
    }

    // Upsert / Sort (TODO: should be done in the SDK)
    final chatItem = data.chatItem;
    if (chatItem != null) {
      if (chatItem is Message ||
          chatItem is ConciergeMessage ||
          chatItem is EventMessage) {
        // await _upsertChatItem(chatItem);
        _chatItemController.add(chatItem);
      }

      if (chatItem is Message && !chatItem.isFromMe) {
        _clearTypingController.add(chatItem.messageId);
      }
    }

    _loadingActivityController.add(false);
  }

  void _updateContactPresenceIfNeeded(StreamData data, String channelDid) {
    final plainTextMessage = data.plainTextMessage;
    if (plainTextMessage == null) return;

    final timestamp = DateTime.tryParse(
      plainTextMessage.body?['timestamp'] as String? ?? '',
    );

    if (channelDid.isNotEmpty && timestamp != null) {
      unawaited(
        ref
            .read(contactsServiceProvider.notifier)
            .updateContactLastKeepAliveMessage(channelDid, timestamp),
      );
      _presenceController.add(timestamp);
    }
  }

  void _updateMembersTypingActivityIfNeeded({
    required PlainTextMessage plainTextMessage,
    required String? senderDid,
    required int secondsToShowChatActivityIndicator,
  }) {
    final messageCreatedTime = plainTextMessage.createdTime;
    if (messageCreatedTime == null) return;

    final differenceInSeconds = clock
        .now()
        .difference(messageCreatedTime)
        .inSeconds;
    final isChatActivityExpired =
        (secondsToShowChatActivityIndicator - differenceInSeconds) < 0;
    if (isChatActivityExpired) return;

    _typingController.add(senderDid);
  }

  void _updateContactCardIfNeeded(StreamData data, String channelDid) {
    if (_isGroupChat) {
      _updateGroupDetails(data, channelDid);
      return;
    }

    final plainTextMessage = data.plainTextMessage;
    if (plainTextMessage == null) {
      _logger.warning(
        'Received a contact details update without a message',
        name: _logKey,
      );
      return;
    }

    final contactDid = plainTextMessage.from;
    if (contactDid == null || contactDid.isEmpty) {
      _logger.warning(
        'Received a contact details update without a from',
        name: _logKey,
      );
      return;
    }

    final body = plainTextMessage.body;
    if (body == null) {
      _logger.warning(
        'Received a contact details update without a body',
        name: _logKey,
      );
      return;
    }

    final cardValues = body['contactInfo'] as Map<String, dynamic>?;
    if (cardValues == null) {
      _logger.warning(
        'Received a contact details update without a contact card',
        name: _logKey,
      );
      return;
    }

    _logger.info('Updating Contact Card', name: _logKey);

    final sdkCard = ContactCard(
      did: body['did'] as String,
      type: body['type'] as String,
      contactInfo: cardValues,
    );

    final domainCard = ContactCardUtils.fromSdkContactCard(sdkCard);
    _otherPartyContactCardUpdateController.add(domainCard);
    ref
        .read(contactsServiceProvider.notifier)
        .updateContactCard(contactDid, domainCard);
  }

  void _updateGroupDetails(StreamData data, String channelDid) {
    _logger.info(
      'Updating group details for channel ${channelDid.topAndTail()}',
      name: _logKey,
    );
    _groupDetailsController.add(data);
  }

  Future<void> resetBadgeCount() async {
    if (_channelDid == null) return;

    await ref
        .read(contactsServiceProvider.notifier)
        .resetContactBadgeCount(_channelDid!);
  }
}
