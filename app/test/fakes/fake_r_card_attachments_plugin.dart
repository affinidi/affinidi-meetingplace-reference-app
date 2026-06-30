import 'package:flutter/material.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

class FakeUnsupportedRCardPlugin
    implements AttachmentPicker, AttachmentRenderer {
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
    AttachmentPickRequest request,
  ) async => null;

  @override
  bool supportsFormat(ChatAttachment attachment) => false;

  @override
  Widget renderAttachment(AttachmentRenderRequest request) =>
      const SizedBox.shrink();

  @override
  Widget renderAttachments(AttachmentListRenderRequest request) =>
      const SizedBox.shrink();

  @override
  bool get includeInMediaOptions => true;
}
