import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:mpx_flutter_reference_app/infrastructure/plugins/attachment_plugin_cache.dart';

void main() {
  group('attachmentPluginCacheKey', () {
    test('prefers attachment id over transport id and link', () {
      final attachment = ChatAttachment(
        id: 'attachment-id',
        transportId: 'transport-id',
        data: ChatAttachmentData(links: [Uri.parse('mxc://example/media')]),
      );

      expect(
        attachmentPluginCacheKey(attachment),
        'chat_attachment_attachment-id',
      );
    });

    test('uses transport id when attachment id is absent', () {
      final attachment = ChatAttachment(
        transportId: 'transport-id',
        data: ChatAttachmentData(links: [Uri.parse('mxc://example/media')]),
      );

      expect(
        attachmentPluginCacheKey(attachment),
        'chat_attachment_transport_transport-id',
      );
    });

    test('uses first link when id and transport id are absent', () {
      final attachment = ChatAttachment(
        data: ChatAttachmentData(links: [Uri.parse('mxc://example/media')]),
      );

      expect(attachmentPluginCacheKey(attachment), 'mxc://example/media');
    });

    test('uses object identity fallback when no stable fields are present', () {
      final attachment = ChatAttachment();

      expect(
        attachmentPluginCacheKey(attachment),
        'chat_attachment_${identityHashCode(attachment)}',
      );
    });
  });

  group('attachment plugin cache helpers', () {
    test(
      'writeCachedAttachmentBytes and readCachedAttachmentBytes round trip',
      () async {
        final cacheManager = _MemoryCacheManager();
        final attachment = ChatAttachment(id: 'attachment-id');
        final bytes = Uint8List.fromList([1, 2, 3]);

        await writeCachedAttachmentBytes(cacheManager, attachment, bytes);

        expect(
          await readCachedAttachmentBytes(cacheManager, attachment),
          bytes,
        );
        expect(cacheManager.writtenKeys, ['chat_attachment_attachment-id']);
      },
    );

    test('downloadAndCacheAttachmentBytes returns cached bytes without '
        'downloading', () async {
      final cacheManager = _MemoryCacheManager();
      final attachment = ChatAttachment(id: 'attachment-id');
      final cachedBytes = Uint8List.fromList([4, 5, 6]);
      var downloadCalls = 0;

      await writeCachedAttachmentBytes(cacheManager, attachment, cachedBytes);

      final result = await downloadAndCacheAttachmentBytes(
        cacheManager: cacheManager,
        attachment: attachment,
        download: (_) async {
          downloadCalls++;
          return Uint8List.fromList([7, 8, 9]);
        },
      );

      expect(result, cachedBytes);
      expect(downloadCalls, 0);
    });

    test(
      'downloadAndCacheAttachmentBytes caches non-empty downloads',
      () async {
        final cacheManager = _MemoryCacheManager();
        final attachment = ChatAttachment(transportId: 'transport-id');
        final downloadedBytes = Uint8List.fromList([7, 8, 9]);

        final result = await downloadAndCacheAttachmentBytes(
          cacheManager: cacheManager,
          attachment: attachment,
          download: (_) async => downloadedBytes,
        );

        expect(result, downloadedBytes);
        expect(
          await readCachedAttachmentBytes(cacheManager, attachment),
          downloadedBytes,
        );
        expect(cacheManager.writtenKeys, [
          'chat_attachment_transport_transport-id',
        ]);
      },
    );

    test(
      'downloadAndCacheAttachmentBytes does not cache empty downloads',
      () async {
        final cacheManager = _MemoryCacheManager();
        final attachment = ChatAttachment(id: 'attachment-id');
        final emptyBytes = Uint8List(0);

        final result = await downloadAndCacheAttachmentBytes(
          cacheManager: cacheManager,
          attachment: attachment,
          download: (_) async => emptyBytes,
        );

        expect(result, emptyBytes);
        expect(
          await readCachedAttachmentBytes(cacheManager, attachment),
          isNull,
        );
        expect(cacheManager.writtenKeys, isEmpty);
      },
    );
  });
}

class _MemoryCacheManager implements BaseCacheManager {
  final _fileSystem = MemoryFileSystem.test();
  final _files = <String, Uint8List>{};
  final writtenKeys = <String>[];

  @override
  Future<FileInfo?> getFileFromCache(
    String key, {
    bool ignoreMemCache = false,
  }) async {
    final bytes = _files[key];
    if (bytes == null) return null;

    final file = _fileSystem.file('/cache/${Uri.encodeComponent(key)}')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);

    return FileInfo(
      file,
      FileSource.Cache,
      DateTime.now().add(const Duration(days: 1)),
      key,
    );
  }

  @override
  Future<File> putFile(
    String url,
    Uint8List fileBytes, {
    String? key,
    String? eTag,
    Duration maxAge = const Duration(days: 30),
    String fileExtension = 'file',
  }) async {
    final cacheKey = key ?? url;
    final bytes = Uint8List.fromList(fileBytes);
    _files[cacheKey] = bytes;
    writtenKeys.add(cacheKey);

    return _fileSystem.file('/cache/${Uri.encodeComponent(cacheKey)}')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}
