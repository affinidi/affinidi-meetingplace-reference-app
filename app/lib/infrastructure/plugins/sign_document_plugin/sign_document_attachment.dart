import 'package:clock/clock.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:uuid/uuid.dart';

/// Carries the document bytes for a `cierge/sign-document-request` as an
/// external chat attachment (uploaded to media storage) so large documents do
/// not exceed the transport event-size limit. The connector recognises it by
/// its [format].
class SignDocumentAttachment implements MessageAttachment {
  SignDocumentAttachment({
    required this._base64,
    required this._mimeType,
    required this._filename,
    required this._byteCount,
  });

  /// Attachment format tag shared with the connector.
  static const format = 'cierge/sign-document';

  final String _base64;
  final String _mimeType;
  final String _filename;
  final int _byteCount;

  @override
  String get pluginName => format;

  @override
  ChatAttachment toAttachment() => ChatAttachment(
    id: const Uuid().v4(),
    mediaType: _mimeType,
    format: format,
    filename: _filename,
    lastModifiedTime: clock.now(),
    byteCount: _byteCount,
    data: ChatAttachmentData(base64: _base64),
  );
}
