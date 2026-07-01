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

  Widget renderAttachment(AttachmentRenderRequest request) {
    final attachment = request.attachment;
    if (_isVideoAttachment(attachment)) {
      return VideoAttachmentWidget(
        attachment: attachment,
        cacheManager: attachmentRendererCacheManager,
        cacheKey: cacheKeyForImageAttachment(attachment.id ?? ''),
        playbackScopeId: request.renderContext?.playbackScopeId,
        download: request.download,
      );
    }

    return ImageAttachmentWidget(
      attachment: attachment,
      cacheManager: attachmentRendererCacheManager,
      cacheKey: cacheKeyForImageAttachment(attachment.id ?? ''),
      download: request.download,
    );
  }

  Widget renderAttachments(AttachmentListRenderRequest request) => Column(
    children: List.generate(request.attachments.length, (index) {
      final attachment = request.attachments[index];
      if (_isVideoAttachment(attachment)) {
        return VideoAttachmentWidget(
          key: ValueKey(attachment.id),
          attachment: attachment,
          cacheManager: attachmentRendererCacheManager,
          cacheKey: cacheKeyForImageAttachment(attachment.id ?? ''),
          playbackScopeId: request.renderContext?.playbackScopeId,
          download: request.download,
        );
      }

      return ImageAttachmentWidget(
        key: ValueKey(attachment.id),
        attachment: attachment,
        cacheManager: attachmentRendererCacheManager,
        cacheKey: cacheKeyForImageAttachment(attachment.id ?? ''),
        download: request.download,
      );
    }, growable: false),
  );
}
