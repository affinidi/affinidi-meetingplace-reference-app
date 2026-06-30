import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:uuid/uuid.dart';

import '../../../presentation/screens/media/media_screen/media_screen.dart';
import '../../extensions/build_context_extensions.dart';
import '../attachment_plugin_cache.dart';
import '../image_attachment_renderer_mixin.dart';
import 'camera_image_attachment.dart';

/// A plugin for handling camera-based attachments.
///
/// Features:
/// - Opens camera via [MediaScreen] for image capture
/// - Provides image review functionality before attachment
/// - Renders camera attachments as tappable image cards
/// - Supports full-screen image viewing via the shared image attachment widget
class CameraAttachmentsPlugin
    with ImageAttachmentRendererMixin
    implements AttachmentPicker, AttachmentRenderer {
  CameraAttachmentsPlugin({required this._cacheManager});

  static const _pluginName = 'mpx_camera_attachment_plugin';

  final BaseCacheManager _cacheManager;

  @override
  bool get dismissSheetBeforePicking => false;

  @override
  BaseCacheManager get attachmentRendererCacheManager => _cacheManager;

  @override
  String get pluginName => _pluginName;

  /// Prompts the user to capture and review an image before attaching.
  ///
  /// Opens the [MediaScreen] with back camera enabled. Users can capture
  /// an image and optionally add a text message during review.
  ///
  /// Returns an [AttachmentPluginPickResult] containing the captured image
  /// and optional text message, or `null` if cancelled or failed.
  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    AttachmentPickRequest request,
  ) async {
    final context = request.context;
    if (!context.mounted) return null;

    final result = await Navigator.push<MediaReviewResult>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const MediaScreen(
            cameraLensDirection: CameraLensDirection.back,
            useCamera: true,
            useChatSemantics: true,
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
    final cacheKey = cacheKeyForImageAttachment(attachmentId);
    await _cacheManager.writeBytes(cacheKey, result.compressedImage.bytes);

    return AttachmentPluginPickResult(
      text: result.textMessage,
      attachments: [
        CameraImageAttachment(
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
  Widget renderAttachment(AttachmentRenderRequest request) =>
      super.renderAttachment(request);

  /// Renders multiple image attachments as a scrollable list.
  ///
  /// Each attachment is rendered using [renderAttachment] in a vertical
  /// ListView with disabled scrolling physics.
  @override
  Widget renderAttachments(AttachmentListRenderRequest request) =>
      super.renderAttachments(request);

  /// Returns `true` if the attachment format matches this plugin.
  @override
  bool supportsFormat(ChatAttachment attachment) {
    return attachment.format == _pluginName;
  }

  @override
  AttachmentPluginIcon get icon => const EmojiIcon('📷');

  @override
  String localizedName(BuildContext context) => context.l10n.generalCamera;

  @override
  bool get isPlatformSupported => true;

  @override
  bool get includeInMediaOptions => true;
}
