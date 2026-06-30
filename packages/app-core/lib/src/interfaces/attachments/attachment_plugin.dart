import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../mpx_app_core.dart';

abstract interface class AttachmentPlugin {
  AttachmentPluginIcon get icon;

  String localizedName(BuildContext context);

  bool get isPlatformSupported => true;
}

abstract interface class AttachmentPicker implements AttachmentPlugin {
  /// When `true`, the consumer must dismiss the sheet (or any overlay that
  /// launched the plugin) **before** calling [pickAttachments]. The plugin
  /// itself will not attempt to pop any route.
  bool get dismissSheetBeforePicking => false;

  Future<AttachmentPluginPickResult?> pickAttachments(
    AttachmentPickRequest request,
  );

  bool get includeInMediaOptions => true;
}

abstract interface class AttachmentRenderer implements AttachmentPlugin {
  bool supportsFormat(ChatAttachment format);

  Widget renderAttachment(AttachmentRenderRequest request);

  Widget renderAttachments(AttachmentListRenderRequest request);
}

class AttachmentPickRequest {
  const AttachmentPickRequest({required this.context, this.capabilities});

  final BuildContext context;
  final TransportCapabilities? capabilities;
}

class AttachmentRenderRequest {
  const AttachmentRenderRequest({
    required this.attachment,
    required this.isFromMe,
    required this.chatItemColor,
    this.renderContext,
    this.download,
  });

  final ChatAttachment attachment;
  final bool isFromMe;
  final Color chatItemColor;
  final AttachmentRenderContext? renderContext;
  final Future<Uint8List> Function(ChatAttachment)? download;
}

class AttachmentListRenderRequest {
  const AttachmentListRenderRequest({
    required this.attachments,
    required this.isFromMe,
    required this.chatItemColor,
    this.renderContext,
    this.download,
  });

  final List<ChatAttachment> attachments;
  final bool isFromMe;
  final Color chatItemColor;
  final AttachmentRenderContext? renderContext;
  final Future<Uint8List> Function(ChatAttachment)? download;
}

class AttachmentRenderContext {
  const AttachmentRenderContext({
    this.avatarImage,
    this.playbackScopeId,
    this.playbackClipId,
  });

  final ImageProvider<Object>? avatarImage;
  final String? playbackScopeId;
  final String? playbackClipId;
}
