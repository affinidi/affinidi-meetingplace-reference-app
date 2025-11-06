import 'message_attachment.dart';

class AttachmentPluginPickResult {
  AttachmentPluginPickResult({required this.text, required this.attachments});

  final String text;
  final List<MessageAttachment> attachments;
}
