import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:meeting_place_relationship/meeting_place_relationship.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:uuid/uuid.dart';

class RCardAttachment implements MessageAttachment {
  RCardAttachment({required String vcBlob}) : _vcBlob = vcBlob;

  /// The DIDComm attachment format identifier for R-Card attachments.
  ///
  /// Mirrors [RCardDIDCommAttachmentBuilder.attachmentFormat] — use either;
  /// they are the same value.
  static const pluginFormat = RCardDIDCommAttachmentBuilder.attachmentFormat;

  final String _vcBlob;

  @override
  String get pluginName => pluginFormat;

  @override
  Attachment toAttachment() {
    final payload = jsonEncode({'vcBlob': _vcBlob, 'isUpdate': false});
    return Attachment(
      id: const Uuid().v4(),
      mediaType: 'application/json',
      format: pluginFormat,
      lastModifiedTime: clock.now(),
      data: AttachmentData(json: payload),
    );
  }
}

extension AttachmentRCardX on Attachment {
  bool get isRCard => format == RCardAttachment.pluginFormat;

  String? get rCardVcBlob {
    if (!isRCard) return null;
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

  bool get isRCardUpdate {
    if (!isRCard) return false;
    final json = data?.json;
    if (json == null || json.isEmpty) return false;
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return (decoded['isUpdate'] as bool?) ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  bool get isRCardAutoExchange {
    if (!isRCard) return false;
    final json = data?.json;
    if (json == null || json.isEmpty) return false;
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map<String, dynamic>) {
        return (decoded['isAutoExchange'] as bool?) ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  String? get rCardSubjectDid {
    final vcBlob = rCardVcBlob;
    if (vcBlob == null || vcBlob.isEmpty) return null;
    try {
      return RCardSubject.fromVcBlob(vcBlob).id;
    } on FormatException {
      return null;
    }
  }
}
