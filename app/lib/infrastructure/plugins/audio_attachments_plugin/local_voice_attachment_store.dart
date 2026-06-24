import 'dart:typed_data';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../../application/services/chat_service/local_voice_message_data.dart';

/// Retains locally recorded voice payloads for the current app session so the
/// sender can replay and render waveforms before the upload round-trips.
class LocalVoiceAttachmentStore {
  final Map<String, LocalVoiceMessageData> _messages = {};

  void cacheLocalVoiceMessage(
    ChatAttachment attachment,
    Uint8List bytes, {
    required int durationMs,
    required List<int> waveform,
  }) {
    final key = _attachmentKey(attachment);
    if (key == null) return;
    _messages[key] = LocalVoiceMessageData(
      bytes: bytes,
      durationMs: durationMs,
      waveform: waveform,
    );
  }

  LocalVoiceMessageData? localVoiceMessageFor(ChatAttachment attachment) {
    final key = _attachmentKey(attachment);
    if (key == null) return null;
    return _messages[key];
  }

  void removeLocalVoiceMessage(ChatAttachment attachment) {
    final key = _attachmentKey(attachment);
    if (key != null) _messages.remove(key);
  }

  List<chat.ChatItem> withLocalVoiceMetadata(List<chat.ChatItem> messages) {
    var didChange = false;
    final nextMessages = messages
        .map((item) {
          if (item is! chat.Message || !item.isFromMe) return item;

          var messageDidChange = false;
          final nextAttachments = item.attachments
              .map((attachment) {
                if (!chat.VoiceMessageMetadata.isVoice(attachment)) {
                  return attachment;
                }
                final localVoiceMessage = localVoiceMessageFor(attachment);
                if (localVoiceMessage == null) return attachment;
                final voice = chat.VoiceMessageMetadata.of(attachment);
                if (voice?.waveform?.isNotEmpty == true &&
                    voice?.durationMs != null) {
                  return attachment;
                }

                messageDidChange = true;
                didChange = true;
                return ChatAttachment(
                  id: attachment.id,
                  description: attachment.description,
                  filename: attachment.filename,
                  mediaType: attachment.mediaType,
                  format: attachment.format,
                  lastModifiedTime: attachment.lastModifiedTime,
                  data: attachment.data,
                  byteCount: attachment.byteCount,
                  transportId: attachment.transportId,
                  metadata: chat.VoiceMessageMetadata(
                    durationMs:
                        voice?.durationMs ?? localVoiceMessage.durationMs,
                    waveform: voice?.waveform?.isNotEmpty == true
                        ? voice!.waveform
                        : localVoiceMessage.waveform,
                  ).toMetadata(),
                );
              })
              .toList(growable: false);

          if (!messageDidChange) return item;
          return chat.Message(
            chatId: item.chatId,
            messageId: item.messageId,
            senderDid: item.senderDid,
            isFromMe: item.isFromMe,
            dateCreated: item.dateCreated,
            status: item.status,
            type: item.type,
            value: item.value,
            attachments: nextAttachments,
            reactions: item.reactions,
            editedAt: item.editedAt,
            transportId: item.transportId,
            isDeleted: item.isDeleted,
            isDeletedLocally: item.isDeletedLocally,
          );
        })
        .toList(growable: false);

    return didChange ? nextMessages : messages;
  }

  String? _attachmentKey(ChatAttachment attachment) {
    final id = attachment.id;
    if (id == null || id.isEmpty) return null;
    return id;
  }
}

final localVoiceAttachmentStoreProvider = Provider<LocalVoiceAttachmentStore>((
  ref,
) {
  ref.keepAlive();
  return LocalVoiceAttachmentStore();
});