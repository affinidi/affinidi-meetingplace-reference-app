/// Categorises a MIME type into a broad media category for UI routing.
enum MediaCategory { image, video, audio, document }

/// Playable audio file extensions (lowercase, no leading dot) mapped to the
/// MIME type used both when sending the file and when handing the bytes to the
/// audio player.
const Map<String, String> _audioMimeByExtension = {
  'mp3': 'audio/mpeg',
  'm4a': 'audio/mp4',
  'aac': 'audio/aac',
  'wav': 'audio/wav',
  'ogg': 'audio/ogg',
};

/// Audio file extensions (lowercase, no leading dot) treated as playable audio.
Set<String> get audioFileExtensions => _audioMimeByExtension.keys.toSet();

/// Returns the audio MIME type for [extension] (lowercase, no leading dot), or
/// `null` when it is missing or not a recognised audio type.
String? audioMimeFromExtension(String? extension) =>
    extension == null ? null : _audioMimeByExtension[extension.toLowerCase()];

/// Returns the audio MIME type for [filename]'s extension, or `null` when the
/// extension is missing or not a recognised audio type.
String? audioMimeFromFilename(String? filename) =>
    audioMimeFromExtension(_extensionOf(filename));

/// Determines the [MediaCategory] from a MIME type string.
///
/// When [mimeType] is absent or a generic `application/octet-stream`, falls
/// back to [filename]'s extension to recognise audio files that arrive without
/// a specific MIME type (for example an MP3 sent as a generic file).
///
/// Returns [MediaCategory.document] for unknown or null types.
MediaCategory mediaCategoryFromMimeType(String? mimeType, {String? filename}) {
  final lower = mimeType?.toLowerCase();
  if (lower != null && lower.isNotEmpty) {
    if (lower.startsWith('image/')) return MediaCategory.image;
    if (lower.startsWith('video/')) return MediaCategory.video;
    if (lower.startsWith('audio/')) return MediaCategory.audio;
    if (lower != 'application/octet-stream') return MediaCategory.document;
  }
  if (audioMimeFromFilename(filename) != null) return MediaCategory.audio;
  return MediaCategory.document;
}

/// Returns the lowercase extension (no leading dot) of [filename], or `null`
/// when there is none.
String? _extensionOf(String? filename) {
  if (filename == null) return null;
  final dot = filename.lastIndexOf('.');
  if (dot < 0 || dot == filename.length - 1) return null;
  return filename.substring(dot + 1).toLowerCase();
}
