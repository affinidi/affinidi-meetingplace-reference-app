import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../../presentation/painting/cached_base64_image.dart';
import '../../../presentation/screens/media/image_view_screen/image_view_screen.dart';
import '../../../presentation/screens/media/media_screen/media_screen.dart';
import '../../extensions/build_context_extensions.dart';
import '../downloadable_image_attachment_card.dart';
import 'gallery_image_attachment.dart';

/// A plugin for handling gallery-based image attachments.
///
/// This plugin provides functionality to:
/// - Pick images from the device gallery via [MediaScreen]
/// - Review selected images before attaching
/// - Render image attachments as tappable cards in chat
/// - Support full-screen image viewing
class GalleryAttachmentsPlugin implements AttachmentPlugin {
  GalleryAttachmentsPlugin({required BaseCacheManager cacheManager})
    : _cacheManager = cacheManager;

  static const _pluginName = 'mpx_gallery_attachment_plugin';

  final BaseCacheManager _cacheManager;

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
    required Attachment attachment,
    required bool isFromMe,
    Color? chatItemColor,
    Future<void> Function(Attachment attachment)? onDownloadAttachment,
  }) => _GalleryAttachmentWidget(
    attachment: attachment,
    cacheManager: _cacheManager,
    onDownloadAttachment: onDownloadAttachment,
  );

  /// Renders multiple image attachments as a scrollable list.
  ///
  /// Each attachment is rendered using [renderAttachment] in a vertical
  /// ListView with disabled scrolling physics.
  @override
  Widget renderAttachments({
    required List<Attachment> attachments,
    required bool isFromMe,
    Color? chatItemColor,
    Future<void> Function(Attachment attachment)? onDownloadAttachment,
  }) => _ListGalleryAttachmentsWidget(
    attachments: attachments,
    cacheManager: _cacheManager,
    onDownloadAttachment: onDownloadAttachment,
  );

  /// Checks if this plugin supports the given attachment format.
  ///
  /// Returns `true` if the attachment format matches this plugin's name.
  @override
  bool supportsFormat(Attachment attachment) {
    return attachment.format == _pluginName;
  }

  /// The emoji icon representing this plugin type.
  @override
  String get icon => '🖼';

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
    required List<Attachment> attachments,
    required BaseCacheManager cacheManager,
    Future<void> Function(Attachment attachment)? onDownloadAttachment,
  }) : _attachments = attachments,
       _cacheManager = cacheManager,
       _onDownloadAttachment = onDownloadAttachment;

  final List<Attachment> _attachments;
  final BaseCacheManager _cacheManager;
  final Future<void> Function(Attachment attachment)? _onDownloadAttachment;

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
          onDownloadAttachment: _onDownloadAttachment,
        );
      },
    );
  }
}

/// Widget that renders a single gallery image attachment as a tappable card.
///
/// Features:
/// - 200x200 size with rounded corners and elevation
/// - Displays image using [CachedBase64Image] for performance
/// - Taps navigate to [ImageViewScreen] for full-screen viewing
/// - Returns empty widget if attachment data is invalid
class _GalleryAttachmentWidget extends StatelessWidget {
  _GalleryAttachmentWidget({
    required Attachment attachment,
    required BaseCacheManager cacheManager,
    Future<void> Function(Attachment attachment)? onDownloadAttachment,
  }) : _attachment = attachment,
       _cacheManager = cacheManager,
       _onDownloadAttachment = onDownloadAttachment;

  final Attachment _attachment;
  final BaseCacheManager _cacheManager;
  final Future<void> Function(Attachment attachment)? _onDownloadAttachment;

  @override
  Widget build(BuildContext context) {
    return DownloadableImageAttachmentCard(
      attachment: _attachment,
      cacheManager: _cacheManager,
      onDownloadAttachment: _onDownloadAttachment,
    );
  }
}
