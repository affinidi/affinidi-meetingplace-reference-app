import '../../l10n/app_localizations.dart';

/// Helpers to produce human-friendly "time ago" strings localized via l10n.
extension DateTimeExtension on DateTime {
  /// Produce a localized "time ago" string for this DateTime.
  ///
  /// [l10n] - localization instance used to format the output.
  /// [numericDates] - when true use numeric phrasing (e.g., "1 day ago")
  String timeAgo(AppLocalizations l10n, {bool numericDates = true}) {
    final now = DateTime.now();
    final diff = now.difference(this);

    if ((diff.inDays / 7).floor() >= 1) {
      return numericDates
          ? l10n.timeAgoWeek((diff.inDays / 7).floor())
          : l10n.timeAgoLastWeek;
    }
    if (diff.inDays >= 2) {
      return l10n.timeAgoDay(diff.inDays);
    }
    if (diff.inDays >= 1) {
      return numericDates ? l10n.timeAgoDay(1) : l10n.timeAgoYesterday;
    }
    if (diff.inHours >= 2) {
      return l10n.timeAgoHourNumeric(diff.inHours);
    }
    if (diff.inHours >= 1) {
      return numericDates ? l10n.timeAgoHourNumeric(1) : l10n.timeAgoHourWorded;
    }
    if (diff.inMinutes >= 2) {
      return l10n.timeAgoMinute(diff.inMinutes);
    }
    if (diff.inMinutes >= 1) {
      return numericDates ? l10n.timeAgoMinute(1) : l10n.timeAgoMinuteWorded;
    }
    if (diff.inSeconds >= 3) {
      return l10n.timeAgoSecond(diff.inSeconds);
    }

    return l10n.timeAgoJustNow;
  }
}
