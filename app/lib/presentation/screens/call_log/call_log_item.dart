part of 'call_log_screen.dart';

/// Resolves the participants label shown under a group call log entry, or
/// `null` for a 1:1 call.
///
/// [CallLogEntry.participantNames] only carries the subset of
/// [CallLogEntry.participantCount] peers whose DID resolved to a known
/// contact (see [CallParticipation.participantDids]), so a partial match
/// must not be rendered as if it were the full roster. Falls back to the
/// count label when no name resolved; appends the unresolved remainder as
/// "and N others" when some, but not all, resolved.
String? resolveCallLogParticipantsLabel(
  AppLocalizations l10n,
  CallLogEntry entry,
) {
  if (!entry.isGroupCall) return null;

  final participantNames = entry.participantNames;
  if (participantNames == null || participantNames.isEmpty) {
    return l10n.callLogParticipantsCount(entry.participantCount);
  }

  final unresolvedCount = entry.participantCount - participantNames.length;
  if (unresolvedCount <= 0) return participantNames.join(', ');

  return l10n.callLogParticipantsNamesAndOthers(
    participantNames.join(', '),
    unresolvedCount,
  );
}

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

    final participantsLabel = resolveCallLogParticipantsLabel(l10n, entry);

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
              DateFormat(
                'MMM d, h:mm a',
                l10n.localeName,
              ).format(entry.timestamp.toLocal()),
              style: textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
