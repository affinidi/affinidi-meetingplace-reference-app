part of 'r_card_attachments_plugin.dart';

class _RCardMessageAttachment implements MessageAttachment {
  _RCardMessageAttachment({required Attachment attachment})
    : _attachment = attachment;

  final Attachment _attachment;

  @override
  String get pluginName => RCardAttachment.pluginFormat;

  @override
  Attachment toAttachment() => _attachment;
}
