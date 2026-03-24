import 'package:clock/clock.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:uuid/uuid.dart';

class RecordedAudioAttachment implements MessageAttachment {
  RecordedAudioAttachment({
    required String base64,
    required String pluginName,
    required String mediaType,
  }) : _base64 = base64,
       _pluginName = pluginName,
       _mediaType = mediaType;

  final String _base64;
  final String _pluginName;
  final String _mediaType;

  @override
  String get pluginName => _pluginName;

  @override
  Attachment toAttachment() => Attachment(
    id: const Uuid().v4(),
    mediaType: _mediaType,
    format: _pluginName,
    lastModifiedTime: clock.now(),
    data: AttachmentData(base64: _base64),
  );
}
