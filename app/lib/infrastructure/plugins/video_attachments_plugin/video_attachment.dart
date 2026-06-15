import 'package:clock/clock.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:uuid/uuid.dart';

/// A message attachment representing a video picked from the gallery.
class VideoAttachment implements MessageAttachment {
  VideoAttachment({
    required String base64,
    required String pluginName,
    required String mimeType,
    required String filename,
    required int byteCount,
  }) : _base64 = base64,
       _pluginName = pluginName,
       _mimeType = mimeType,
       _filename = filename,
       _byteCount = byteCount;

  final String _base64;
  final String _pluginName;
  final String _mimeType;
  final String _filename;
  final int _byteCount;

  @override
  String get pluginName => _pluginName;

  @override
  ChatAttachment toAttachment() => ChatAttachment(
    id: const Uuid().v4(),
    mediaType: _mimeType,
    format: _pluginName,
    filename: _filename,
    lastModifiedTime: clock.now(),
    byteCount: _byteCount,
    data: ChatAttachmentData(base64: _base64),
  );
}
