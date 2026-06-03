import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import 'video_attachment.dart';

/// A plugin for handling video attachments picked from the device gallery.
final class VideoAttachmentsPlugin implements AttachmentPlugin {
  VideoAttachmentsPlugin();

  static const _pluginName = 'mpx_video_attachment_plugin';

  /// Hard upper bound on raw video bytes accepted from the picker.
  /// Above this the file is rejected before being loaded into memory or
  /// base64-encoded, which would otherwise risk an OOM kill on lower-memory
  /// devices.
  static const _maxBytes = 25 * 1024 * 1024;

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
          pluginName: _pluginName,
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
  }) => _VideoAttachmentWidget(attachment: attachment);

  @override
  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
  }) => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: attachments.length,
    itemBuilder: (context, index) =>
        _VideoAttachmentWidget(attachment: attachments[index]),
  );

  @override
  bool supportsFormat(ChatAttachment attachment) =>
      attachment.format == _pluginName;

  @override
  String get icon => '🎬';

  @override
  String localizedName(BuildContext context) => context.l10n.generalVideo;

  @override
  bool get isPlatformSupported => true;
}

class _VideoAttachmentWidget extends StatelessWidget {
  const _VideoAttachmentWidget({required ChatAttachment attachment})
    : _attachment = attachment;

  final ChatAttachment _attachment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: Card(
        color: const Color.fromARGB(0, 10, 10, 10),
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam, color: Colors.white70, size: 48),
              if (_attachment.filename != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  child: Text(
                    _attachment.filename!,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
