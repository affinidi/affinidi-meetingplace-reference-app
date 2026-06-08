import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_credentials/meeting_place_credentials.dart';

import '../../../../domain/models/identity/identity.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../../infrastructure/providers/chat_repository_provider.dart';
import '../../../../infrastructure/providers/credentials_sdk_provider.dart';
import '../../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../identities_service/identities_service.dart';

/// Manages outgoing and incoming R-Card operations for a single chat channel.
class RCardManager {
  RCardManager({
    required Ref ref,
    required String otherPartyPermanentDid,
    required AppLogger logger,
    required MeetingPlaceChatSDK? Function() getChatSdk,
    required void Function(ChatItem) upsertChatItem,
  }) : _ref = ref,
       _otherPartyPermanentDid = otherPartyPermanentDid,
       _logger = logger,
       _getChatSdk = getChatSdk,
       _upsertChatItem = upsertChatItem;

  static const _logKey = 'RCARD';

  final Ref _ref;
  final String _otherPartyPermanentDid;
  final AppLogger _logger;
  final MeetingPlaceChatSDK? Function() _getChatSdk;
  final void Function(ChatItem) _upsertChatItem;

  StreamSubscription<dynamic>? _subscription;

  MeetingPlaceChatSDK? get _chatSdk => _getChatSdk();

  /// Cancels the incoming R-Card stream subscription.
  void cancelSubscription() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }

  /// Consumes any R-Card that arrived from the other party while no
  /// subscription was active, and surfaces it as a chat attachment.
  ///
  /// Must be called AFTER [subscribeToIncomingRCards] so that the
  /// subscription is live before replay runs.
  Future<void> replayPendingRCard() async {
    final credentialsSDK = await _ref.read(credentialsSdkProvider.future);
    final pending = credentialsSDK.consumePendingRCard(_otherPartyPermanentDid);
    if (pending != null) {
      await _onRCardReceived(pending);
    }
  }

  /// Subscribes to incoming R-Cards from the credentials SDK and surfaces
  /// each received card as a chat attachment.
  Future<void> subscribeToIncomingRCards() async {
    final credentialsSDK = await _ref.read(credentialsSdkProvider.future);
    _subscription = credentialsSDK.receivedRCards.listen(
      _onRCardReceived,
      onError: (Object error, StackTrace stackTrace) {
        _logger.error(
          'Error in incoming R-Card stream',
          error: error,
          stackTrace: stackTrace,
          name: _logKey,
        );
      },
    );
  }

  /// Sends an R-Card from the given [identity] and posts the issued credential
  /// into the chat as an outgoing attachment.
  Future<void> sendRCardFromPlugin(Identity identity) async {
    try {
      final coreSdk = await _ref.read(meetingPlaceSdkProvider.future);
      final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
        _otherPartyPermanentDid,
      );
      if (channel == null) {
        _logger.warning(
          'sendRCardFromPlugin: channel not found for $_otherPartyPermanentDid',
          name: _logKey,
        );
        return;
      }

      final channelDid = channel.permanentChannelDid;
      final otherDid = channel.otherPartyPermanentChannelDid;
      if (channelDid == null || otherDid == null) return;

      final didManager = await coreSdk.getDidManager(channelDid);
      final credentialsSDK = await _ref.read(credentialsSdkProvider.future);
      final rCard = await credentialsSDK.sendRCard(
        channel: channel,
        subjectDid: identity.did,
        card: identity.card.toRCardSubject(),
        issuerDidManager: didManager,
      );

      final vcJson = jsonDecode(rCard.vcBlob) as Map<String, dynamic>;
      final attachments = RCardDIDCommAttachmentBuilder.fromVcJson(vcJson);
      await _chatSdk?.createAttachmentMessage(
        attachments: attachments,
        senderDid: channelDid,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to send R-Card from plugin',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }

  /// Sends an R-Card profile update in response to a [ConciergeMessage],
  /// confirms the message, and shows the issued credential as an outgoing
  /// attachment.
  Future<void> sendProfileUpdateWithRCard(ConciergeMessage message) async {
    try {
      final coreSdk = await _ref.read(meetingPlaceSdkProvider.future);
      final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
        _otherPartyPermanentDid,
      );
      if (channel == null) return;

      final externalRef = channel.externalRef;
      if (externalRef == null || externalRef.isEmpty) return;

      final identity = _ref
          .read(identitiesServiceProvider)
          .getIdentityById(externalRef);
      if (identity == null || identity.did.isEmpty) return;

      final channelDid = channel.permanentChannelDid;
      if (channelDid == null || channelDid.isEmpty) return;

      final otherDid = channel.otherPartyPermanentChannelDid;
      if (otherDid == null || otherDid.isEmpty) return;

      final didManager = await coreSdk.getDidManager(channelDid);
      final credentialsSDK = await _ref.read(credentialsSdkProvider.future);
      final rCard = await credentialsSDK.sendRCard(
        channel: channel,
        subjectDid: identity.did,
        card: identity.card.toRCardSubject(),
        issuerDidManager: didManager,
      );

      final confirmedMessage = ConciergeMessage(
        chatId: message.chatId,
        messageId: message.messageId,
        senderDid: message.senderDid,
        isFromMe: message.isFromMe,
        dateCreated: message.dateCreated,
        status: ChatItemStatus.confirmed,
        conciergeType: message.conciergeType,
        data: {
          ...message.data,
          'messageType': 'rCardUpdated',
          'subjectDid': identity.did,
        },
      );

      final chatRepository = await _ref.read(chatRepositoryProvider.future);
      await chatRepository.updateMesssage(confirmedMessage);
      _upsertChatItem(confirmedMessage);

      final vcJson = jsonDecode(rCard.vcBlob) as Map<String, dynamic>;
      final attachments = RCardDIDCommAttachmentBuilder.fromVcJson(
        vcJson,
        isUpdate: true,
      );
      await _chatSdk?.createAttachmentMessage(
        attachments: attachments,
        senderDid: channelDid,
      );
    } catch (e, st) {
      _logger.error(
        'Failed to send profile update with R-Card',
        error: e,
        stackTrace: st,
        name: _logKey,
      );
    }
  }

  Future<void> _onRCardReceived(RCard rCard) async {
    try {
      final chatSdk = _chatSdk;
      if (chatSdk == null) return;

      final coreSdk = await _ref.read(meetingPlaceSdkProvider.future);
      final channel = await coreSdk.getChannelByOtherPartyPermanentDid(
        _otherPartyPermanentDid,
      );
      if (channel == null) return;

      final otherDid = channel.otherPartyPermanentChannelDid;
      if (otherDid == null) return;

      if (rCard.issuerDid != otherDid) return;

      // Drain the pending cache so replayPendingRCard() does not re-deliver
      // this card when the chat screen is re-entered after the live stream
      // already delivered it.
      final credentialsSDK = await _ref.read(credentialsSdkProvider.future);
      credentialsSDK.consumePendingRCard(_otherPartyPermanentDid);

      final vcJson = jsonDecode(rCard.vcBlob) as Map<String, dynamic>;
      final attachments = RCardDIDCommAttachmentBuilder.fromVcJson(vcJson);
      await chatSdk.createAttachmentMessage(
        attachments: attachments,
        senderDid: otherDid,
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Failed to surface incoming R-Card as chat tile',
        error: error,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }
}
