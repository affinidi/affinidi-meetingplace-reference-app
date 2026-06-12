import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;

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
}
