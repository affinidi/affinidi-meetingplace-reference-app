import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' as chat;
import 'package:mpx_app_core/mpx_app_core.dart';

import 'local_voice_attachment_store.dart';
import 'voice_attachment_widget.dart';

/// Renders voice-message attachments recorded or received in chat.
///
/// Voice notes are captured from the chat input rather than the attachment
/// sheet, so [pickAttachments] is not used.
final class AudioAttachmentsPlugin implements AttachmentPlugin {
  AudioAttachmentsPlugin({
    required this._cacheManager,
    required this._localVoiceStore,
  });

  static const pluginName = 'mpx_audio_attachment_plugin';

  final BaseCacheManager _cacheManager;
  final LocalVoiceAttachmentStore _localVoiceStore;

  @override
  bool get dismissSheetBeforePicking => false;

  @override
  bool get isPlatformSupported => false;

  @override
  Future<AttachmentPluginPickResult?> pickAttachments(
    BuildContext context,
  ) async => null;

  @override
  Widget renderAttachment({
    required ChatAttachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => VoiceAttachmentWidget(
    attachment: attachment,
    isFromMe: isFromMe,
    chatItemColor: chatItemColor,
    cacheManager: _cacheManager,
    localVoiceStore: _localVoiceStore,
    download: download,
  );

  @override
  Widget renderAttachments({
    required List<ChatAttachment> attachments,
    required bool isFromMe,
    required Color chatItemColor,
    Future<Uint8List> Function(ChatAttachment)? download,
  }) => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: attachments.length,
    itemBuilder: (context, index) => VoiceAttachmentWidget(
      attachment: attachments[index],
      isFromMe: isFromMe,
      chatItemColor: chatItemColor,
      cacheManager: _cacheManager,
      localVoiceStore: _localVoiceStore,
      download: download,
    ),
  );

  @override
  bool supportsFormat(ChatAttachment attachment) =>
      chat.VoiceMessageMetadata.isVoice(attachment);

  @override
  AttachmentPluginIcon get icon => const EmojiIcon('🎤');

  @override
  String localizedName(BuildContext context) => 'Voice';
}
