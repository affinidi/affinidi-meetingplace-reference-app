import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' show CallStatus;

import '../../../../../l10n/app_localizations.dart';
import '../../../../../presentation/themes/app_custom_colors.dart';

// =========================================================================
// Policy — what the SDK persists when a call ends
// =========================================================================

/// How a call ended, from the wire's perspective.
///
/// Used by [resolveEndStatus] to compute the [CallStatus] to persist on the
/// call chat item. This is an app-side concept; it is not part of the SDK.
enum CallEndOutcome {
  /// The call ended normally after both parties were connected.
  hungUp,

  /// The call ended without being answered — either the receiver timed out
  /// or explicitly declined.
  declined,
}

/// Returns the [CallStatus] to persist on the call chat item when a call ends.
///
/// [isFromMe] is the `isFromMe` flag of the call chat item owned by this
/// device. Caller items are `isFromMe=true`;
/// receiver items are `isFromMe=false`.
///
/// This is the single authority for the "who sees what end state" rule:
///   - Caller (`isFromMe=true`) + [CallEndOutcome.declined]
///     → [CallStatus.declined] ("Not answered")
///   - Caller (`isFromMe=true`) + [CallEndOutcome.hungUp]
///     → [CallStatus.ended]
///   - Receiver (`isFromMe=false`) + any unanswered outcome
///     → [CallStatus.missed] ("Missed")
///   - Receiver (`isFromMe=false`) + [CallEndOutcome.hungUp]
///     → [CallStatus.ended]
CallStatus resolveEndStatus({
  required CallEndOutcome outcome,
  required bool isFromMe,
}) => switch ((isFromMe, outcome)) {
  (true, CallEndOutcome.declined) => CallStatus.declined,
  (true, CallEndOutcome.hungUp) => CallStatus.ended,
  (false, CallEndOutcome.declined) => CallStatus.missed,
  (false, CallEndOutcome.hungUp) => CallStatus.ended,
};

// =========================================================================
// Render predicates — driven by (status, isFromMe)
// =========================================================================

/// Whether the item shows a missed-call (error) visual treatment.
///
/// True for any unanswered ending: `missed` (receiver) or `declined` (caller).
bool isMissedCallDisplay(CallStatus status) =>
    status == CallStatus.missed || status == CallStatus.declined;

/// Whether tapping the item opens or returns to the call screen.
///
/// Tappable while an incoming call is pending (receiver's view of `calling`)
/// or while a call is in progress.
bool isCallChatItemTappable({
  required CallStatus status,
  required bool isFromMe,
}) =>
    (status == CallStatus.calling && !isFromMe) ||
    status == CallStatus.inProgress;

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
/// See the display table in `docs/call-chat-item.md` for the full mapping.
String resolveCallChatItemStatusText({
  required CallStatus status,
  required bool isFromMe,
  required int? durationMs,
  required DateTime? callStartedAt,
  required AppLocalizations l10n,
}) {
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
