import 'package:flutter/material.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import 'downloadable_audio_attachment_card.dart';

class AudioAttachmentsPlugin implements AttachmentPlugin {
  static const pluginName = 'mpx_audio_attachment_plugin';

  @override
  String get icon => '🎵';

  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    BuildContext context,
  ) async {
    throw UnsupportedError(
      'Audio attachments are only supported when rendering received messages.',
    );
  }

  @override
  Widget renderAttachment({
    required Attachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
    Future<void> Function(Attachment attachment)? onDownloadAttachment,
  }) => DownloadableAudioAttachmentCard(
    attachment: attachment,
    onDownloadAttachment: onDownloadAttachment,
  );

  @override
  Widget renderAttachments({
    required List<Attachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
    Future<void> Function(Attachment attachment)? onDownloadAttachment,
  }) => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: attachments.length,
    itemBuilder: (context, index) {
      return DownloadableAudioAttachmentCard(
        attachment: attachments[index],
        onDownloadAttachment: onDownloadAttachment,
      );
    },
  );

  @override
  bool supportsFormat(Attachment attachment) {
    return attachment.format == pluginName;
  }

  @override
  String localizedName(BuildContext context) => 'Audio';

  @override
  bool get isPlatformSupported => true;
}
