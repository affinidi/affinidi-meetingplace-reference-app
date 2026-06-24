import 'package:clock/clock.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:uuid/uuid.dart';

import '../../../presentation/screens/media/media_screen/media_screen.dart';

/// Wire format for videos picked from the gallery [MediaScreen].
class VideoAttachment implements MessageAttachment {
  VideoAttachment({
    required this._base64,
    required this._pluginName,
    required this._mimeType,
    required this._filename,
    required this._byteCount,
  });

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
