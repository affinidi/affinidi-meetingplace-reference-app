import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:uuid/uuid.dart';

class VrcRequestAttachment implements MessageAttachment {
  const VrcRequestAttachment({
    required this.identityDid,
    required this.identityName,
  });

  static const pluginFormat = 'mpx_vrc_request_plugin';

  final String identityDid;
  final String identityName;

  @override
  String get pluginName => pluginFormat;

  @override
  Attachment toAttachment() {
    return Attachment(
      id: const Uuid().v4(),
      mediaType: 'application/json',
      format: pluginFormat,
      lastModifiedTime: clock.now(),
      data: AttachmentData(
        json: jsonEncode({
          'identityDid': identityDid,
          'identityName': identityName,
        }),
      ),
    );
  }
}
