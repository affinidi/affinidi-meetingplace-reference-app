import 'dart:convert';

import 'package:mpx_app_core/mpx_app_core.dart';

import '../plugins/vrc_attachments_plugin/vrc_attachment.dart';
import '../plugins/vrc_attachments_plugin/vrc_request_attachment.dart';

extension AttachmentVrcX on Attachment {
  bool get isVrc => format == VrcAttachment.pluginFormat;

  String? get vrcVcBlob {
    if (!isVrc) return null;
    final json = data?.json;
    if (json == null || json.isEmpty) return null;
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic> && decoded.containsKey('vcBlob')) {
        return decoded['vcBlob'] as String?;
      }
      return json;
    } catch (_) {
      return json;
    }
  }
}

extension AttachmentVrcRequestX on Attachment {
  bool get isVrcRequest => format == VrcRequestAttachment.pluginFormat;

  String? get vrcRequestIdentityDid {
    if (!isVrcRequest) return null;
    try {
      final decoded = jsonDecode(data?.json ?? '{}') as Map<String, dynamic>;
      return decoded['identityDid'] as String?;
    } catch (_) {
      return null;
    }
  }

  String? get vrcRequestIdentityName {
    if (!isVrcRequest) return null;
    try {
      final decoded = jsonDecode(data?.json ?? '{}') as Map<String, dynamic>;
      return decoded['identityName'] as String?;
    } catch (_) {
      return null;
    }
  }
}
