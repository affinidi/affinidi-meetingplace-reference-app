import 'package:clock/clock.dart';
import 'package:mpx_app_core/mpx_app_core.dart';

/// A message attachment for images captured by the camera.
///
/// Stores the base64-encoded image data and plugin name, and can be
/// converted into a standard `ChatAttachment` object with JPEG media type.
class CameraImageAttachment implements MessageAttachment {
  CameraImageAttachment({
    required this._id,
    required this._base64,
    required this._pluginName,
  });

  final String _id;
  final String _base64;
  final String _pluginName;
  final String _mediaType = AttachmentMediaType.imageJpeg.value;

  @override
  String get pluginName => _pluginName;

  /// Converts this camera image into a standard [ChatAttachment].
  ///
  /// Creates an attachment with:
  /// - The provided id
  /// - JPEG media type
  /// - Plugin name as the format
  /// - Current timestamp as last modified time
  /// - Base64 image data
  @override
  ChatAttachment toAttachment() => ChatAttachment(
    id: _id,
    mediaType: _mediaType,
    format: _pluginName,
    lastModifiedTime: clock.now(),
    data: ChatAttachmentData(base64: _base64),
  );
}
