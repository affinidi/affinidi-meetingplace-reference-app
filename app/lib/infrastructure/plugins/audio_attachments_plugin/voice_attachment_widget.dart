import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:mpx_app_core/mpx_app_core.dart';

import '../attachment_plugin_cache.dart';
import 'local_voice_attachment_store.dart';
import 'voice_attachment_playback.dart';

class VoiceAttachmentWidget extends HookWidget {
  const VoiceAttachmentWidget({
    super.key,
    required this.attachment,
    required this.isFromMe,
    required this.chatItemColor,
    required this.cacheManager,
    required this.localVoiceStore,
    this.avatarImage,
    this.download,
  });

  final ChatAttachment attachment;
  final bool isFromMe;
  final Color chatItemColor;
  final BaseCacheManager cacheManager;
  final LocalVoiceAttachmentStore localVoiceStore;
  final ImageProvider<Object>? avatarImage;
  final Future<Uint8List> Function(ChatAttachment)? download;

  @override
  Widget build(BuildContext context) {
    final bytes = useState<Uint8List?>(_initialBytes());
    final isDownloading = useState(false);
    final hasFailed = useState(false);
    final playRequested = useState(false);

    Future<void> loadBytes({required bool markFailure}) async {
      final downloadFn = download;
      if (downloadFn == null) return;

      isDownloading.value = true;
      hasFailed.value = false;

      try {
        final cachedBytes = await readCachedAttachmentBytes(
          cacheManager,
          attachment,
        );
        if (cachedBytes != null) {
          bytes.value = cachedBytes;
          return;
        }

        final downloaded = await downloadFn(attachment);
        if (downloaded.isEmpty) {
          if (markFailure) hasFailed.value = true;
          return;
        }

        await writeCachedAttachmentBytes(cacheManager, attachment, downloaded);
        bytes.value = downloaded;
      } catch (_) {
        if (markFailure) hasFailed.value = true;
      } finally {
        isDownloading.value = false;
      }
    }

    useEffect(() {
      if (bytes.value != null) return null;
      unawaited(
        readCachedAttachmentBytes(cacheManager, attachment).then((cached) {
          if (cached != null) bytes.value = cached;
        }),
      );
      return null;
    }, [attachment.id, attachment.transportId]);

    final cachedBytes = bytes.value;
    final levels = voiceLevelsForAttachment(attachment, cachedBytes);
    final durationMs =
        chat.VoiceMessageMetadata.of(attachment)?.durationMs ?? 0;

    if (cachedBytes == null) {
      final isLoading = isDownloading.value && !hasFailed.value;

      Future<void> onPressed() async {
        if (hasFailed.value) {
          playRequested.value = true;
          await loadBytes(markFailure: true);
          return;
        }
        if (isDownloading.value) return;
        playRequested.value = true;
        await loadBytes(markFailure: true);
      }

      return VoiceAttachmentBubble(
        isFromMe: isFromMe,
        chatItemColor: chatItemColor,
        isPlaying: false,
        isLoading: isLoading,
        duration: Duration(milliseconds: durationMs),
        levels: levels,
        progress: 0,
        avatarImage: avatarImage,
        onPressed: () => unawaited(onPressed()),
      );
    }

    return VoiceAttachmentPlayer(
      bytes: cachedBytes,
      mediaType: attachment.mediaType,
      initialDuration: Duration(milliseconds: durationMs),
      autoPlay: playRequested.value,
      onAutoPlayed: () => playRequested.value = false,
      builder: (context, state) => VoiceAttachmentBubble(
        isFromMe: isFromMe,
        chatItemColor: chatItemColor,
        isPlaying: state.isPlaying,
        duration: state.duration,
        levels: levels,
        progress: state.progress,
        avatarImage: avatarImage,
        onPressed: state.toggle,
      ),
    );
  }

  Uint8List? _initialBytes() {
    final localVoice = localVoiceStore.localVoiceMessageFor(attachment);
    if (localVoice != null) return localVoice.bytes;

    final base64Data = attachment.data?.base64;
    if (base64Data == null) return null;
    try {
      return base64.decode(base64Data);
    } catch (_) {
      return null;
    }
  }
}
