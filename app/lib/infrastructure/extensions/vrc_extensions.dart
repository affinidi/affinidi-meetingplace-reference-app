import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:mpx_app_core/mpx_app_core.dart';

import '../plugins/vrc_attachments_plugin/vrc_attachment.dart';
import '../plugins/vrc_attachments_plugin/vrc_request_attachment.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Attachment extensions
// ─────────────────────────────────────────────────────────────────────────────

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

// ─────────────────────────────────────────────────────────────────────────────
// ChatItem list extensions — VRC exchange state derived from message history
// ─────────────────────────────────────────────────────────────────────────────

extension ChatItemListVrcX on List<chat.ChatItem> {
  bool get hasVrcExchangeCompleted => any(
    (message) =>
        message is chat.EventMessage &&
        message.eventType ==
            chat.EventMessageType.fromJson('vrcExchangeCompleted'),
  );

  bool get hasVrcExchangeInitiated => any(
    (message) =>
        message is chat.EventMessage &&
        message.eventType ==
            chat.EventMessageType.fromJson('vrcExchangeInitiated'),
  );

  bool get hasVrcRequestReceived => any(
    (message) =>
        message is chat.EventMessage &&
        message.eventType ==
            chat.EventMessageType.fromJson('vrcRequestReceived'),
  );

  String? get vrcInitiatorIdentityDid {
    final event = whereType<chat.EventMessage>().firstWhereOrNull(
      (message) =>
          message.eventType ==
          chat.EventMessageType.fromJson('vrcExchangeInitiated'),
    );
    return event?.data['identityDid'] as String?;
  }

  String? get vrcInitiatorIdentityName {
    final event = whereType<chat.EventMessage>().firstWhereOrNull(
      (message) =>
          message.eventType ==
          chat.EventMessageType.fromJson('vrcExchangeInitiated'),
    );
    return event?.data['identityName'] as String?;
  }
}
