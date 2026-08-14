import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../presentation/themes/app_custom_colors.dart';
import 'call_ui_rules.dart';

// =========================================================================
// Policy — mapping the shared CallOutcome to the persisted chat item status
// =========================================================================

/// Returns the [CallStatus] to persist on the call chat item for a terminal
/// [CallOutcome].
///
/// [CallOutcome] is the shared, wire-level fact both sides agree on. This is
/// the single authority for the local "who sees what end state" asymmetry, and
/// is reused by both individual and group calls:
///   - [CallOutcome.ended] → [CallStatus.ended] on both sides
///   - any unanswered outcome ([CallOutcome.cancelled], [CallOutcome.declined],
///     [CallOutcome.timedOut]):
///       - caller ([isFromMe] true) → [CallStatus.declined] ("Not answered")
///       - recipient ([isFromMe] false) → [CallStatus.missed] ("Missed")
///
/// [CallOutcome.ongoing] is not a terminal outcome; it maps defensively to
/// [CallStatus.inProgress].
CallStatus resolveEndStatus({
  required CallOutcome outcome,
  required bool isFromMe,
}) => switch (outcome) {
  CallOutcome.ended => CallStatus.ended,
  CallOutcome.ongoing => CallStatus.inProgress,
  CallOutcome.cancelled ||
  CallOutcome.declined ||
  CallOutcome.timedOut => isFromMe ? CallStatus.declined : CallStatus.missed,
};

/// Resolves the shared [CallOutcome] from this device's local session history.
///
/// A call counts as answered ([CallOutcome.ended]) when a peer joined and the
/// last status was not an unanswered terminal. Otherwise it maps the local
/// terminal signal to the matching unanswered outcome: an explicit decline to
/// [CallOutcome.declined], an unanswered timeout to [CallOutcome.timedOut], and
/// a caller leaving before answer to [CallOutcome.cancelled].
CallOutcome resolveCallOutcome({
  required AudioVideoCallStatus lastStatus,
  required bool hasHadPeer,
}) {
  final answered =
      hasHadPeer &&
      lastStatus != AudioVideoCallStatus.declined &&
      lastStatus != AudioVideoCallStatus.missed;
  if (answered) return CallOutcome.ended;
  if (lastStatus == AudioVideoCallStatus.declined) return CallOutcome.declined;
  if (lastStatus == AudioVideoCallStatus.missed) return CallOutcome.timedOut;
  return CallOutcome.cancelled;
}

// =========================================================================
// Group participation — accumulated off the session state stream
// =========================================================================

/// Accumulates the running set of distinct peer participant ids seen during a
/// call, excluding the local party. Drives the "n joined" peer count.
Set<String> accumulateSeenPeerIds({
  required Set<String> previous,
  required List<AudioVideoCallParticipant> participants,
}) {
  final next = {...previous};
  for (final participant in participants) {
    if (!participant.isSelf) next.add(participant.participantId);
  }
  return next;
}

/// Accumulates the running set of distinct peer DIDs seen during a call,
/// excluding the local party. A peer whose DID could not be resolved at the
/// moment it was observed contributes nothing here; [accumulateSeenPeerIds]
/// still counts it via [AudioVideoCallParticipant.participantId].
Set<String> accumulateSeenPeerDids({
  required Set<String> previous,
  required List<AudioVideoCallParticipant> participants,
}) {
  final next = {...previous};
  for (final participant in participants) {
    final did = participant.did;
    if (!participant.isSelf && did != null) next.add(did);
  }
  return next;
}

/// Latch: whether the local party has fully joined the call media session.
/// Once true, stays true for the rest of the call.
bool computeDidSelfJoin({
  required bool previous,
  required AudioVideoCallStatus status,
}) => previous || isConnectedCallStatus(status);

/// The local party's DID from the participant list, or null when not resolved.
String? resolveSelfDid(List<AudioVideoCallParticipant> participants) {
  for (final participant in participants) {
    if (participant.isSelf) return participant.did;
  }
  return null;
}

/// Builds the group participation summary from the accumulated call state.
CallParticipation buildCallParticipation({
  required Set<String> seenPeerIds,
  required bool didSelfJoin,
  required bool selfLeftBeforeEnd,
  String? initiatorDid,
  Set<String> seenPeerDids = const {},
}) => CallParticipation(
  participantCount: seenPeerIds.length,
  didSelfJoin: didSelfJoin,
  selfLeftBeforeEnd: selfLeftBeforeEnd,
  initiatorDid: initiatorDid,
  participantDids: seenPeerDids.toList(growable: false),
);

// =========================================================================
// Render predicates — driven by (status, isFromMe)
// =========================================================================

/// Whether the item shows a missed-call (error) visual treatment.
///
/// True for any unanswered ending: `missed` (recipient) or `declined` (caller).
bool isMissedCallDisplay(CallStatus status) =>
    status == CallStatus.missed || status == CallStatus.declined;

/// Whether tapping the item opens or returns to the call screen.
///
/// Only tappable while a call is in progress (both parties connected).
/// Ringing and calling states are intentionally excluded: the incoming call
/// banner handles answer/reject, and tapping a ringing item would open a
/// blank screen with no live session to restore.
bool isCallChatItemTappable({
  required CallStatus status,
  required bool isFromMe,
}) => status == CallStatus.inProgress;

/// Whether the item represents a finished call that can be re-initiated.
///
/// True for any terminal outcome that isn't currently in progress: `ended`,
/// `missed`, or `declined`. Tapping such an item opens the re-call sheet
/// instead of rejoining a live session.
bool isCallChatItemRecallable(CallStatus status) =>
    status == CallStatus.ended ||
    status == CallStatus.missed ||
    status == CallStatus.declined;

/// Maps any live (non-final) call state to the [CallStatus] to persist on
/// the chat item while a call is in progress.
///
/// Returns null once the call has ended — final writes go through
/// [resolveEndStatus]. Built on the same [resolveCallUiPhase] rule that drives
/// the call screen and banner, so the persisted chat item can never disagree
/// with what the live UI shows.
CallStatus? resolveInProgressCallChatItemStatus({
  required AudioVideoCallStatus status,
  required bool hasHadPeer,
}) {
  final phase = resolveCallUiPhase(status: status, hasHadPeer: hasHadPeer);
  return switch (phase) {
    CallUiPhase.calling => CallStatus.calling,
    CallUiPhase.ringing => CallStatus.ringing,
    CallUiPhase.inCall => CallStatus.inProgress,
    CallUiPhase.ended => null,
  };
}

// =========================================================================
// Status text
// =========================================================================

/// Formats a participation [duration] as e.g. "1 hr 30 min", "2 min 14 sec",
/// or "14 sec".
String formatCallDuration(
  Duration duration, {
  required String Function(int) hourFormat,
  required String Function(int) minuteFormat,
  required String Function(int) secondFormat,
}) {
  final totalSeconds = duration.inSeconds;
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  final parts = <String>[];
  if (hours > 0) {
    parts.add(hourFormat(hours));
    if (minutes > 0) parts.add(minuteFormat(minutes));
  } else if (minutes > 0) {
    parts.add(minuteFormat(minutes));
    if (seconds > 0) parts.add(secondFormat(seconds));
  } else {
    parts.add(secondFormat(seconds));
  }

  return parts.join(' ');
}

/// Localized status text for a call item, derived from [status], [isFromMe],
/// and optional [durationMs].
///
/// When [status] is [CallStatus.ended] and [durationMs] is null (no peer
/// joined), the call's start time is shown as "12:04 PM" with locale-aware
/// AM/PM formatting. Falls back to current time if null.
///
/// For a group call (non-null [participation]), the group label rules apply
/// while the call is ongoing or has ended with peers; a group call the local
/// party never joined falls through to the same "Missed" text as a 1:1 call.
///
/// See the display table in `docs/call-chat-item.md` for the full mapping.
String resolveCallChatItemStatusText({
  required CallStatus status,
  required bool isFromMe,
  required int? durationMs,
  required DateTime? callStartedAt,
  required AppLocalizations l10n,
  CallMediaType? mediaType,
  CallParticipation? participation,
}) {
  if (participation != null) {
    final groupText = _resolveGroupCallStatusText(
      status: status,
      mediaType: mediaType,
      participation: participation,
      l10n: l10n,
    );
    if (groupText != null) return groupText;
  }
  switch (status) {
    case CallStatus.calling:
      return isFromMe ? l10n.callChatItemCalling : l10n.callChatItemRinging;
    case CallStatus.ringing:
      return l10n.callChatItemRinging;
    case CallStatus.inProgress:
      return l10n.callChatItemTapToReturn;
    case CallStatus.ended:
      if (durationMs != null && durationMs > 0) {
        return formatCallDuration(
          Duration(milliseconds: durationMs),
          hourFormat: l10n.callDurationHourFormat,
          minuteFormat: l10n.callDurationMinuteFormat,
          secondFormat: l10n.callDurationSecondFormat,
        );
      }
      final dt = callStartedAt ?? clock.now();
      return DateFormat('h:mm a').format(dt.toLocal());
    case CallStatus.missed:
    case CallStatus.declined:
      return isFromMe ? l10n.callChatItemNotAnswered : l10n.callChatItemMissed;
  }
}

/// Group-specific status text, or null when the group call should fall back to
/// the shared 1:1 wording (e.g. a group call the local party never joined).
String? _resolveGroupCallStatusText({
  required CallStatus status,
  required CallMediaType? mediaType,
  required CallParticipation participation,
  required AppLocalizations l10n,
}) {
  switch (status) {
    case CallStatus.calling:
    case CallStatus.ringing:
      return null;
    case CallStatus.inProgress:
      final count = participation.participantCount;
      return mediaType == CallMediaType.audio
          ? l10n.callChatItemGroupOngoingAudio(count)
          : l10n.callChatItemGroupOngoingVideo(count);
    case CallStatus.ended:
      if (!participation.selfLeftBeforeEnd) return null;
      return l10n.callChatItemYouLeft;
    case CallStatus.missed:
    case CallStatus.declined:
      return null;
  }
}

// =========================================================================
// Colors
// =========================================================================

/// Resolved colors for a call chat item.
/// Produced by [resolveCallChatItemColors].
class CallChatItemColors {
  const CallChatItemColors({
    required this.background,
    required this.iconContainer,
    required this.icon,
    required this.content,
  });

  final Color background;
  final Color iconContainer;
  final Color icon;
  final Color content;
}

/// Maps [status] and [isFromMe] to the concrete colors used by the card.
CallChatItemColors resolveCallChatItemColors({
  required CallStatus status,
  required bool isFromMe,
  required Color chatItemColor,
  required ColorScheme colorScheme,
  required AppCustomColors customColors,
}) {
  final background = isFromMe
      ? customColors.callChatItemFromMeBackground
      : customColors.callChatItemBackground;

  switch (status) {
    case CallStatus.calling:
    case CallStatus.ringing:
      if (!isFromMe) {
        return CallChatItemColors(
          background: background,
          iconContainer: colorScheme.surface,
          icon: customColors.callChatItemPendingContent,
          content: customColors.callChatItemPendingContent,
        );
      }
      return CallChatItemColors(
        background: background,
        iconContainer: customColors.callChatItemPendingIconContainer,
        icon: customColors.callChatItemPendingContent,
        content: customColors.callChatItemPendingContent,
      );
    case CallStatus.missed:
    case CallStatus.declined:
      return CallChatItemColors(
        background: background,
        iconContainer: colorScheme.error.withAlpha(50),
        icon: colorScheme.error,
        content: colorScheme.onSurfaceVariant,
      );
    case CallStatus.inProgress:
    case CallStatus.ended:
      return CallChatItemColors(
        background: background,
        iconContainer: isFromMe
            ? chatItemColor.withAlpha(50)
            : colorScheme.surface,
        icon: isFromMe ? chatItemColor : colorScheme.onSurface,
        content: colorScheme.onSurface,
      );
  }
}
