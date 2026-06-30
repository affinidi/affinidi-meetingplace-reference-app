import 'dart:typed_data';

import 'package:flutter/material.dart';
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
    BuildContext context, {
    TransportCapabilities? capabilities,
  }) async => null;

  @override
  bool supportsFormat(ChatAttachment attachment) => false;

  @override
  Widget renderAttachment({
    required ChatAttachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
    AttachmentRenderContext? renderContext,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => const SizedBox.shrink();

  @override
  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
    AttachmentRenderContext? renderContext,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => const SizedBox.shrink();

  @override
  bool get includeInMediaOptions => true;
}
