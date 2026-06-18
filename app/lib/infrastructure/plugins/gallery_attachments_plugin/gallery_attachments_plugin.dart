import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../../presentation/painting/cached_base64_image.dart';
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

    return AttachmentPluginPickResult(
      text: result.textMessage,
      attachments: [
        GalleryImageAttachment(
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
    Color? chatItemColor,
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
    Color? chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => _ListGalleryAttachmentsWidget(
    attachments: attachments,
    cacheManager: _cacheManager,
    download: download,
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
  @override
  AttachmentPluginIcon get icon => const EmojiIcon('🖼');

  /// Returns the localized display name for this plugin.
  @override
  String localizedName(BuildContext context) => context.l10n.generalPhoto;

  /// Indicates this plugin is supported on all platforms.
  @override
  bool get isPlatformSupported => true;
}

/// Widget that renders multiple gallery attachments in a vertical list.
///
/// Uses a [ListView.builder] with disabled scrolling to display each
/// attachment as a separate [_GalleryAttachmentWidget].
class _ListGalleryAttachmentsWidget extends StatelessWidget {
  const _ListGalleryAttachmentsWidget({
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
      itemBuilder: (context, index) {
        return _GalleryAttachmentWidget(
          attachment: _attachments[index],
          cacheManager: _cacheManager,
          download: _download,
        );
      },
    );
  }
}

/// Widget that renders a single gallery image attachment as a tappable card.
///
/// Features:
/// - 200x200 size with rounded corners and elevation
/// - When inline base64 data is available, renders using [CachedBase64Image]
/// - When no inline data but a [download] callback is provided, uses
///   [FutureBuilder] to download and render the image
/// - Shows loading spinner while downloading
/// - Shows broken image icon on download error
/// - Returns empty widget if neither data nor callback are available
class _GalleryAttachmentWidget extends StatelessWidget {
  const _GalleryAttachmentWidget({
    required this.attachment,
    required this.cacheManager,
    this.download,
  });

  final ChatAttachment attachment;
  final BaseCacheManager cacheManager;
  final Future<Uint8List> Function(ChatAttachment)? download;

  String _cacheKey(ChatAttachment attachment) {
    final id = attachment.id;
    if (id != null && id.isNotEmpty) return 'chat_attachment_$id';

    final transportId = attachment.transportId;
    if (transportId != null && transportId.isNotEmpty) {
      return 'chat_attachment_transport_$transportId';
    }

    return attachment.data?.links?.firstOrNull?.toString() ??
        'chat_attachment_${identityHashCode(attachment)}';
  }

  Future<Uint8List> _loadImageBytes(
    ChatAttachment attachment,
    Future<Uint8List> Function(ChatAttachment) downloadFn,
  ) async {
    final cacheKey = _cacheKey(attachment);
    final cachedFileInfo = await cacheManager.getFileFromCache(cacheKey);
    if (cachedFileInfo != null) {
      return cachedFileInfo.file.readAsBytes();
    }

    final imageBytes = await downloadFn(attachment);
    await cacheManager.putFile(cacheKey, imageBytes);
    return imageBytes;
  }

  @override
  Widget build(BuildContext context) {
    final imageDataBase64 = attachment.data?.base64;

    // If we have inline base64, render it directly (legacy / sender path).
    if (imageDataBase64 != null) {
      return SizedBox(
        height: 200,
        width: 200,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push<ImageViewScreen>(
              MaterialPageRoute(
                builder: (context) =>
                    ImageViewScreen(imageBytes: base64.decode(imageDataBase64)),
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
            child: Image(
              fit: BoxFit.cover,
              image: CachedBase64Image(
                imageDataBase64,
                cacheManager: cacheManager,
              ),
            ),
          ),
        ),
      );
    }

    // No inline data: if no download callback, show nothing
    final downloadFn = download;
    if (downloadFn == null) return const SizedBox.shrink();

    // Use FutureBuilder to download and render the image
    return FutureBuilder<Uint8List>(
      future: _loadImageBytes(attachment, downloadFn),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            width: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox(
            height: 200,
            width: 200,
            child: Center(child: Icon(Icons.broken_image_outlined)),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox(
            height: 200,
            width: 200,
            child: Center(child: Icon(Icons.broken_image_outlined)),
          );
        }

        final imageBytes = snapshot.data!;
        final imageBase64 = base64.encode(imageBytes);

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
              child: Image(
                fit: BoxFit.cover,
                image: CachedBase64Image(
                  imageBase64,
                  cacheManager: cacheManager,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
