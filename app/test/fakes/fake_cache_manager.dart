import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter_cache_manager/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FakeCacheManager implements BaseCacheManager {
  final Map<String, Uint8List> _cache = {};

  @override
  Future<FileInfo?> getFileFromCache(String key,
      {bool ignoreMemCache = false}) async {
    final data = _cache[key];
    if (data == null) return null;

    final tempFile = await _createTempFileFromData(
      key,
      data,
    );

    return FileInfo(
      tempFile,
      FileSource.Cache,
      DateTime.now().add(const Duration(days: 30)),
      key,
    );
  }

  // Stub out only the methods your code actually calls:
  @override
  Future<FileInfo> downloadFile(String url,
      {String? key,
      Map<String, String>? authHeaders,
      bool force = false}) async {
    throw UnimplementedError();
  }

  // All other BaseCacheManager methods can just throw or return null
  @override
  Future<void> emptyCache() async {
    _cache.clear();
  }

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) =>
      const Stream.empty();

  @override
  Future<void> removeFile(String key) async {
    _cache.remove(key);
  }

  @override
  Future<void> dispose() async {
    _cache.clear();
  }

  @override
  Stream<FileInfo> getFile(String url,
      {String key = '', Map<String, String> headers = const {}}) {
    throw UnimplementedError();
  }

  @override
  Future<FileInfo?> getFileFromMemory(String key) {
    throw UnimplementedError();
  }

  @override
  Future<File> getSingleFile(String url,
      {String key = '', Map<String, String> headers = const {}}) async {
    final fileKey = key.isEmpty ? url : key;
    final storedData = _cache[fileKey];
    if (storedData != null) {
      return await _createTempFileFromData(fileKey, storedData);
    }
    throw UnimplementedError('File not found in fake cache: $fileKey');
  }

  @override
  Future<File> putFile(String url, Uint8List fileBytes,
      {String? key,
      String? eTag,
      Duration maxAge = const Duration(days: 30),
      String fileExtension = 'file'}) async {
    final fileKey = key ?? url;

    _cache[fileKey] = fileBytes;

    final file = await _createTempFileFromData(fileKey, fileBytes);
    return file;
  }

  @override
  Future<File> putFileStream(String url, Stream<List<int>> source,
      {String? key,
      String? eTag,
      Duration maxAge = const Duration(days: 30),
      String fileExtension = 'file'}) {
    throw UnimplementedError();
  }

  Future<File> _createTempFileFromData(String key, Uint8List data) async {
    final tempDir = io.Directory.systemTemp;
    final fileName = 'fake_cache_${key.hashCode}.tmp';
    final ioFile = io.File('${tempDir.path}/$fileName');
    await ioFile.writeAsBytes(data);
    return ioFile as File;
  }
}
