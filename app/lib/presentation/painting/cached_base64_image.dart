import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachedBase64Image extends ImageProvider<CachedBase64Image> {
  CachedBase64Image(
    this.base64String, {
    this.scale = 1.0,
    required this._cacheManager,
  });

  final BaseCacheManager _cacheManager;

  /// The base64 string to decode into an image.
  final String base64String;

  /// The scale to place in the [ImageInfo] object of the image.
  ///
  /// See also:
  ///
  ///  * [ImageInfo.scale], which gives more information on how this scale is
  ///    applied.
  final double scale;

  @override
  Future<CachedBase64Image> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedBase64Image>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    CachedBase64Image key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(_loadAsync(key, decode: decode));
  }

  Future<ImageInfo> _loadAsync(
    CachedBase64Image key, {
    required ImageDecoderCallback decode,
  }) async {
    assert(key == this);

    final fileInfo = await _cacheManager.getFileFromCache(base64String);

    late Uint8List fileBytes;
    if (fileInfo == null) {
      fileBytes = base64Decode(base64String);
      await _cacheManager.putFile(base64String, fileBytes);
    } else {
      fileBytes = await fileInfo.file.readAsBytes();
    }

    final codec = await decode(await ImmutableBuffer.fromUint8List(fileBytes));
    final frame = await codec.getNextFrame();
    return ImageInfo(image: frame.image, scale: scale);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CachedBase64Image &&
        other.base64String == base64String &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(base64String.hashCode, scale);

  @override
  String toString() =>
      '''${objectRuntimeType(this, 'CachedBase64Image')}(${describeIdentity(base64String)}, scale: ${scale.toStringAsFixed(1)})''';
}
