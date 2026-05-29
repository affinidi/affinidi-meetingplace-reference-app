import 'package:collection/collection.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

String attachmentCacheKey(chat.ChatAttachment attachment) {
  final parts = <String?>[
    attachment.id,
    attachment.data?.hash,
    attachment.data?.links?.firstOrNull?.toString(),
    attachment.filename,
    attachment.mediaType,
    attachment.description,
    attachment.byteCount?.toString(),
    attachment.data?.json,
  ].whereType<String>().where((part) => part.isNotEmpty).toList();

  if (parts.isEmpty) {
    return 'chat_attachment_${identityHashCode(attachment)}';
  }

  return 'chat_attachment_${parts.join('|')}';
}
