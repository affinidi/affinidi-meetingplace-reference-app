import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../chat_service/chat_service.dart';
import '../chat_service/chat_session_service.dart';
import '../contacts_service/contacts_service.dart';

part 'attachment_cache_service.g.dart';

/// Holds decrypted attachment bytes for a chat, keyed by
/// [AttachmentCacheService.cacheKey].
///
/// Downloads hosted media via the [ChatService] and decodes legacy base64
/// attachments, deduplicating in-flight downloads. Owned per contact so the
/// chat screen and its widgets observe a single cache instance.
@riverpod
class AttachmentCacheService extends _$AttachmentCacheService {
  static const _logKey = 'ATTACHCACHE';

  late final AppLogger _logger;
  ChatService? _chatService;
  final Set<String> _attachmentsLoading = {};

  @override
  Map<String, Uint8List> build(String contactId) {
    _logger = ref.read(appLoggerProvider);

    final contact = ref.read(contactsServiceProvider).getContactById(contactId);
    final channelDid = contact?.channelDid;
    if (channelDid != null) {
      _chatService = ref.read(chatSessionServiceProvider(channelDid).notifier);
    }

    return const {};
  }

  /// Returns a stable string key for [attachment] suitable for use as a cache
  /// map key.
  ///
  /// Prefers the attachment's own [ChatAttachment.id], then its
  /// [ChatAttachment.transportId], and finally a composite of its data fields.
  static String cacheKey(ChatAttachment attachment) {
    final id = attachment.id;
    if (id != null && id.isNotEmpty) {
      return 'chat_attachment_$id';
    }

    final transportId = attachment.transportId;
    if (transportId != null && transportId.isNotEmpty) {
      return 'chat_attachment_transport_$transportId';
    }

    final parts = <String?>[
      attachment.data?.hash,
      attachment.data?.links?.firstOrNull?.toString(),
      attachment.filename,
      attachment.mediaType,
      attachment.description,
      attachment.byteCount?.toString(),
      attachment.data?.json,
    ].whereType<String>().where((part) => part.isNotEmpty).toList();

    if (parts.isEmpty) {
      return 'chat_attachment_${identityHashCode(attachment)}';
    }

    return 'chat_attachment_${parts.join('|')}';
  }

  /// Seeds the cache with the attachment's inline base64 so the sender sees
  /// the image immediately, before the upload/download round-trip completes.
  void seed(ChatAttachment attachment) {
    final base64Data = attachment.data?.base64;
    if (base64Data == null || base64Data.isEmpty) return;

    try {
      _writeCache(cacheKey(attachment), base64.decode(base64Data));
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to decode attachment base64 in seed',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }

  /// Loads an attachment into the cache. Handles both legacy base64-encoded
  /// attachments and hosted media downloaded via the attachment's transportId.
  void loadAttachment(ChatAttachment attachment) {
    final key = cacheKey(attachment);
    if (state[key] != null) return;

    final base64Data = attachment.data?.base64;
    if (base64Data != null) {
      try {
        _writeCache(key, base64.decode(base64Data));
      } catch (e, stackTrace) {
        _logger.error(
          'Failed to decode attachment base64',
          error: e,
          stackTrace: stackTrace,
          name: _logKey,
        );
      }
      return;
    }

    // Outgoing hosted-media attachments are pushed optimistically without a
    // transportId until the upload completes; downloading then would fail and
    // poison the cache. Skip and wait for the post-upload state push.
    if (attachment.transportId == null) return;

    _downloadAndCache(key, attachment);
  }

  /// Preloads every hosted-media attachment found in [messages].
  void preload(List<chat.ChatItem> messages) {
    for (final message in messages.whereType<chat.Message>()) {
      for (final attachment in message.attachments) {
        if (attachment.format == AttachmentFormat.hostedMedia.value) {
          loadAttachment(attachment);
        }
      }
    }
  }

  Future<void> _downloadAndCache(
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
        _writeCache(cacheKey, Uint8List(0));
        return;
      }

      _writeCache(cacheKey, bytes);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to download media attachment',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      _writeCache(cacheKey, Uint8List(0));
    } finally {
      _attachmentsLoading.remove(cacheKey);
    }
  }

  void _writeCache(String cacheKey, Uint8List bytes) {
    state = {...state, cacheKey: bytes};
  }
}
