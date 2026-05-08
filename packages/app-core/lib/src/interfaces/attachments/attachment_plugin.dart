import 'package:flutter/material.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';

import 'attachment_plugin_pick_result.dart';

abstract interface class AttachmentPlugin {
  String get icon;

  Future<AttachmentPluginPickResult?> pickAttachments(BuildContext context);

  Widget renderAttachment({
    required ChatAttachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
  });

  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
  });

  bool supportsFormat(ChatAttachment format);

  String localizedName(BuildContext context);

  bool get isPlatformSupported => true;
}
