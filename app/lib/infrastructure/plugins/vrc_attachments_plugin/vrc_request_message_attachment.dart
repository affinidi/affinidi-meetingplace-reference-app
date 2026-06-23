import 'package:mpx_app_core/mpx_app_core.dart';

import 'vrc_request_attachment.dart';

class VrcRequestMessageAttachment implements MessageAttachment {
  const VrcRequestMessageAttachment({
    required this.identityDid,
    required this.identityName,
  });

  final String identityDid;
  final String identityName;

  @override
  String get pluginName => VrcRequestAttachment.pluginFormat;

  @override
  ChatAttachment toAttachment() => VrcRequestAttachment(
    identityDid: identityDid,
    identityName: identityName,
  ).toAttachment();
}
