import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/matrix_config_provider.dart';

void main() {
  group('matrixMediaCacheConfig', () {
    late Directory documentsDirectory;

    setUp(() {
      documentsDirectory = Directory.systemTemp.createTempSync(
        'matrix_media_cache_test',
      );
    });

    tearDown(() {
      if (documentsDirectory.existsSync()) {
        documentsDirectory.deleteSync(recursive: true);
      }
    });

    test('passes maxFileSize, fileStorageLocation and TTL on native', () {
      const maxBytes = 30 * 1024 * 1024;
      const ttl = Duration(days: 30);

      final config = matrixMediaCacheConfig(
        documentsDirectory: documentsDirectory,
        safeDatabaseName: 'account_a',
        maxCacheBytes: maxBytes,
        cacheTtl: ttl,
        isWeb: false,
      );

      expect(config.maxFileSize, maxBytes);
      expect(config.deleteFilesAfterDuration, ttl);
      expect(config.fileStorageLocation, isNotNull);
      expect(
        config.fileStorageLocation!.toFilePath(),
        equals(
          Directory(
            '${documentsDirectory.path}/matrix_media_account_a',
          ).uri.toFilePath(),
        ),
      );
    });

    test('namespaces the cache directory per account database', () {
      final configA = matrixMediaCacheConfig(
        documentsDirectory: documentsDirectory,
        safeDatabaseName: 'account_a',
        maxCacheBytes: 1,
        cacheTtl: const Duration(days: 1),
        isWeb: false,
      );
      final configB = matrixMediaCacheConfig(
        documentsDirectory: documentsDirectory,
        safeDatabaseName: 'account_b',
        maxCacheBytes: 1,
        cacheTtl: const Duration(days: 1),
        isWeb: false,
      );

      expect(
        configA.fileStorageLocation,
        isNot(equals(configB.fileStorageLocation)),
      );
    });

    test('disables the on-disk cache on web', () {
      final config = matrixMediaCacheConfig(
        documentsDirectory: documentsDirectory,
        safeDatabaseName: 'account_a',
        maxCacheBytes: 30 * 1024 * 1024,
        cacheTtl: const Duration(days: 30),
        isWeb: true,
      );

      expect(config.maxFileSize, 0);
      expect(config.fileStorageLocation, isNull);
      expect(config.deleteFilesAfterDuration, isNull);
    });
  });
}
