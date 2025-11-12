import 'package:meeting_place_core/meeting_place_core.dart';

abstract interface class MessageAttachment {
  MessageAttachment({required this.pluginName});

  final String pluginName;

  Attachment toAttachment();
}
