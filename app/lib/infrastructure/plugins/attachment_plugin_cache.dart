import 'dart:typed_data';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

extension BytesCacheManager on BaseCacheManager {
  Future<Uint8List?> readBytes(String cacheKey) async {
    final cachedFileInfo = await getFileFromCache(cacheKey);
    if (cachedFileInfo == null) return null;
    return cachedFileInfo.file.readAsBytes();
  }

  Future<void> writeBytes(String cacheKey, Uint8List bytes) async {
    await putFile(cacheKey, bytes);
  }

  Future<Uint8List> downloadBytes({
    required String cacheKey,
    required Future<Uint8List> Function() download,
  }) async {
    final cachedBytes = await readBytes(cacheKey);
    if (cachedBytes != null) return cachedBytes;

    final bytes = await download();
    if (bytes.isNotEmpty) {
      await writeBytes(cacheKey, bytes);
    }
    return bytes;
  }
}
