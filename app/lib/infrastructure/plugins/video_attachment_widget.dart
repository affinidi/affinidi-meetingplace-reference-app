import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

import '../../application/services/voice_playback_service/voice_playback_service.dart';
import '../../presentation/screens/media/video_player_screen/video_player_screen.dart';
import '../extensions/build_context_extensions.dart';
import 'attachment_plugin_cache.dart';

class VideoAttachmentWidget extends ConsumerStatefulWidget {
  const VideoAttachmentWidget({
    super.key,
    required this.attachment,
    required this.cacheManager,
    required this.cacheKey,
    this.playbackScopeId,
    this.download,
  });

  final ChatAttachment attachment;
  final BaseCacheManager cacheManager;
  final String cacheKey;
  final String? playbackScopeId;
  final Future<Uint8List> Function(ChatAttachment)? download;

  @override
  ConsumerState<VideoAttachmentWidget> createState() =>
      _VideoAttachmentWidgetState();
}

class _VideoAttachmentWidgetState extends ConsumerState<VideoAttachmentWidget> {
  Uint8List? _bytes;
  bool _isDownloading = false;
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    final base64Data = widget.attachment.data?.base64;
    if (base64Data != null) {
      try {
        _bytes = base64.decode(base64Data);
      } catch (_) {}
      return;
    }
    unawaited(_loadFromDiskCache());
  }

  Future<void> _loadFromDiskCache() async {
    final cachedBytes = await widget.cacheManager.readBytes(widget.cacheKey);
    if (cachedBytes == null || !mounted) return;
    setState(() => _bytes = cachedBytes);
  }

  Future<void> _download() async {
    if (_isDownloading || _bytes != null) return;

    final downloadFn = widget.download;
    if (downloadFn == null) return;

    setState(() {
      _isDownloading = true;
      _hasFailed = false;
    });

    try {
      final bytes = await widget.cacheManager.downloadBytes(
        cacheKey: widget.cacheKey,
        download: () => downloadFn(widget.attachment),
      );
      if (!mounted) return;
      if (bytes.isEmpty) {
        setState(() {
          _isDownloading = false;
          _hasFailed = true;
        });
        return;
      }
      setState(() {
        _bytes = bytes;
        _isDownloading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _hasFailed = true;
      });
    }
  }

  Future<void> _openPlayer() async {
    final bytes = _bytes;
    if (bytes == null) return;

    final playbackScopeId = widget.playbackScopeId;
    if (playbackScopeId != null) {
      await ref
          .read(voicePlaybackServiceProvider(playbackScopeId).notifier)
          .stop();
    }

    if (!mounted) return;

    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => VideoPlayerScreen(
          videoBytes: bytes,
          filename: widget.attachment.filename,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasFailed) {
      return SizedBox(
        height: 200,
        width: 200,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _download,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.broken_image_outlined, size: 32),
                const SizedBox(height: 8),
                const Icon(Icons.refresh, size: 20),
                const SizedBox(height: 4),
                Text(
                  context.l10n.mediaTapToRetry,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bytes = _bytes;
    if (bytes == null) {
      return SizedBox(
        height: 200,
        width: 200,
        child: GestureDetector(
          onTap: _isDownloading ? null : _download,
          child: Card(
            color: const Color.fromARGB(0, 10, 10, 10),
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            child: Center(
              child: _isDownloading
                  ? const CircularProgressIndicator()
                  : const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.video_file, color: Colors.white70, size: 48),
                        SizedBox(height: 8),
                        Icon(Icons.download, color: Colors.white70, size: 24),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      width: 200,
      child: GestureDetector(
        onTap: () => unawaited(_openPlayer()),
        child: Card(
          color: const Color.fromARGB(0, 10, 10, 10),
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child: const Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 56,
            ),
          ),
        ),
      ),
    );
  }
}
