import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_relationship/meeting_place_relationship.dart';

import '../../../application/services/zkp_service/zkp_concierge_messages.dart';
import '../../../domain/models/contacts/contact.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import 'proof_flow_controller.dart';

class ChatZkpHandler {
  ChatZkpHandler({
    required this.ref,
    required this.logger,
    required this.logKey,
    required this.isZkpEnabled,
    required this.getContact,
    required this.onUpsertChatItem,
  });

  final Ref ref;
  final AppLogger logger;
  final String logKey;
  final bool isZkpEnabled;
  final Contact? Function() getContact;
  final void Function(chat.ChatItem item) onUpsertChatItem;

  void handleZkpAttachment(chat.StreamData data, String channelDid) {
    if (!isZkpEnabled) return;
    final plainTextMessage = data.plainTextMessage;
    if (plainTextMessage == null) return;
    final attachments = plainTextMessage.attachments;
    if (attachments == null || attachments.isEmpty) return;

    if (LivenessZkpAttachmentParser.tryParseRequestIn(attachments) != null) {
      _handleLivenessRequest(channelDid, data);
      return;
    }

    final proofPayload = LivenessZkpAttachmentParser.tryParseProofIn(
      attachments,
    );
    if (proofPayload != null) {
      _handleLivenessProof(channelDid, data, proofPayload);
    }
  }

  void _handleLivenessRequest(String channelDid, chat.StreamData data) {
    final contact = getContact();
    if (contact == null || contact.channelDid != channelDid) return;

    final chatItem = data.chatItem;
    if (chatItem == null || chatItem.isFromMe) return;

    logger.info('Liveness request received from $channelDid', name: logKey);
    ref
        .read(proofFlowControllerProvider(contact.id).notifier)
        .onLivenessRequestReceived();
  }

  void _handleLivenessProof(
    String channelDid,
    chat.StreamData data,
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

    final chatItem = data.chatItem;
    if (chatItem == null || chatItem.isFromMe) {
      logger.info('  Skipping: chatItem null or isFromMe', name: logKey);
      return;
    }

    ref
        .read(proofFlowControllerProvider(contact.id).notifier)
        .onProofReceived(proofPayload);
  }

  Future<void> insertZkpPausedNotice({String? pausedForNoticeMessageId}) async {
    if (!isZkpEnabled) return;
    final contact = getContact();
    if (contact == null || contact.channelDid == null) return;

    final notice = ZkpConciergeMessages.humanZkpPaused(
      chatId: contact.channelDid!,
      dateCreated: DateTime.now(),
      pausedForRequestMessageId: pausedForNoticeMessageId,
    );
    onUpsertChatItem(notice);
  }
}
