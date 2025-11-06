/// Describes image export/compression settings used across the app.
///
/// Factory parameters:
/// - [qualityPercentage] - JPEG quality percentage (0-100) applied when
///  encoding images.
/// - [imageMaxSize] - Maximum image dimension in pixels (largest width
///  or height) to resize images to.
class ImageConfig {
  ImageConfig({required this.qualityPercentage, required this.imageMaxSize});

  final int qualityPercentage;
  final int imageMaxSize;
}
