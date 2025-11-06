import 'package:clock/clock.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:uuid/uuid.dart';

/// A message attachment representing an image picked from the gallery.
///
/// Stores the base64-encoded image data and plugin name. Can be converted
/// into a standard [Attachment] object with JPEG media type and generated
/// UUID identifier.
class GalleryImageAttachment implements MessageAttachment {
  GalleryImageAttachment({
    required String base64,
    required String pluginName,
  })  : _base64 = base64,
        _pluginName = pluginName;

  final String _base64;
  final String _pluginName;
  final String _mediaType = AttachmentMediaType.imageJpeg.value;

  @override
  String get pluginName => _pluginName;

  @override
  Attachment toAttachment() => Attachment(
        id: const Uuid().v4(),
        mediaType: _mediaType,
        format: _pluginName,
        lastModifiedTime: clock.now(),
        data: AttachmentData(
          base64: _base64,
        ),
      );
}
