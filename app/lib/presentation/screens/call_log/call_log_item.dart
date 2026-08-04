part of 'call_log_screen.dart';

/// Renders a single past-call entry. Tapping this item is intentionally a
/// no-op — the Call log screen has no per-item action or navigation.
class _CallLogItem extends StatelessWidget {
  const _CallLogItem({required this.entry});

  final CallLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    // resolveCallChatItemStatusText returns "Tap to return" for an
    // in-progress call, which is meant for the live in-chat call item where
    // tapping does return to the call. Tapping a call log entry is a no-op,
    // so that copy is misleading here and is overridden below.
    final statusText = entry.status == CallStatus.inProgress
        ? l10n.callLogInProgress
        : resolveCallChatItemStatusText(
            status: entry.status,
            isFromMe: entry.isFromMe,
            durationMs: entry.durationMs,
            callStartedAt: entry.timestamp,
            l10n: l10n,
            mediaType: entry.mediaType,
          );

    final participantNames = entry.participantNames;
    final participantsLabel = entry.isGroupCall
        ? (participantNames != null && participantNames.isNotEmpty
              ? participantNames.join(', ')
              : l10n.callLogParticipantsCount(entry.participantCount))
        : null;

    return Card(
      color: colorScheme.inverseSurface.withValues(alpha: 0.5),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              entry.mediaType == CallMediaType.audio
                  ? Icons.call
                  : Icons.videocam,
              color: colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.displayLabel,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(statusText, style: textTheme.labelSmall),
                  if (participantsLabel != null)
                    Text(participantsLabel, style: textTheme.labelSmall),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('MMM d, h:mm a').format(entry.timestamp.toLocal()),
              style: textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
