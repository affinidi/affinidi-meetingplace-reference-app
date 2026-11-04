import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mpx_flutter_reference_app/presentation/widgets/images/compressed_image.dart';

String _jpeg({required int width, required int height}) {
  final image = img.Image(width: width, height: height);
  // Noise keeps the JPEG from compressing to almost nothing.
  for (final pixel in image) {
    pixel
      ..r = (pixel.x * 37 + pixel.y * 11) % 256
      ..g = (pixel.x * 13 + pixel.y * 29) % 256
      ..b = (pixel.x * 7 + pixel.y * 41) % 256;
  }
  return base64Encode(img.encodeJpg(image, quality: 100));
}

img.Image _decoded(String base64) => img.decodeImage(base64Decode(base64))!;

void main() {
  group('thumbnailFromBase64', () {
    test('shrinks the longest side to the size, keeping the shape', () {
      final thumbnail = thumbnailFromBase64(
        _jpeg(width: 1024, height: 512),
        imageSize: 256,
        maxLength: 48 * 1024,
      )!;

      final image = _decoded(thumbnail);
      expect(image.width, 256);
      expect(image.height, 128);
    });

    test('does not enlarge a smaller picture', () {
      final thumbnail = thumbnailFromBase64(
        _jpeg(width: 100, height: 200),
        imageSize: 256,
        maxLength: 48 * 1024,
      )!;

      final image = _decoded(thumbnail);
      expect(image.width, 100);
      expect(image.height, 200);
    });

    test('lowers the quality until the thumbnail fits', () {
      final picture = _jpeg(width: 256, height: 256);
      final atDefaultQuality = thumbnailFromBase64(
        picture,
        imageSize: 256,
        maxLength: 1 << 20,
      )!;

      final thumbnail = thumbnailFromBase64(
        picture,
        imageSize: 256,
        maxLength: atDefaultQuality.length - 1,
      );

      expect(thumbnail, isNotNull);
      expect(thumbnail!.length, lessThan(atDefaultQuality.length));
    });

    test('gives up when no quality fits', () {
      expect(
        thumbnailFromBase64(
          _jpeg(width: 256, height: 256),
          imageSize: 256,
          maxLength: 10,
        ),
        isNull,
      );
    });

    test('gives up on what is not a picture', () {
      expect(
        thumbnailFromBase64('not base64!', imageSize: 256, maxLength: 1024),
        isNull,
      );
      expect(
        thumbnailFromBase64(
          base64Encode(utf8.encode('text')),
          imageSize: 256,
          maxLength: 1024,
        ),
        isNull,
      );
    });
  });
}
