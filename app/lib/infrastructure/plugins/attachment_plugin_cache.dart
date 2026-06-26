import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

Future<Uint8List?> readCachedAttachmentBytes(
  BaseCacheManager cacheManager,
  String cacheKey,
) async {
  final cachedFileInfo = await cacheManager.getFileFromCache(cacheKey);
  if (cachedFileInfo == null) return null;
  return cachedFileInfo.file.readAsBytes();
}

Future<void> writeCachedAttachmentBytes(
  BaseCacheManager cacheManager,
  String cacheKey,
  Uint8List bytes,
) async {
  await cacheManager.putFile(cacheKey, bytes);
}

Future<Uint8List> downloadAndCacheAttachmentBytes({
  required BaseCacheManager cacheManager,
  required String cacheKey,
  required Future<Uint8List> Function() download,
}) async {
  final cachedBytes = await readCachedAttachmentBytes(cacheManager, cacheKey);
  if (cachedBytes != null) return cachedBytes;

  final bytes = await download();
  if (bytes.isNotEmpty) {
    await writeCachedAttachmentBytes(cacheManager, cacheKey, bytes);
  }
  return bytes;
}
