import 'package:flutter/material.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import 'attachment_plugin_pick_result.dart';

abstract interface class AttachmentPlugin {
  String get icon;

  Future<AttachmentPluginPickResult?> pickAttachments(BuildContext context);

  Widget renderAttachment({
    required Attachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
  });

  Widget renderAttachments({
    required List<Attachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
  });

  bool supportsFormat(Attachment format);

  String localizedName(BuildContext context);

  bool get isPlatformSupported => true;
}
