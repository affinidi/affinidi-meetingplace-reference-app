import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../../presentation/painting/cached_base64_image.dart';
import '../../../presentation/screens/media/image_view_screen/image_view_screen.dart';
import '../../../presentation/screens/media/media_screen/media_screen.dart';
import '../../extensions/build_context_extensions.dart';
import 'camera_image_attachment.dart';

/// A plugin for handling camera-based attachments.
///
/// Features:
/// - Opens camera via [MediaScreen] for image capture
/// - Provides image review functionality before attachment
/// - Renders camera attachments as tappable image cards
/// - Supports full-screen image viewing via [ImageViewScreen]
class CameraAttachmentsPlugin implements AttachmentPlugin {
  CameraAttachmentsPlugin({required this._cacheManager});

  static const _pluginName = 'mpx_camera_attachment_plugin';

  final BaseCacheManager _cacheManager;

  @override
  bool get dismissSheetBeforePicking => false;

  /// Prompts the user to capture and review an image before attaching.
  ///
  /// Opens the [MediaScreen] with back camera enabled. Users can capture
  /// an image and optionally add a text message during review.
  ///
  /// Returns an [AttachmentPluginPickResult] containing the captured image
  /// and optional text message, or `null` if cancelled or failed.
  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    BuildContext context,
  ) async {
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

    return AttachmentPluginPickResult(
      text: result.textMessage,
      attachments: [
        CameraImageAttachment(
          base64: result.compressedImage.base64,
          pluginName: _pluginName,
        ),
      ],
    );
  }

  /// Renders a single camera attachment as a tappable image card.
  ///
  /// Creates a 200x200 card with the camera image. Tapping opens the
  /// full-screen [ImageViewScreen].
  @override
  Widget renderAttachment({
    required ChatAttachment attachment,
    required bool isFromMe,
    Color? chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => _CameraAttachmentWidget(
    attachment: attachment,
    cacheManager: _cacheManager,
  );

  /// Renders multiple camera attachments in a scrollable list.
  ///
  /// Uses a [ListView] with disabled scrolling physics to display
  /// each attachment using [_CameraAttachmentWidget].
  @override
  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    Color? chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => _ListCameraAttachmentsWidget(
    attachments: attachments,
    cacheManager: _cacheManager,
  );

  /// Returns `true` if the attachment format matches this plugin.
  @override
  bool supportsFormat(ChatAttachment attachment) {
    return attachment.format == _pluginName;
  }

  @override
  @override
  AttachmentPluginIcon get icon => const EmojiIcon('📷');

  @override
  String localizedName(BuildContext context) => context.l10n.generalCamera;

  @override
  bool get isPlatformSupported => true;
}

/// Renders multiple camera attachments in a non-scrollable ListView.
///
/// Uses [NeverScrollableScrollPhysics] and `shrinkWrap` to fit within
/// parent scroll containers without interfering with their scroll behavior.
class _ListCameraAttachmentsWidget extends StatelessWidget {
  const _ListCameraAttachmentsWidget({
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
        return _CameraAttachmentWidget(
          attachment: _attachments[index],
          cacheManager: _cacheManager,
        );
      },
    );
  }
}

/// Renders a single camera attachment as a tappable image card.
///
/// Features:
/// - 200x200 sized card with rounded corners and elevation
/// - Base64 image display with cover fit
/// - Tap gesture opens full-screen [ImageViewScreen]
/// - Uses [CachedBase64Image] for efficient image rendering
class _CameraAttachmentWidget extends StatelessWidget {
  _CameraAttachmentWidget({
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
