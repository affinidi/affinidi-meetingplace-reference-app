import 'package:flutter/material.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:mpx_app_core/mpx_app_core.dart';

class FakeUnsupportedRCardPlugin implements AttachmentPlugin {
  @override
  AttachmentPluginIcon get icon => const EmojiIcon('💳');

  @override
  bool get isPlatformSupported => false;

  @override
  bool get dismissSheetBeforePicking => false;

  @override
  String localizedName(BuildContext context) => 'R-Card (disabled)';

  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    BuildContext context,
  ) async => null;

  @override
  bool supportsFormat(chat.Attachment attachment) => false;

  @override
  Widget renderAttachment({
    required chat.Attachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
  }) => const SizedBox.shrink();

  @override
  Widget renderAttachments({
    required List<chat.Attachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
  }) => const SizedBox.shrink();
}
