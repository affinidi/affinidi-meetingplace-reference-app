import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:mpx_app_core/mpx_app_core.dart';

import '../../extensions/build_context_extensions.dart';
import 'local_voice_attachment_store.dart';
import 'voice_attachment_widget.dart';

/// Renders voice-message attachments recorded or received in chat.
///
/// Voice notes are captured from the chat input rather than the attachment
/// sheet, so this plugin only implements [AttachmentRenderer].
final class AudioAttachmentsPlugin implements AttachmentRenderer {
  AudioAttachmentsPlugin({
    required this._cacheManager,
    required this._localVoiceStore,
  });

  static const pluginName = 'mpx_audio_attachment_plugin';

  final BaseCacheManager _cacheManager;
  final LocalVoiceAttachmentStore _localVoiceStore;

  String cacheKeyForAudioAttachment(String attachmentId) =>
      '$pluginName:$attachmentId';

  @override
  bool get isPlatformSupported => false;

  @override
  Widget renderAttachment(AttachmentRenderRequest request) =>
      VoiceAttachmentWidget(
        attachment: request.attachment,
        isFromMe: request.isFromMe,
        chatItemColor: request.chatItemColor,
        cacheManager: _cacheManager,
        cacheKey: cacheKeyForAudioAttachment(request.attachment.id),
        localVoiceStore: _localVoiceStore,
        avatarImage: request.renderContext?.avatarImage,
        playbackScopeId: request.renderContext?.playbackScopeId,
        playbackClipId: request.renderContext?.playbackClipId,
        download: request.download,
      );

  @override
  Widget renderAttachments(AttachmentListRenderRequest request) =>
      ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: request.attachments.length,
        itemBuilder: (context, index) => VoiceAttachmentWidget(
          attachment: request.attachments[index],
          isFromMe: request.isFromMe,
          chatItemColor: request.chatItemColor,
          cacheManager: _cacheManager,
          cacheKey: cacheKeyForAudioAttachment(request.attachments[index].id),
          localVoiceStore: _localVoiceStore,
          avatarImage: request.renderContext?.avatarImage,
          playbackScopeId: request.renderContext?.playbackScopeId,
          playbackClipId: request.renderContext?.playbackClipId,
          download: request.download,
        ),
      );

  @override
  bool supportsFormat(ChatAttachment attachment) =>
      chat.VoiceMessageMetadata.isVoice(attachment);

  @override
  AttachmentPluginIcon get icon => const EmojiIcon('🎤');

  @override
  String localizedName(BuildContext context) => context.l10n.generalVoice;
}
