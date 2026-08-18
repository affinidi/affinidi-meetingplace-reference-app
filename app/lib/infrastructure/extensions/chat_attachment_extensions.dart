import 'dart:convert';

import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

import '../plugins/cierge_signature_attachments_plugin/cierge_signature_attachments_plugin.dart';
import '../plugins/cierge_trust_task_plugin/cierge_trust_task_plugin.dart';

extension ChatAttachmentExtension on chat.ChatAttachment {
  /// Returns `true` when this attachment is a voice message.
  ///
  /// Matches attachments that carry the explicit `media_kind: voice` metadata
  /// marker (set by [chat.VoiceMessageMetadata.buildAttachment]) as well as
  /// attachments with an `audio/` MIME type that pre-date the metadata column
  /// (legacy rows whose metadata was never persisted).
  bool get isVoice {
    if (chat.VoiceMessageMetadata.isVoice(this)) return true;
    return mediaType?.toLowerCase().startsWith('audio/') ?? false;
  }

  /// Returns `true` when this attachment marks a Cierge agent-authored reply.
  bool get isCiergeAgentMarker {
    return format == CiergeSignatureAttachmentsPlugin.pluginFormat ||
        format == CiergeTrustTaskPlugin.pluginFormat;
  }

  /// Owner DIDs the connector stamped on a `cierge/signature` attachment so a
  /// group agent reply can be attributed back to the owning member. Empty when
  /// this attachment carries no owner metadata.
  List<String> get ciergeOwnerDids {
    if (format != CiergeSignatureAttachmentsPlugin.pluginFormat &&
        format != CiergeTrustTaskPlugin.pluginFormat) {
      return const [];
    }
    final fromFilename = _ownerDidsFromFilename();
    if (fromFilename.isNotEmpty) return fromFilename;
    final inline = metadata?['ownerDids'];
    if (inline is List) {
      return inline.whereType<String>().where((d) => d.isNotEmpty).toList();
    }
    final raw = data?.json ?? _decodeBase64(data?.base64);
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const [];
      final owners = decoded['ownerDids'];
      if (owners is! List) return const [];
      return owners.whereType<String>().where((d) => d.isNotEmpty).toList();
    } on FormatException {
      return const [];
    }
  }

  /// Reads the owner DIDs from the `cierge-signature.<token>.json` filename,
  /// the only inline attachment field that survives the Matrix transport.
  List<String> _ownerDidsFromFilename() {
    final name = filename;
    if (name == null) return const [];
    final match = RegExp(r'^cierge-signature\.([^.]+)\.json$').firstMatch(name);
    if (match == null) return const [];
    try {
      final decoded = jsonDecode(
        utf8.decode(base64Url.decode(match.group(1)!)),
      );
      // Token encodes the full metadata map {ownerDids:[...], context:...}.
      final owners = decoded is Map ? decoded['ownerDids'] : decoded;
      if (owners is! List) return const [];
      return owners.whereType<String>().where((d) => d.isNotEmpty).toList();
    } on FormatException {
      return const [];
    }
  }

  String? _decodeBase64(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      return utf8.decode(base64Decode(value));
    } on FormatException {
      return null;
    }
  }
}
