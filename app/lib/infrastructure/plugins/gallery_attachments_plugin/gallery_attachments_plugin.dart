import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../../presentation/painting/cached_base64_image.dart';
import '../../../presentation/screens/media/image_view_screen/image_view_screen.dart';
import '../../../presentation/screens/media/media_screen/media_screen.dart';
import '../../extensions/build_context_extensions.dart';
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
    required ChatAttachment attachment,
    required bool isFromMe,
    Color? chatItemColor,
  }) => _GalleryAttachmentWidget(
    attachment: attachment,
    cacheManager: _cacheManager,
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
  }) => _ListGalleryAttachmentsWidget(
    attachments: attachments,
    cacheManager: _cacheManager,
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
    required this._attachments,
    required this._cacheManager,
  });

  final List<ChatAttachment> _attachments;
  final BaseCacheManager _cacheManager;

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
    required this._attachment,
    required this._cacheManager,
  });

  final ChatAttachment _attachment;
  final BaseCacheManager _cacheManager;

  @override
  Widget build(BuildContext context) {
    final imageDataBase64 = _attachment.data?.base64;

    if (imageDataBase64 == null) return const SizedBox.shrink();

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
              cacheManager: _cacheManager,
            ),
          ),
        ),
      ),
    );
  }
}
