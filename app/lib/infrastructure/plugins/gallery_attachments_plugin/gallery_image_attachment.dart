import 'package:clock/clock.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

/// A message attachment representing an image picked from the gallery.
///
/// Stores the base64-encoded image data and plugin name. Can be converted
/// into a standard `ChatAttachment` object with JPEG media type and generated
/// UUID identifier.
class GalleryImageAttachment implements MessageAttachment {
  GalleryImageAttachment({
    required this.id,
    required this._base64,
    required this._pluginName,
  });

  final String id;
  final String _base64;
  final String _pluginName;
  final String _mediaType = AttachmentMediaType.imageJpeg.value;

  @override
  String get pluginName => _pluginName;

  @override
  ChatAttachment toAttachment() => ChatAttachment(
    id: id,
    mediaType: _mediaType,
    format: pluginName,
    lastModifiedTime: clock.now(),
    data: ChatAttachmentData(base64: _base64),
  );
}
