import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:uuid/uuid.dart';

import '../../../presentation/screens/media/media_screen/media_screen.dart';
import '../../extensions/build_context_extensions.dart';
import '../attachment_plugin_cache.dart';
import '../image_attachment_renderer_mixin.dart';
import 'gallery_image_attachment.dart';
import 'video_attachment.dart';

/// A plugin for handling gallery-based image and video attachments.
///
/// This plugin provides functionality to:
/// - Pick images and videos from the device gallery via [MediaScreen]
/// - Review selected media before attaching
/// - Render image and video attachments in chat
class GalleryAttachmentsPlugin
    with ImageAttachmentRendererMixin
    implements AttachmentPlugin {
  GalleryAttachmentsPlugin({required this._cacheManager});

  static const _pluginName = 'mpx_gallery_attachment_plugin';

  final BaseCacheManager _cacheManager;

  @override
  bool get dismissSheetBeforePicking => false;

  @override
  BaseCacheManager get attachmentRendererCacheManager => _cacheManager;

  @override
  String get pluginName => _pluginName;

  /// Prompts the user to pick and review an image from gallery.
  ///
  /// Opens [MediaScreen] with gallery mode enabled. The user can select
  /// an image and optionally add a text message before confirming.
  ///
  /// Returns an [AttachmentPluginPickResult] containing the selected image
  /// and optional text, or `null` if cancelled or failed.
  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    BuildContext context, {
    TransportCapabilities? capabilities,
  }) async {
    if (!context.mounted) return null;

    final mediaSelectionMode = _mediaSelectionModeFor(capabilities);
    if (mediaSelectionMode == null) {
      return null;
    }

    final result = await Navigator.push<MediaReviewResult>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MediaScreen(
            useCamera: false,
            useChatSemantics: true,
            mediaSelectionMode: mediaSelectionMode,
          );
        },
      ),
    );

    if (result == null) {
      return null;
    }

    if (!result.succeeded) {
      return null;
    }

    final attachmentId = const Uuid().v4();

    final videoBase64 = result.videoBase64;
    if (videoBase64 != null) {
      return AttachmentPluginPickResult(
        text: result.textMessage,
        attachments: [
          VideoAttachment(
            id: attachmentId,
            base64: videoBase64,
            pluginName: _pluginName,
            mimeType: result.videoMimeType ?? 'video/mp4',
            filename: result.videoFilename ?? 'video.mp4',
            byteCount: result.videoByteCount ?? 0,
          ),
        ],
      );
    }

    final cacheKey = cacheKeyForImageAttachment(attachmentId);
    await _cacheManager.writeBytes(cacheKey, result.compressedImage.bytes);

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
  /// Tapping opens the image in full-screen view via the shared image widget.
  @override
  Widget renderAttachment({
    required ChatAttachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
    AttachmentRenderContext? renderContext,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) {
    return super.renderAttachment(
      attachment: attachment,
      isFromMe: isFromMe,
      chatItemColor: chatItemColor,
      renderContext: renderContext,
      download: download,
    );
  }

  /// Renders multiple image attachments as a scrollable list.
  ///
  /// Each attachment is rendered using [renderAttachment] in a vertical
  /// ListView with disabled scrolling physics.
  @override
  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
    AttachmentRenderContext? renderContext,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) {
    return super.renderAttachments(
      attachments: attachments,
      isFromMe: isFromMe,
      chatItemColor: chatItemColor,
      download: download,
    );
  }

  /// Checks if this plugin supports the given attachment format.
  ///
  /// Returns `true` if the attachment format matches this plugin's name.
  @override
  bool supportsFormat(ChatAttachment attachment) =>
      attachment.format == _pluginName;

  /// The emoji icon representing this plugin type.
  @override
  AttachmentPluginIcon get icon => const EmojiIcon('🖼');

  /// Returns the localized display name for this plugin.
  @override
  String localizedName(BuildContext context) => context.l10n.generalPhoto;

  /// Indicates this plugin is supported on all platforms.
  @override
  bool get isPlatformSupported => true;

  @override
  bool get includeInMediaOptions => true;

  MediaSelectionMode? _mediaSelectionModeFor(
    TransportCapabilities? capabilities,
  ) {
    final supportsImages =
        capabilities?.supports(ChatFeature.imageAttachments) ?? true;
    final supportsVideos =
        capabilities?.supports(ChatFeature.videoAttachments) ?? true;

    return switch ((supportsImages, supportsVideos)) {
      (true, true) => MediaSelectionMode.imagesAndVideos,
      (true, false) => MediaSelectionMode.imagesOnly,
      (false, true) => MediaSelectionMode.videosOnly,
      (false, false) => null,
    };
  }
}
