/// Categorises a MIME type into a broad media category for UI routing.
enum MediaCategory { image, video, audio, document }

/// Determines the [MediaCategory] from a MIME type string.
///
/// Returns [MediaCategory.document] for unknown or null types.
MediaCategory mediaCategoryFromMimeType(String? mimeType) {
  if (mimeType == null || mimeType.isEmpty) return MediaCategory.document;
  final lower = mimeType.toLowerCase();
  if (lower.startsWith('image/')) return MediaCategory.image;
  if (lower.startsWith('video/')) return MediaCategory.video;
  if (lower.startsWith('audio/')) return MediaCategory.audio;
  return MediaCategory.document;
}
