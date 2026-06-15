import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show
        LivenessZkpConciergeChatMapper,
        LivenessZkpConciergeIds,
        LivenessZkpConciergeMessages;
import 'package:meeting_place_credentials/meeting_place_credentials.dart'
    show
        LivenessCheckRequestPayload,
        LivenessProofPayload,
        LivenessZkpAttachmentParser;

import '../../../domain/models/contacts/contact.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import 'proof_flow_controller.dart';

class ChatZkpHandler {
  ChatZkpHandler({
    required this._ref,
    required this.logger,
    required this.logKey,
    required this.isZkpEnabled,
    required this.getContact,
    required this.onUpsertChatItem,
  });

  final Ref _ref;
  final AppLogger logger;
  final String logKey;
  final bool isZkpEnabled;
  final Contact? Function() getContact;
  final void Function(chat.ChatItem item) onUpsertChatItem;

  void handleZkpAttachment(chat.ChatItem chatItem, String channelDid) {
    if (!isZkpEnabled) return;
    if (chatItem is! chat.Message) return;

    final attachments = chatItem.attachments.map((a) => a.toCoreAttachment());
    if (attachments.isEmpty) return;

    final requestPayload = LivenessZkpAttachmentParser.tryParseRequestIn(
      attachments,
    );
    if (requestPayload != null) {
      _handleLivenessRequest(channelDid, chatItem, requestPayload);
      return;
    }

    final proofPayload = LivenessZkpAttachmentParser.tryParseProofIn(
      attachments,
    );
    if (proofPayload != null) {
      _handleLivenessProof(channelDid, chatItem, proofPayload);
    }
  }

  void _handleLivenessRequest(
    String channelDid,
    chat.ChatItem chatItem,
    LivenessCheckRequestPayload requestPayload,
  ) {
    final contact = getContact();
    if (contact == null || contact.channelDid != channelDid) return;

    if (chatItem.isFromMe) return;

    _ref
        .read(proofFlowControllerProvider(contact.id).notifier)
        .setVerifierChallengeNonce(requestPayload.challengeNonceBytes);

    logger.info('Liveness request received from $channelDid', name: logKey);
  }

  void _handleLivenessProof(
    String channelDid,
    chat.ChatItem chatItem,
    LivenessProofPayload proofPayload,
  ) {
    logger.info(
      '_handleLivenessProof called for channel: $channelDid',
      name: logKey,
    );

    final contact = getContact();
    if (contact == null || contact.channelDid != channelDid) {
      logger.warning('  Contact mismatch or not found', name: logKey);
      return;
    }

    if (chatItem.isFromMe) {
      logger.info('  Skipping: isFromMe', name: logKey);
      return;
    }

    unawaited(() async {
      try {
        final isVerified = await _ref
            .read(proofFlowControllerProvider(contact.id).notifier)
            .onProofReceived(proofPayload);

        if (!isVerified) {
          logger.info(
            '  Proof verification failed; badge notice not added',
            name: logKey,
          );
          return;
        }

        final contactName = contact.card.firstName.isNotEmpty
            ? contact.card.firstName
            : contact.card.displayName;
        final notice = LivenessZkpConciergeMessages.humanZkpProofReceived(
          chatId: chatItem.chatId,
          messageId: LivenessZkpConciergeIds.proofReceived(chatItem.messageId),
          dateCreated: chatItem.dateCreated,
          contactName: contactName,
        );
        onUpsertChatItem(
          LivenessZkpConciergeChatMapper.toConciergeMessage(notice),
        );
      } catch (error, stackTrace) {
        logger.error(
          'Unexpected error while verifying liveness proof',
          name: logKey,
          error: error,
          stackTrace: stackTrace,
        );
      }
    }());
  }

  Future<void> insertZkpPausedNotice({String? pausedForNoticeMessageId}) async {
    if (!isZkpEnabled) return;
    final contact = getContact();
    if (contact == null || contact.channelDid == null) return;

    final notice = LivenessZkpConciergeMessages.humanZkpPaused(
      chatId: contact.channelDid!,
      dateCreated: DateTime.now(),
      pausedForRequestNoticeMessageId: pausedForNoticeMessageId,
    );
    onUpsertChatItem(LivenessZkpConciergeChatMapper.toConciergeMessage(notice));
  }
}
