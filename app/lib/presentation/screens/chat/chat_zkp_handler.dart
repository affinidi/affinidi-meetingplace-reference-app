import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

import '../../../application/services/zkp_service/zkp_constants.dart';
import '../../../domain/models/chat/zkp_paused_notice.dart';
import '../../../domain/models/chat/zkp_proof_received_notice.dart';
import '../../../domain/models/chat/zkp_proof_shared_notice.dart';
import '../../../domain/models/chat/zkp_request_received_notice.dart';
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
    required this.onPersistZkpNotice,
  });

  final Ref ref;
  final AppLogger logger;
  final String logKey;
  final bool isZkpEnabled;
  final Contact? Function() getContact;
  final void Function(chat.ChatItem item) onUpsertChatItem;
  final Future<void> Function(chat.ChatItem item) onPersistZkpNotice;

  void handleZkpAttachment(chat.StreamData data, String channelDid) {
    if (!isZkpEnabled) return;
    final plainTextMessage = data.plainTextMessage;
    if (plainTextMessage == null) return;
    final attachments = plainTextMessage.attachments;
    if (attachments == null || attachments.isEmpty) return;

    for (final attachment in attachments) {
      if (attachment.format == ZkpConstants.livenessCheckRequestType) {
        _handleLivenessRequest(channelDid, data);
        break;
      }

      if (attachment.format == ZkpConstants.livenessProofType) {
        _handleLivenessProof(channelDid, data);
        break;
      }
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

  void _handleLivenessProof(String channelDid, chat.StreamData data) {
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

    final plainTextMessage = data.plainTextMessage;
    if (plainTextMessage == null) {
      logger.warning('  No plainTextMessage found in data', name: logKey);
      return;
    }

    final attachments = plainTextMessage.attachments;
    if (attachments == null || attachments.isEmpty) {
      logger.warning('  No attachments found', name: logKey);
      return;
    }

    final attachment = attachments.firstWhere(
      (att) => att.format == ZkpConstants.livenessProofType,
      orElse: () => chat.Attachment(
        id: '',
        mediaType: '',
        format: '',
        lastModifiedTime: DateTime.now(),
      ),
    );

    if (attachment.format == null ||
        attachment.format!.isEmpty ||
        attachment.data?.json == null) {
      logger.warning('  No proof data found in attachment', name: logKey);
      return;
    }

    final proofData =
        jsonDecode(attachment.data!.json!) as Map<String, dynamic>;
    ref
        .read(proofFlowControllerProvider(contact.id).notifier)
        .onProofReceived(proofData);
  }

  Future<void> insertZkpPausedNotice({
    String? pausedForNoticeMessageId,
    bool persist = true,
  }) async {
    if (!isZkpEnabled) return;
    final contact = getContact();
    if (contact == null || contact.channelDid == null) return;

    final notice = ZkpPausedNotice(
      chatId: contact.channelDid!,
      dateCreated: DateTime.now(),
      // When pausing an incoming proof request, make the paused notice
      // deterministic so the UI can hide the request notice after Do-later.
      messageId: pausedForNoticeMessageId == null
          ? null
          : 'zkp-paused-$pausedForNoticeMessageId',
    );
    onUpsertChatItem(notice);
    if (persist) {
      await _persistNoticeSafely(notice);
    }
  }

  Future<void> insertZkpProofSharedNotice() async {
    if (!isZkpEnabled) return;
    final contact = getContact();
    if (contact == null || contact.channelDid == null) return;

    final notice = ZkpProofSharedNotice(
      chatId: contact.channelDid!,
      dateCreated: DateTime.now(),
    );
    onUpsertChatItem(notice);
    await _persistNoticeSafely(notice);
  }

  Future<void> insertZkpProofReceivedNotice() async {
    if (!isZkpEnabled) return;
    final contact = getContact();
    if (contact == null || contact.channelDid == null) return;

    final contactName = contact.displayName?.isNotEmpty == true
        ? contact.displayName!
        : contact.card.firstName;

    final notice = ZkpProofReceivedNotice(
      chatId: contact.channelDid!,
      dateCreated: DateTime.now(),
      contactName: contactName,
    );
    onUpsertChatItem(notice);
    await _persistNoticeSafely(notice);
  }

  Future<void> insertZkpRequestReceivedNotice() async {
    if (!isZkpEnabled) return;
    final contact = getContact();
    if (contact == null || contact.channelDid == null) return;

    final contactName = contact.displayName?.isNotEmpty == true
        ? contact.displayName!
        : contact.card.firstName;

    final notice = ZkpRequestReceivedNotice(
      chatId: contact.channelDid!,
      dateCreated: DateTime.now(),
      contactName: contactName,
    );
    onUpsertChatItem(notice);
    await _persistNoticeSafely(notice);
  }

  Future<void> _persistNoticeSafely(chat.ChatItem notice) async {
    try {
      await onPersistZkpNotice(notice);
    } catch (e, st) {
      logger.error(
        'Failed to persist ZKP notice',
        error: e,
        stackTrace: st,
        name: logKey,
      );
    }
  }
}
