import 'package:meeting_place_chat/meeting_place_chat.dart';
import '../../../mpx_app_core.dart';

abstract interface class MessageAttachment {
  MessageAttachment({required this.pluginName});

  final String pluginName;

  ChatAttachment toAttachment();
}
