import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// A container for compressed/encoded image results.
class CompressedImage {
  CompressedImage({
    required this.succeeded,
    required this.path,
    required this.base64,
    required this.bytes,
  });
  CompressedImage.empty() : path = '', bytes = Uint8List(0), base64 = '';
  String path;
  String base64;
  Uint8List bytes;
  bool succeeded = false;
}

/// Compress and resize from a file path
Future<CompressedImage> compressAndResizeImageFromFileAsBase64({
  required XFile image,
  required int imageSize,
  required int qualityPercent,
}) async {
  final bytes = await image.readAsBytes();
  final decoded = img.decodeImage(bytes);

  if (decoded == null) return CompressedImage.empty();

  final compressedBytes = _compressAndResize(
    image: decoded,
    imageSize: imageSize,
    qualityPercent: qualityPercent,
  );
  if (compressedBytes.isEmpty) return CompressedImage.empty();

  // Save the compressed image to a file
  final compressedFile = XFile.fromData(
    Uint8List.fromList(compressedBytes),
    mimeType: 'image/jpeg',
    name: image.name.replaceFirst(
      RegExp(r'\.(jpg|jpeg|png)$'),
      '_compressed.jpg',
    ),
  );

  return CompressedImage(
    succeeded: true,
    path: compressedFile.path,
    base64: base64Encode(compressedBytes),
    bytes: compressedBytes,
  );
}

/// Lowest JPEG quality [thumbnailFromBase64] tries before giving up.
const _thumbnailMinQualityPercent = 30;
const _thumbnailQualityStepPercent = 10;

/// A JPEG thumbnail of the base64-encoded [image], at most [imageSize] on its
/// longest side and at most [maxLength] characters of base64.
///
/// Quality is lowered step by step until the thumbnail fits. Returns null
/// when [image] cannot be decoded or no quality fits [maxLength].
String? thumbnailFromBase64(
  String image, {
  required int imageSize,
  required int maxLength,
  int qualityPercent = 80,
}) {
  final decoded = _decodeBase64Image(image);
  if (decoded == null) return null;

  final longestSide = decoded.width > decoded.height
      ? decoded.width
      : decoded.height;
  final size = longestSide < imageSize ? longestSide : imageSize;

  for (
    var quality = qualityPercent;
    quality >= _thumbnailMinQualityPercent;
    quality -= _thumbnailQualityStepPercent
  ) {
    final thumbnail = base64Encode(
      _compressAndResize(
        image: decoded,
        imageSize: size,
        qualityPercent: quality,
      ),
    );
    if (thumbnail.length <= maxLength) return thumbnail;
  }
  return null;
}

/// The decoders throw, rather than return null, on some bytes that are not
/// an image they know, so any failure reads as "not a picture".
img.Image? _decodeBase64Image(String image) {
  try {
    return img.decodeImage(base64Decode(image));
  } catch (_) {
    return null;
  }
}

Uint8List _compressAndResize({
  required img.Image image,
  required int imageSize,
  required int qualityPercent,
}) {
  int width, height;

  if (image.width > image.height) {
    width = imageSize;
    height = (image.height / image.width * imageSize).round();
  } else {
    height = imageSize;
    width = (image.width / image.height * imageSize).round();
  }

  var resized = img.copyResize(image, width: width, height: height);

  return Uint8List.fromList(img.encodeJpg(resized, quality: qualityPercent));
}
