import '../../../mpx_app_core.dart';

abstract interface class MessageAttachment {
  MessageAttachment({required this.pluginName});

  final String pluginName;

  ChatAttachment toAttachment();
}
