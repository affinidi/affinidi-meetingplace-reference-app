import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../presentation/screens/media/video_player_screen/video_player_screen.dart';
import '../attachment_plugin_cache.dart';
import 'video_attachment.dart';

/// A plugin for handling video attachments picked from the device gallery.
final class VideoAttachmentsPlugin implements AttachmentPlugin {
  VideoAttachmentsPlugin({required this._cacheManager});

  static const pluginName = 'mpx_video_attachment_plugin';

  final BaseCacheManager _cacheManager;

  int get _maxBytes => Environment.instance.chatAttachmentMaxBytes;

  @override
  bool get dismissSheetBeforePicking => false;

  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    BuildContext context,
  ) async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );

    if (video == null) return null;

    final sizeBytes = await video.length();
    if (sizeBytes > _maxBytes) {
      if (context.mounted) {
        _showTooLargeSnackBar(context);
      }
      return null;
    }

    final bytes = await video.readAsBytes();
    final base64Data = base64.encode(bytes);
    final mimeType = video.mimeType ?? 'video/mp4';
    final filename = video.name;

    return AttachmentPluginPickResult(
      text: '',
      attachments: [
        VideoAttachment(
          base64: base64Data,
          pluginName: pluginName,
          mimeType: mimeType,
          filename: filename,
          byteCount: bytes.length,
        ),
      ],
    );
  }

  void _showTooLargeSnackBar(BuildContext context) {
    final maxMb = _maxBytes ~/ (1024 * 1024);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.attachmentTooLarge(maxMb))),
    );
  }

  @override
  Widget renderAttachment({
    required ChatAttachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => _VideoAttachmentWidget(
    attachment: attachment,
    cacheManager: _cacheManager,
    download: download,
  );

  @override
  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => _ListVideoAttachmentsWidget(
    attachments: attachments,
    cacheManager: _cacheManager,
    download: download,
  );

  @override
  bool supportsFormat(ChatAttachment attachment) =>
      attachment.format == pluginName;

  @override
  AttachmentPluginIcon get icon => const EmojiIcon('🎬');

  @override
  String localizedName(BuildContext context) => context.l10n.generalVideo;

  @override
  bool get isPlatformSupported => true;
}

class _ListVideoAttachmentsWidget extends StatelessWidget {
  const _ListVideoAttachmentsWidget({
    required this._attachments,
    required this._cacheManager,
    this._download,
  });

  final List<ChatAttachment> _attachments;
  final BaseCacheManager _cacheManager;
  final Future<Uint8List> Function(ChatAttachment)? _download;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _attachments.length,
      itemBuilder: (context, index) => _VideoAttachmentWidget(
        attachment: _attachments[index],
        cacheManager: _cacheManager,
        download: _download,
      ),
    );
  }
}

class _VideoAttachmentWidget extends StatefulWidget {
  const _VideoAttachmentWidget({
    required this.attachment,
    required this.cacheManager,
    this.download,
  });

  final ChatAttachment attachment;
  final BaseCacheManager cacheManager;
  final Future<Uint8List> Function(ChatAttachment)? download;

  @override
  State<_VideoAttachmentWidget> createState() => _VideoAttachmentWidgetState();
}

class _VideoAttachmentWidgetState extends State<_VideoAttachmentWidget> {
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
    final cachedBytes = await readCachedAttachmentBytes(
      widget.cacheManager,
      widget.attachment,
    );
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
      final bytes = await downloadAndCacheAttachmentBytes(
        cacheManager: widget.cacheManager,
        attachment: widget.attachment,
        download: downloadFn,
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

  void _openPlayer() {
    final bytes = _bytes;
    if (bytes == null) return;

    Navigator.of(context, rootNavigator: true).push<void>(
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
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.video_file,
                          color: Colors.white70,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        const Icon(
                          Icons.download,
                          color: Colors.white70,
                          size: 24,
                        ),
                        if (widget.attachment.filename != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              left: 8,
                              right: 8,
                            ),
                            child: Text(
                              widget.attachment.filename!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
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
        onTap: _openPlayer,
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
