import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

import '../../../domain/models/chat/zkp_paused_notice.dart';
import '../../../domain/models/chat/zkp_proof_received_notice.dart';
import '../../../domain/models/chat/zkp_proof_shared_notice.dart';
import '../../../domain/models/chat/zkp_request_received_notice.dart';
import '../../secure_storage/secure_storage.dart';

final zkpNoticesServiceProvider = Provider<ZkpNoticesService>(
  ZkpNoticesService.new,
);

class ZkpNoticesService {
  ZkpNoticesService(this._ref);

  final Ref _ref;

  Future<List<chat.ChatItem>> loadNotices(String channelDid) async {
    final storage = await _ref.read(secureStorageProvider.future);
    final records = await storage.getZkpNotices(channelDid);
    return records.map(_recordToNotice).whereType<chat.ChatItem>().toList();
  }

  Future<void> upsertNotice(chat.ChatItem notice) async {
    final storage = await _ref.read(secureStorageProvider.future);
    final records = List<Map<String, dynamic>>.from(
      await storage.getZkpNotices(notice.chatId),
    );
    final updatedRecord = _noticeToRecord(notice);
    if (updatedRecord == null) return;

    final idx = records.indexWhere(
      (item) => item['messageId'] == notice.messageId,
    );
    if (idx == -1) {
      records.add(updatedRecord);
    } else {
      records[idx] = updatedRecord;
    }
    await storage.saveZkpNotices(notice.chatId, records);
  }

  chat.ChatItem? _recordToNotice(Map<String, dynamic> record) {
    final messageId = record['messageId'] as String?;
    final chatId = record['chatId'] as String?;
    final dateCreatedMs = record['dateCreatedMs'] as int?;
    if (messageId == null || chatId == null || dateCreatedMs == null) {
      return null;
    }

    final dateCreated = DateTime.fromMillisecondsSinceEpoch(dateCreatedMs);
    final contactName = record['contactName'] as String?;

    if (messageId.startsWith('zkp-paused-')) {
      return ZkpPausedNotice(
        chatId: chatId,
        dateCreated: dateCreated,
        messageId: messageId,
      );
    }
    if (messageId.startsWith('zkp-proof-shared-')) {
      return ZkpProofSharedNotice(
        chatId: chatId,
        dateCreated: dateCreated,
        messageId: messageId,
      );
    }
    if (messageId.startsWith('zkp-proof-received-') && contactName != null) {
      return ZkpProofReceivedNotice(
        chatId: chatId,
        dateCreated: dateCreated,
        contactName: contactName,
        messageId: messageId,
      );
    }
    if (messageId.startsWith('zkp-request-received-') && contactName != null) {
      return ZkpRequestReceivedNotice(
        chatId: chatId,
        dateCreated: dateCreated,
        contactName: contactName,
        messageId: messageId,
      );
    }

    return null;
  }

  Map<String, dynamic>? _noticeToRecord(chat.ChatItem notice) {
    if (notice is! ZkpPausedNotice &&
        notice is! ZkpProofSharedNotice &&
        notice is! ZkpProofReceivedNotice &&
        notice is! ZkpRequestReceivedNotice) {
      return null;
    }

    return {
      'messageId': notice.messageId,
      'chatId': notice.chatId,
      'dateCreatedMs': notice.dateCreated.millisecondsSinceEpoch,
      'contactName': switch (notice) {
        ZkpProofReceivedNotice(:final contactName) => contactName,
        ZkpRequestReceivedNotice(:final contactName) => contactName,
        _ => null,
      },
    };
  }
}
