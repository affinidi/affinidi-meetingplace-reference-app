import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../mpx_app_core.dart';

abstract interface class AttachmentPlugin {
  AttachmentPluginIcon get icon;

  /// When `true`, the consumer must dismiss the sheet (or any overlay that
  /// launched the plugin) **before** calling [pickAttachments]. The plugin
  /// itself will not attempt to pop any route.
  bool get dismissSheetBeforePicking => false;

  Future<AttachmentPluginPickResult?> pickAttachments(BuildContext context);

  Widget renderAttachment({
    required ChatAttachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  });

  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  });

  bool supportsFormat(ChatAttachment format);

  String localizedName(BuildContext context);

  bool get isPlatformSupported => true;

  bool get includeInMediaOptions => true;
}
