import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:uuid/uuid.dart';

import '../../../presentation/screens/media/image_view_screen/image_view_screen.dart';
import '../../../presentation/screens/media/media_screen/media_screen.dart';
import '../../extensions/build_context_extensions.dart';
import '../video_attachments_plugin/video_attachment.dart';
import '../video_attachments_plugin/video_attachments_plugin.dart';
import 'gallery_image_attachment.dart';

/// A plugin for handling gallery-based image attachments.
///
/// This plugin provides functionality to:
/// - Pick images from the device gallery via [MediaScreen]
/// - Review selected images before attaching
/// - Render image attachments as tappable cards in chat
/// - Support full-screen image viewing
class GalleryAttachmentsPlugin implements AttachmentPlugin {
  GalleryAttachmentsPlugin({required this._cacheManager});

  static const _pluginName = 'mpx_gallery_attachment_plugin';

  static String _cacheKeyForAttachment(String attachmentId) =>
      '$_pluginName:$attachmentId';

  final BaseCacheManager _cacheManager;

  @override
  bool get dismissSheetBeforePicking => false;

  /// Prompts the user to pick and review an image from gallery.
  ///
  /// Opens [MediaScreen] with gallery mode enabled. The user can select
  /// an image and optionally add a text message before confirming.
  ///
  /// Returns an [AttachmentPluginPickResult] containing the selected image
  /// and optional text, or `null` if cancelled or failed.
  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    BuildContext context,
  ) async {
    if (!context.mounted) return null;

    final result = await Navigator.push<MediaReviewResult>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const MediaScreen(useCamera: false, useChatSemantics: true);
        },
      ),
    );

    if (result == null) {
      return null;
    }

    if (!result.succeeded) {
      return null;
    }

    final videoBase64 = result.videoBase64;
    if (videoBase64 != null) {
      return AttachmentPluginPickResult(
        text: result.textMessage,
        attachments: [
          VideoAttachment(
            base64: videoBase64,
            pluginName: VideoAttachmentsPlugin.pluginName,
            mimeType: result.videoMimeType ?? 'video/mp4',
            filename: result.videoFilename ?? 'video.mp4',
            byteCount: result.videoByteCount ?? 0,
          ),
        ],
      );
    }

    final attachmentId = const Uuid().v4();
    final cacheKey = _cacheKeyForAttachment(attachmentId);
    await _cacheManager.putFile(cacheKey, result.compressedImage.bytes);

    return AttachmentPluginPickResult(
      text: result.textMessage,
      attachments: [
        GalleryImageAttachment(
          id: attachmentId,
          base64: result.compressedImage.base64,
          pluginName: _pluginName,
        ),
      ],
    );
  }

  /// Renders a single image attachment as a tappable card widget.
  ///
  /// Creates a 200x200 card with rounded corners that displays the image.
  /// Tapping opens the image in full-screen view via [ImageViewScreen].
  @override
  Widget renderAttachment({
    required ChatAttachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => _GalleryAttachmentWidget(
    attachment: attachment,
    cacheManager: _cacheManager,
    download: download,
  );

  /// Renders multiple image attachments as a scrollable list.
  ///
  /// Each attachment is rendered using [renderAttachment] in a vertical
  /// ListView with disabled scrolling physics.
  @override
  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => Column(
    children: List.generate(attachments.length, (index) {
      return _GalleryAttachmentWidget(
        key: ValueKey(attachments[index].id ?? index),
        attachment: attachments[index],
        cacheManager: _cacheManager,
        download: download,
      );
    }, growable: false),
  );

  /// Checks if this plugin supports the given attachment format.
  ///
  /// Returns `true` if the attachment format matches this plugin's name.
  @override
  bool supportsFormat(ChatAttachment attachment) {
    return attachment.format == _pluginName;
  }

  /// The emoji icon representing this plugin type.
  @override
  AttachmentPluginIcon get icon => const EmojiIcon('🖼');

  /// Returns the localized display name for this plugin.
  @override
  String localizedName(BuildContext context) => context.l10n.generalPhoto;

  /// Indicates this plugin is supported on all platforms.
  @override
  bool get isPlatformSupported => true;
}

/// Widget that renders a single gallery image attachment as a tappable card.
///
/// Features:
/// - 200x200 size with rounded corners and elevation
/// - When inline base64 data is available, renders using [MemoryImage]
/// - When no inline data but a [download] callback is provided, downloads once
///   and reuses the same future while the attachment identity stays the same
/// - Shows loading spinner while downloading
/// - Shows broken image icon on download error
/// - Returns empty widget if neither data nor callback are available
class _GalleryAttachmentWidget extends StatefulWidget {
  const _GalleryAttachmentWidget({
    super.key,
    required this.attachment,
    required this.cacheManager,
    this.download,
  });

  final ChatAttachment attachment;
  final BaseCacheManager cacheManager;
  final Future<Uint8List> Function(ChatAttachment)? download;

  @override
  State<_GalleryAttachmentWidget> createState() =>
      _GalleryAttachmentWidgetState();
}

class _GalleryAttachmentWidgetState extends State<_GalleryAttachmentWidget>
    with AutomaticKeepAliveClientMixin {
  Future<Uint8List>? _imageFuture;
  Uint8List? _resolvedImageBytes;
  late String _attachmentKey;

  String? _cacheKey(ChatAttachment attachment) {
    final id = attachment.id;
    if (id == null || id.isEmpty) return null;

    return GalleryAttachmentsPlugin._cacheKeyForAttachment(id);
  }

  Future<Uint8List> _loadImageBytes(
    ChatAttachment attachment,
    Future<Uint8List> Function(ChatAttachment) downloadFn,
  ) async {
    final cacheKey = _cacheKey(attachment);
    if (cacheKey != null) {
      final cachedFileInfo = await widget.cacheManager.getFileFromCache(
        cacheKey,
      );
      if (cachedFileInfo != null) {
        return cachedFileInfo.file.readAsBytes();
      }
    }

    final imageBytes = await downloadFn(attachment);
    if (imageBytes.isEmpty) return imageBytes;

    if (cacheKey != null) {
      await widget.cacheManager.putFile(cacheKey, imageBytes);
    }
    return imageBytes;
  }

  String _attachmentIdentityKey(ChatAttachment attachment) {
    final id = attachment.id;
    if (id != null && id.isNotEmpty) return 'id:$id';

    final transportId = attachment.transportId;
    if (transportId != null && transportId.isNotEmpty) {
      return 'transport:$transportId';
    }

    final link = attachment.data?.links?.firstOrNull?.toString();
    if (link != null && link.isNotEmpty) return 'link:$link';

    final base64Data = attachment.data?.base64;
    if (base64Data != null && base64Data.isNotEmpty) {
      return 'base64:${base64Data.hashCode}';
    }

    return 'attachment:${identityHashCode(attachment)}';
  }

  @override
  void initState() {
    super.initState();
    _attachmentKey = _attachmentIdentityKey(widget.attachment);
    _imageFuture = _createImageFuture();
  }

  @override
  void didUpdateWidget(_GalleryAttachmentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final nextAttachmentKey = _attachmentIdentityKey(widget.attachment);
    final downloadAvailabilityChanged =
        (oldWidget.download == null) != (widget.download == null);
    if (_attachmentKey != nextAttachmentKey || downloadAvailabilityChanged) {
      _attachmentKey = nextAttachmentKey;
      _resolvedImageBytes = null;
      _imageFuture = _createImageFuture();
    }
  }

  Future<Uint8List>? _createImageFuture() {
    final imageDataBase64 = widget.attachment.data?.base64;
    if (imageDataBase64 != null) return null;

    final downloadFn = widget.download;
    if (downloadFn == null) return null;

    return _loadImageBytes(widget.attachment, downloadFn);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final imageDataBase64 = widget.attachment.data?.base64;

    if (imageDataBase64 != null) {
      try {
        return _ResolvedImage(base64Decode(imageDataBase64));
      } catch (_) {
        return const _ErrorImage();
      }
    }

    final resolvedImageBytes = _resolvedImageBytes;
    if (resolvedImageBytes != null) {
      return _ResolvedImage(resolvedImageBytes);
    }

    final imageFuture = _imageFuture;
    if (imageFuture == null) return const SizedBox.shrink();

    return FutureBuilder<Uint8List>(
      future: imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingImage();
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const _ErrorImage();
        }

        final imageBytes = snapshot.data!;
        _resolvedImageBytes ??= imageBytes;
        return _ResolvedImage(imageBytes);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _LoadingImage extends StatelessWidget {
  const _LoadingImage();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      width: 200,
      child: Card(
        color: Color.fromARGB(0, 10, 10, 10),
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        elevation: 5,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Color.fromARGB(255, 36, 42, 56)),
          child: Center(
            child: Icon(Icons.image_outlined, size: 36, color: Colors.white54),
          ),
        ),
      ),
    );
  }
}

class _ErrorImage extends StatelessWidget {
  const _ErrorImage();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 200,
      width: 200,
      child: Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
}

class _ResolvedImage extends StatelessWidget {
  const _ResolvedImage(this.imageBytes);

  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<ImageViewScreen>(
            MaterialPageRoute(
              builder: (context) => ImageViewScreen(imageBytes: imageBytes),
            ),
          );
        },
        child: Card(
          color: const Color.fromARGB(0, 10, 10, 10),
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child: Image(fit: BoxFit.cover, image: MemoryImage(imageBytes)),
        ),
      ),
    );
  }
}
