import 'dart:convert';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../../presentation/screens/media/media_screen/media_screen.dart';
import '../../../presentation/widgets/images/chat_image_card.dart';
import '../../extensions/build_context_extensions.dart';
import 'camera_image_attachment.dart';

/// A plugin for handling camera-based attachments.
///
/// Features:
/// - Opens camera via [MediaScreen] for image capture
/// - Provides image review functionality before attachment
/// - Renders camera attachments as tappable image cards
/// - Supports full-screen image viewing via [ChatImageCard]
class CameraAttachmentsPlugin implements AttachmentPlugin {
  CameraAttachmentsPlugin();

  static const _pluginName = 'mpx_camera_attachment_plugin';

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
  /// full-screen [ChatImageCard].
  @override
  Widget renderAttachment({
    required ChatAttachment attachment,
    required bool isFromMe,
    Color? chatItemColor,
  }) => _CameraAttachmentWidget(attachment: attachment);

  /// Renders multiple camera attachments in a scrollable list.
  ///
  /// Uses a [ListView] with disabled scrolling physics to display
  /// each attachment using [_CameraAttachmentWidget].
  @override
  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    Color? chatItemColor,
  }) => _ListCameraAttachmentsWidget(attachments: attachments);

  /// Returns `true` if the attachment format matches this plugin.
  @override
  bool supportsFormat(ChatAttachment attachment) {
    return attachment.format == _pluginName;
  }

  @override
  String get icon => '📷';

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
        return _CameraAttachmentWidget(attachment: _attachments[index]);
      },
    );
  }
}

/// Renders a single camera attachment as a tappable image card.
///
/// Features:
/// - 200x200 sized card with rounded corners and elevation
/// - Base64 image display with cover fit
/// - Tap gesture opens full-screen [ChatImageCard]
class _CameraAttachmentWidget extends StatelessWidget {
  _CameraAttachmentWidget({required ChatAttachment attachment})
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
