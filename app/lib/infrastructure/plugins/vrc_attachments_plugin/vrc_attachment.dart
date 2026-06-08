import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:uuid/uuid.dart';

class VrcAttachment implements MessageAttachment {
  VrcAttachment({required String vcBlob}) : _vcBlob = vcBlob;

  static const pluginFormat = 'mpx_vrc_attachment_plugin';

  final String _vcBlob;

  @override
  String get pluginName => pluginFormat;

  @override
  Attachment toAttachment() {
    final payload = jsonEncode({'vcBlob': _vcBlob});
    return Attachment(
      id: const Uuid().v4(),
      mediaType: 'application/json',
      format: pluginFormat,
      lastModifiedTime: clock.now(),
      data: AttachmentData(json: payload),
    );
  }
}
