import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';

/// Fake [AppLocalizations] for testing.
class FakeAppLocalizations implements AppLocalizations {
  @override
  String get localeName => 'en';

  @override
  String get callChatItemCalling => 'Calling...';

  @override
  String get callChatItemRinging => 'Ringing...';

  @override
  String get callChatItemTapToReturn => 'Tap to return';

  @override
  String get callChatItemNotAnswered => 'Not answered';

  @override
  String get callChatItemMissed => 'Missed';

  @override
  String callDurationHourFormat(int h) => '${h}h';

  @override
  String callDurationMinuteFormat(int m) => '${m}m';

  @override
  String callDurationSecondFormat(int s) => '${s}s';

  // Stub all other required methods
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
