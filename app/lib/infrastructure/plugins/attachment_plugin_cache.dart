import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

String attachmentPluginCacheKey(ChatAttachment attachment) {
  final id = attachment.id;
  if (id != null && id.isNotEmpty) return 'chat_attachment_$id';

  final transportId = attachment.transportId;
  if (transportId != null && transportId.isNotEmpty) {
    return 'chat_attachment_transport_$transportId';
  }

  return attachment.data?.links?.firstOrNull?.toString() ??
      'chat_attachment_${identityHashCode(attachment)}';
}

Future<Uint8List?> readCachedAttachmentBytes(
  BaseCacheManager cacheManager,
  ChatAttachment attachment,
) async {
  final cachedFileInfo = await cacheManager.getFileFromCache(
    attachmentPluginCacheKey(attachment),
  );
  if (cachedFileInfo == null) return null;
  return cachedFileInfo.file.readAsBytes();
}

Future<void> writeCachedAttachmentBytes(
  BaseCacheManager cacheManager,
  ChatAttachment attachment,
  Uint8List bytes,
) async {
  await cacheManager.putFile(attachmentPluginCacheKey(attachment), bytes);
}

Future<Uint8List> downloadAndCacheAttachmentBytes({
  required BaseCacheManager cacheManager,
  required ChatAttachment attachment,
  required Future<Uint8List> Function(ChatAttachment) download,
}) async {
  final cachedBytes = await readCachedAttachmentBytes(cacheManager, attachment);
  if (cachedBytes != null) return cachedBytes;

  final bytes = await download(attachment);
  if (bytes.isNotEmpty) {
    await writeCachedAttachmentBytes(cacheManager, attachment, bytes);
  }
  return bytes;
}
