import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../../presentation/screens/media/media_screen/media_screen.dart';
import '../../../presentation/widgets/images/chat_image_card.dart';
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
  GalleryAttachmentsPlugin();

  static const _pluginName = 'mpx_gallery_attachment_plugin';

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
  /// Tapping opens the image in full-screen view via [ChatImageCard].
  @override
  Widget renderAttachment({
    required ChatAttachment attachment,
    required bool isFromMe,
    Color? chatItemColor,
  }) => _GalleryAttachmentWidget(attachment: attachment);

  /// Renders multiple image attachments as a scrollable list.
  ///
  /// Each attachment is rendered using [renderAttachment] in a vertical
  /// ListView with disabled scrolling physics.
  @override
  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    Color? chatItemColor,
  }) => _ListGalleryAttachmentsWidget(attachments: attachments);

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
    required List<ChatAttachment> attachments,
  }) : _attachments = attachments;

  final List<ChatAttachment> _attachments;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _attachments.length,
      itemBuilder: (context, index) {
        return _GalleryAttachmentWidget(attachment: _attachments[index]);
      },
    );
  }
}

/// Widget that renders a single gallery image attachment as a tappable card.
///
/// Features:
/// - 200x200 size with rounded corners and elevation
/// - Tap gesture opens full-screen [ChatImageCard]
/// - Returns empty widget if attachment data is invalid
class _GalleryAttachmentWidget extends StatelessWidget {
  _GalleryAttachmentWidget({required ChatAttachment attachment})
    : _attachment = attachment;

  final ChatAttachment _attachment;

  @override
  Widget build(BuildContext context) {
    final imageDataBase64 = _attachment.data?.base64;

    if (imageDataBase64 == null) return const SizedBox.shrink();

    final Uint8List imageBytes;
    try {
      imageBytes = base64.decode(imageDataBase64);
    } on FormatException {
      return const SizedBox.shrink();
    }
    return ChatImageCard(imageBytes: imageBytes);
  }
}
