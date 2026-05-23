import 'package:mpx_app_core/mpx_app_core.dart';

import 'vrc_attachment.dart';

class VrcMessageAttachment implements MessageAttachment {
  VrcMessageAttachment({required this.vcBlob});

  final String vcBlob;

  @override
  String get pluginName => VrcAttachment.pluginFormat;

  @override
  Attachment toAttachment() => VrcAttachment(vcBlob: vcBlob).toAttachment();
}
