import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:meeting_place_core/meeting_place_core.dart';
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
import 'chat_media_bytes_cache.dart';

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

  // Hosted media lives in Matrix timeline events that are decrypted
  // asynchronously after the room syncs. Until decryption completes a download
  // fails with an `m.room.encrypted` error, so auto-loads retry on this backoff
  // (one entry per follow-up attempt) instead of giving up or poisoning the
  // cache with a permanent failure the user never triggered.
  static const _autoRetryBackoff = <Duration>[
    Duration(milliseconds: 500),
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 8),
  ];

  late final AppLogger _logger;
  late final String _contactId;
  late final ChatMediaBytesCache _bytesCache;
  ChatService? _chatService;
  final Set<String> _attachmentsLoading = {};
  final Set<String> _localProbesInFlight = {};
  final Set<Timer> _autoRetryTimers = {};
  final Map<String, LocalVoiceMessageData> _localVoiceMessages = {};
  bool _isDisposed = false;

  @override
  Map<String, Uint8List> build(String contactId) {
    _isDisposed = false;
    _contactId = contactId;
    _logger = ref.read(appLoggerProvider);
    _bytesCache = ref.read(chatMediaBytesCacheProvider);
    ref.onDispose(() {
      _isDisposed = true;
      for (final timer in _autoRetryTimers) {
        timer.cancel();
      }
      _autoRetryTimers.clear();
    });

    final contact = ref.read(contactsServiceProvider).getContactById(contactId);
    final channelDid = contact?.channelDid;
    if (channelDid != null) {
      _chatService = ref.read(chatSessionServiceProvider(channelDid).notifier);
    }

    // Seed from the process-lifetime warm cache so re-entering a chat renders
    // its already-decrypted media immediately instead of showing a spinner per
    // image while it re-downloads and re-decrypts.
    return {..._bytesCache.snapshotFor(contactId)};
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
      _writeCache(
        cacheKey(attachment),
        base64.decode(base64Data),
        attachment: attachment,
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to decode attachment base64 in seed',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }

  /// Loads an attachment into the cache in response to an explicit user action
  /// (tapping a video, document, or voice bubble). Handles legacy base64
  /// attachments, locally recorded voice messages, and hosted media downloaded
  /// via the attachment's transportId. A failed hosted download is recorded as
  /// an empty cache entry so the bubble can surface a retry affordance.
  ///
  /// Returns `true` when a load was started or resolved synchronously, and
  /// `false` when the attachment is already cached or cannot be loaded yet.
  bool loadAttachment(ChatAttachment attachment) {
    return _load(
      attachment,
      markFailedOnError: true,
      logFailure: true,
      retryAttempt: null,
    );
  }

  /// Loads an attachment without any user interaction (preload, image bubbles).
  ///
  /// Hosted media download failures are silent and never poison the cache:
  /// historical Matrix events decrypt asynchronously after the room syncs, so a
  /// failed attempt is retried on a backoff until the bytes become available.
  bool autoLoad(ChatAttachment attachment) {
    return _load(
      attachment,
      markFailedOnError: false,
      logFailure: false,
      retryAttempt: 0,
    );
  }

  bool _load(
    ChatAttachment attachment, {
    required bool markFailedOnError,
    required bool logFailure,
    required int? retryAttempt,
  }) {
    final key = cacheKey(attachment);
    if (state[key] != null) return false;

    final base64Data = attachment.data?.base64;
    if (base64Data != null) {
      try {
        _writeCache(key, base64.decode(base64Data), attachment: attachment);
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
      _writeCache(key, localVoiceMessage.bytes, attachment: attachment);
      return true;
    }

    // Outgoing hosted-media attachments are pushed optimistically without a
    // transportId until the upload completes; downloading then would fail and
    // poison the cache. Skip and wait for the post-upload state push.
    if (attachment.transportId == null) return false;

    unawaited(
      _downloadAndCache(
        key,
        attachment,
        markFailedOnError: markFailedOnError,
        logFailure: logFailure,
        retryAttempt: retryAttempt,
      ),
    );
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
    unawaited(
      _downloadAndCache(
        key,
        attachment,
        markFailedOnError: true,
        logFailure: true,
        retryAttempt: null,
      ),
    );
    return true;
  }

  /// Restores an already-downloaded hosted attachment from the SDK's on-disk
  /// media cache without contacting the homeserver, so media the user
  /// previously downloaded renders its play/open state on chat re-entry instead
  /// of a download affordance. Used for tap-to-download media (video,
  /// documents, non-voice audio) that is not eagerly auto-loaded.
  ///
  /// A local-cache miss is silent and leaves the cache untouched, so the
  /// download affordance stays and the user can still fetch the media on tap.
  Future<void> restoreFromLocalCache(ChatAttachment attachment) async {
    final key = cacheKey(attachment);
    if (state[key] != null) return;
    // Outgoing attachments without a transportId have no hosted copy to probe.
    if (attachment.transportId == null) return;
    // Guard with a probe-only set, not [_attachmentsLoading], so a concurrent
    // user-initiated download is never suppressed by an in-flight probe.
    if (_localProbesInFlight.contains(key)) return;
    _localProbesInFlight.add(key);

    try {
      final bytes = await _chatService?.downloadMedia(
        attachment,
        localOnly: true,
      );
      if (_isDisposed) return;
      // A user-initiated download may have populated the cache while the probe
      // was in flight; don't clobber it.
      if (state[key] == null && bytes != null && bytes.isNotEmpty) {
        _writeCache(key, bytes, attachment: attachment);
      }
    } catch (_) {
      // Not in the local cache yet (or cache miss): keep the download
      // affordance rather than poisoning the cache with a failure marker.
    } finally {
      _localProbesInFlight.remove(key);
    }
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
          autoLoad(attachment);
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
    _writeCache(cacheKey(attachment), bytes, attachment: attachment);
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
    ChatAttachment attachment, {
    required bool markFailedOnError,
    required bool logFailure,
    required int? retryAttempt,
  }) async {
    if (_attachmentsLoading.contains(cacheKey)) return;
    _attachmentsLoading.add(cacheKey);

    try {
      final bytes = await _chatService?.downloadMedia(attachment);
      if (bytes == null) {
        if (logFailure) {
          _logger.warning(
            'Chat service unavailable, skipping media download',
            name: _logKey,
          );
        }
        if (markFailedOnError) _writeCache(cacheKey, Uint8List(0));
        _scheduleAutoRetry(cacheKey, attachment, retryAttempt);
        return;
      }

      _writeCache(cacheKey, bytes, attachment: attachment);
    } catch (e, stackTrace) {
      if (logFailure) {
        _logger.error(
          'Failed to download media attachment',
          error: e,
          stackTrace: stackTrace,
          name: _logKey,
        );
      }
      if (markFailedOnError) _writeCache(cacheKey, Uint8List(0));
      _scheduleAutoRetry(cacheKey, attachment, retryAttempt);
    } finally {
      _attachmentsLoading.remove(cacheKey);
    }
  }

  /// Schedules a follow-up auto-load when [retryAttempt] is within the backoff
  /// schedule. Hosted media events decrypt asynchronously after the room syncs,
  /// so a failed auto-load is retried until the bytes become available rather
  /// than left as a permanently empty bubble.
  void _scheduleAutoRetry(
    String cacheKey,
    ChatAttachment attachment,
    int? retryAttempt,
  ) {
    if (retryAttempt == null || retryAttempt >= _autoRetryBackoff.length) {
      return;
    }

    late final Timer timer;
    timer = Timer(_autoRetryBackoff[retryAttempt], () {
      _autoRetryTimers.remove(timer);
      if (_isDisposed || state[cacheKey] != null) return;
      unawaited(
        _downloadAndCache(
          cacheKey,
          attachment,
          markFailedOnError: false,
          logFailure: false,
          retryAttempt: retryAttempt + 1,
        ),
      );
    });
    _autoRetryTimers.add(timer);
  }

  void _writeCache(
    String cacheKey,
    Uint8List bytes, {
    ChatAttachment? attachment,
  }) {
    state = {...state, cacheKey: bytes};
    if (attachment != null && _isWarmCacheable(attachment)) {
      _bytesCache.put(_contactId, cacheKey, bytes);
    }
  }

  /// Whether [attachment] is small, auto-displayed media worth retaining in the
  /// process-lifetime warm cache. Large tap-to-open media (video, documents) is
  /// excluded so it cannot evict the images the warm cache exists to keep.
  bool _isWarmCacheable(ChatAttachment attachment) {
    if (attachment.isVoice) return true;
    return mediaCategoryFromMimeType(attachment.mediaType) ==
        MediaCategory.image;
  }
}
