part of '../chat_screen.dart';

/// Renders a call (audio / video) chat item as a thick-bordered card, modelled
/// on the RCard chat tile.
///
/// The displayed status and visual treatment are derived purely from the
/// stored [CallMetadata] and the message ownership. An optional return-to-call
/// callback is invoked when the item is tappable (an active call to return to).
class _CallChatItem extends ConsumerWidget {
  const _CallChatItem({
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
    final logger = ref.read(appLoggerProvider);

    final isFromMe = _message.isFromMe;
    final isTappable = isCallChatItemTappable(
      status: call.status,
      isFromMe: isFromMe,
    );
    final isRecallable = isCallChatItemRecallable(call.status);

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
      mediaType: call.mediaType,
      participation: call.participation,
    );

    return SizedBox(
      height: 90.0,
      child: GestureDetector(
        onTap: isTappable
            ? () {
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
            : isRecallable
            ? () {
                unawaited(
                  _CallChatItemActions.show(
                    context: context,
                    contactId: _contactId,
                    mediaType: call.mediaType,
                  ).catchError((Object error, StackTrace stackTrace) {
                    logger.error(
                      'Failed to open recall actions sheet',
                      error: error,
                      stackTrace: stackTrace,
                      name: '_CallChatItem',
                    );
                  }),
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
