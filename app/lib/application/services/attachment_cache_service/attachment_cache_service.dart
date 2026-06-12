import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/extensions/chat_attachment_extensions.dart';
import '../../../infrastructure/extensions/string_list_extensions.dart';
import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/plugins/media_category.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../chat_service/chat_service.dart';
import '../chat_service/chat_session_service.dart';
import '../chat_service/local_voice_message_data.dart';
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
  final Map<String, LocalVoiceMessageData> _localVoiceMessages = {};

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
    ].nonEmpty.toList();

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

  /// Loads an attachment into the cache. Handles legacy base64-encoded
  /// attachments, locally recorded voice messages, and hosted media downloaded
  /// via the attachment's transportId.
  ///
  /// Returns `true` when a load was started or resolved synchronously, and
  /// `false` when the attachment is already cached or cannot be loaded yet.
  bool loadAttachment(ChatAttachment attachment) {
    final key = cacheKey(attachment);
    if (state[key] != null) return false;

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
      return true;
    }

    final localVoiceMessage = localVoiceMessageFor(attachment);
    if (localVoiceMessage != null) {
      _writeCache(key, localVoiceMessage.bytes);
      return true;
    }

    // Outgoing hosted-media attachments are pushed optimistically without a
    // transportId until the upload completes; downloading then would fail and
    // poison the cache. Skip and wait for the post-upload state push.
    if (attachment.transportId == null) return false;

    unawaited(_downloadAndCache(key, attachment));
    return true;
  }

  /// Retries a previously failed download. A failed download is recorded as an
  /// empty cache entry, so this clears it and re-runs the download flow.
  bool retry(ChatAttachment attachment) {
    final key = cacheKey(attachment);
    if (_attachmentsLoading.contains(key)) return false;

    final current = state[key];
    if (current == null || current.isNotEmpty) return false;

    state = {...state}..remove(key);
    unawaited(_downloadAndCache(key, attachment));
    return true;
  }

  /// Preloads hosted media that should be available without a manual tap:
  /// images and audio (including voice messages). Larger media (video,
  /// documents) is downloaded on demand to avoid eagerly fetching big payloads.
  void preload(List<chat.ChatItem> messages) {
    for (final message in messages.whereType<chat.Message>()) {
      for (final attachment in message.attachments) {
        if (attachment.format != AttachmentFormat.hostedMedia.value) continue;
        final category = mediaCategoryFromMimeType(attachment.mediaType);
        if (category == MediaCategory.image || attachment.isVoice) {
          loadAttachment(attachment);
        }
      }
    }
  }

  /// Caches a just-recorded voice message so the sender sees it immediately and
  /// can replay it before the upload/download round-trip completes.
  void cacheLocalVoiceMessage(
    ChatAttachment attachment,
    Uint8List bytes, {
    required int durationMs,
    required List<int> waveform,
  }) {
    _writeCache(cacheKey(attachment), bytes);
    final key = _localVoiceMessageKey(attachment);
    if (key != null) {
      _localVoiceMessages[key] = LocalVoiceMessageData(
        bytes: bytes,
        durationMs: durationMs,
        waveform: waveform,
      );
    }
  }

  /// Returns the locally retained payload for a voice message sent from this
  /// device, or `null` if none was recorded in this session.
  LocalVoiceMessageData? localVoiceMessageFor(ChatAttachment attachment) {
    final key = _localVoiceMessageKey(attachment);
    if (key == null) return null;
    return _localVoiceMessages[key];
  }

  /// Drops the locally retained payload for a voice message, e.g. after a send
  /// failure so a later retry re-reads from source.
  void removeLocalVoiceMessage(ChatAttachment attachment) {
    final key = _localVoiceMessageKey(attachment);
    if (key != null) {
      _localVoiceMessages.remove(key);
    }
  }

  /// Backfills duration/waveform metadata on the sender's own voice messages
  /// from the locally cached recording, so the bubble shows the waveform and
  /// duration before the hosted copy round-trips back from the homeserver.
  ///
  /// Returns the original list unchanged when no message needed backfilling.
  List<chat.ChatItem> withLocalVoiceMetadata(List<chat.ChatItem> messages) {
    var didChange = false;
    final nextMessages = messages
        .map((item) {
          if (item is! chat.Message || !item.isFromMe) return item;

          var messageDidChange = false;
          final nextAttachments = item.attachments
              .map((attachment) {
                if (!attachment.isVoice) return attachment;
                final localVoiceMessage = localVoiceMessageFor(attachment);
                if (localVoiceMessage == null) return attachment;
                final voice = chat.VoiceMessageMetadata.of(attachment);
                if (voice?.waveform?.isNotEmpty == true &&
                    voice?.durationMs != null) {
                  return attachment;
                }

                messageDidChange = true;
                didChange = true;
                return ChatAttachment(
                  id: attachment.id,
                  description: attachment.description,
                  filename: attachment.filename,
                  mediaType: attachment.mediaType,
                  format: attachment.format,
                  lastModifiedTime: attachment.lastModifiedTime,
                  data: attachment.data,
                  byteCount: attachment.byteCount,
                  transportId: attachment.transportId,
                  metadata: chat.VoiceMessageMetadata(
                    durationMs:
                        voice?.durationMs ?? localVoiceMessage.durationMs,
                    waveform: voice?.waveform?.isNotEmpty == true
                        ? voice!.waveform
                        : localVoiceMessage.waveform,
                  ).toMetadata(),
                );
              })
              .toList(growable: false);

          if (!messageDidChange) return item;
          return chat.Message(
            chatId: item.chatId,
            messageId: item.messageId,
            senderDid: item.senderDid,
            isFromMe: item.isFromMe,
            dateCreated: item.dateCreated,
            status: item.status,
            type: item.type,
            value: item.value,
            attachments: nextAttachments,
            reactions: item.reactions,
            editedAt: item.editedAt,
            transportId: item.transportId,
            isDeleted: item.isDeleted,
            isDeletedLocally: item.isDeletedLocally,
          );
        })
        .toList(growable: false);

    return didChange ? nextMessages : messages;
  }

  String? _localVoiceMessageKey(ChatAttachment attachment) {
    final id = attachment.id;
    if (id == null || id.isEmpty) return null;
    return id;
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
