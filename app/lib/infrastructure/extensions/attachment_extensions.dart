import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

extension AttachmentToChatAttachmentX on Attachment {
  ChatAttachment toChatAttachment() => ChatAttachment(
    id: id,
    description: description,
    filename: filename,
    mediaType: mediaType,
    format: format,
    lastModifiedTime: lastModifiedTime,
    data: data == null
        ? null
        : ChatAttachmentData(
            jws: data!.jws,
            hash: data!.hash,
            links: data!.links,
            base64: data!.base64,
            json: data!.json,
          ),
    byteCount: byteCount,
  );
}
