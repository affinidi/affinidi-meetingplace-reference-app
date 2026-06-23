import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show CallMediaType, CallMetadata, CallStatus, ChatAttachment, Message;

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/providers/pending_call_session_provider.dart';
import '../../../widgets/banners/active_call/active_call_controller.dart';
import '../audio_video_call/audio_video_call_screen.dart';
import '../audio_video_call/rules/call_chat_item_rules.dart';

/// Renders a call (audio / video) chat item as a thick-bordered card, modelled
/// on the RCard chat tile.
///
/// The displayed status and visual treatment are derived purely from the
/// stored [CallMetadata] and the message ownership. An optional return-to-call
/// callback is invoked when the item is tappable (an active call to return to).
class CallChatItem extends ConsumerWidget {
  const CallChatItem({
    super.key,
    required this._message,
    required this._attachment,
    required this._chatItemColor,
    required this._contactId,
  });

  final Message _message;
  final ChatAttachment _attachment;
  final Color _chatItemColor;
  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final call = CallMetadata.maybeOf(_attachment);
    if (call == null) return const SizedBox.shrink();

    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    final isFromMe = _message.isFromMe;
    final isTappable = isCallChatItemTappable(
      status: call.status,
      isFromMe: isFromMe,
    );

    final colors = resolveCallChatItemColors(
      status: call.status,
      isFromMe: isFromMe,
      chatItemColor: _chatItemColor,
      colorScheme: colorScheme,
      customColors: context.customColors,
    );

    final title = call.mediaType == CallMediaType.audio
        ? l10n.callChatItemAudioCall
        : l10n.callChatItemVideoCall;
    final statusText = resolveCallChatItemStatusText(
      status: call.status,
      isFromMe: isFromMe,
      durationMs: call.durationMs,
      callStartedAt: _message.dateCreated,
      l10n: l10n,
    );

    return SizedBox(
      height: 90.0,
      child: GestureDetector(
        onTap: isTappable
            ? () {
                if (call.status == CallStatus.inProgress) {
                  final session = ref
                      .read(activeCallControllerProvider.notifier)
                      .session;
                  if (session != null) {
                    ref.read(pendingCallSessionProvider.notifier).state =
                        session;
                  }
                }
                unawaited(
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => AudioVideoCallScreen(
                        contactId: _contactId,
                        isAudioOnly: call.mediaType == CallMediaType.audio,
                      ),
                    ),
                  ),
                );
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _chatItemColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.iconContainer,
                ),
                child: Icon(
                  call.mediaType == CallMediaType.audio
                      ? Icons.call
                      : Icons.videocam,
                  size: 24,
                  color: colors.icon,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Text(
                      title,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.content,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      statusText,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.content,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
