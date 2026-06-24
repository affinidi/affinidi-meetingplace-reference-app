import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

import 'image_attachment_widget.dart';
import 'video_attachment_widget.dart';

mixin ImageAttachmentRendererMixin {
  BaseCacheManager get attachmentRendererCacheManager;

  String get pluginName;

  String cacheKeyForImageAttachment(String attachmentId) =>
      '$pluginName:$attachmentId';

  bool _isVideoAttachment(ChatAttachment attachment) {
    if (attachment.format != pluginName) return false;
    return attachment.mediaType?.toLowerCase().startsWith('video/') ?? false;
  }

  Widget renderAttachment({
    required ChatAttachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) {
    if (_isVideoAttachment(attachment)) {
      return VideoAttachmentWidget(
        attachment: attachment,
        cacheManager: attachmentRendererCacheManager,
        download: download,
      );
    }

    return ImageAttachmentWidget(
      attachment: attachment,
      cacheManager: attachmentRendererCacheManager,
      cacheKey: cacheKeyForImageAttachment(attachment.id ?? ''),
      download: download,
    );
  }

  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => Column(
    children: List.generate(attachments.length, (index) {
      final attachment = attachments[index];
      if (_isVideoAttachment(attachment)) {
        return VideoAttachmentWidget(
          key: ValueKey(attachment.id ?? index),
          attachment: attachment,
          cacheManager: attachmentRendererCacheManager,
          download: download,
        );
      }

      return ImageAttachmentWidget(
        key: ValueKey(attachment.id ?? index),
        attachment: attachment,
        cacheManager: attachmentRendererCacheManager,
        cacheKey: cacheKeyForImageAttachment(attachment.id ?? ''),
        download: download,
      );
    }, growable: false),
  );
}
