import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart' show CallStatus;
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/call_chat_item_rules.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_custom_colors.dart';

import '../../../../../mocks/fake_app_custom_colors.dart';
import '../../../../../mocks/fake_app_localizations.dart';

void main() {
  group('resolveEndStatus', () {
    group('caller (isFromMe=true)', () {
      test('returns declined for declined outcome', () {
        expect(
          resolveEndStatus(outcome: CallEndOutcome.declined, isFromMe: true),
          CallStatus.declined,
        );
      });

      test('returns ended for hungUp outcome', () {
        expect(
          resolveEndStatus(outcome: CallEndOutcome.hungUp, isFromMe: true),
          CallStatus.ended,
        );
      });
    });

    group('receiver (isFromMe=false)', () {
      test('returns missed for declined outcome', () {
        expect(
          resolveEndStatus(outcome: CallEndOutcome.declined, isFromMe: false),
          CallStatus.missed,
        );
      });

      test('returns ended for hungUp outcome', () {
        expect(
          resolveEndStatus(outcome: CallEndOutcome.hungUp, isFromMe: false),
          CallStatus.ended,
        );
      });
    });
  });

  group('isMissedCallDisplay', () {
    test('returns true for missed status', () {
      expect(isMissedCallDisplay(CallStatus.missed), isTrue);
    });

    test('returns true for declined status', () {
      expect(isMissedCallDisplay(CallStatus.declined), isTrue);
    });

    test('returns false for calling status', () {
      expect(isMissedCallDisplay(CallStatus.calling), isFalse);
    });

    test('returns false for ringing status', () {
      expect(isMissedCallDisplay(CallStatus.ringing), isFalse);
    });

    test('returns false for inProgress status', () {
      expect(isMissedCallDisplay(CallStatus.inProgress), isFalse);
    });

    test('returns false for ended status', () {
      expect(isMissedCallDisplay(CallStatus.ended), isFalse);
    });
  });

  group('isCallChatItemTappable', () {
    test('returns true for calling status when isFromMe=false (receiver)', () {
      expect(
        isCallChatItemTappable(status: CallStatus.calling, isFromMe: false),
        isTrue,
      );
    });

    test('returns false for calling status when isFromMe=true (caller)', () {
      expect(
        isCallChatItemTappable(status: CallStatus.calling, isFromMe: true),
        isFalse,
      );
    });

    test('returns true for inProgress status regardless of isFromMe', () {
      expect(
        isCallChatItemTappable(status: CallStatus.inProgress, isFromMe: true),
        isTrue,
      );
      expect(
        isCallChatItemTappable(status: CallStatus.inProgress, isFromMe: false),
        isTrue,
      );
    });

    test('returns false for ringing status', () {
      expect(
        isCallChatItemTappable(status: CallStatus.ringing, isFromMe: false),
        isFalse,
      );
    });

    test('returns false for ended statuses', () {
      expect(
        isCallChatItemTappable(status: CallStatus.ended, isFromMe: true),
        isFalse,
      );
      expect(
        isCallChatItemTappable(status: CallStatus.missed, isFromMe: false),
        isFalse,
      );
    });
  });

  group('formatCallDuration', () {
    test('formats seconds only', () {
      expect(
        formatCallDuration(
          const Duration(seconds: 14),
          hourFormat: (h) => '${h}h',
          minuteFormat: (m) => '${m}m',
          secondFormat: (s) => '${s}s',
        ),
        '14s',
      );
    });

    test('formats minutes and seconds', () {
      expect(
        formatCallDuration(
          const Duration(minutes: 2, seconds: 14),
          hourFormat: (h) => '${h}h',
          minuteFormat: (m) => '${m}m',
          secondFormat: (s) => '${s}s',
        ),
        '2m 14s',
      );
    });

    test('formats hours and minutes (skips 0 seconds)', () {
      expect(
        formatCallDuration(
          const Duration(hours: 1, minutes: 30),
          hourFormat: (h) => '${h}h',
          minuteFormat: (m) => '${m}m',
          secondFormat: (s) => '${s}s',
        ),
        '1h 30m',
      );
    });

    test('formats hours only (0 minutes and seconds)', () {
      expect(
        formatCallDuration(
          const Duration(hours: 2),
          hourFormat: (h) => '${h}h',
          minuteFormat: (m) => '${m}m',
          secondFormat: (s) => '${s}s',
        ),
        '2h',
      );
    });

    test('formats with custom locale formatters', () {
      expect(
        formatCallDuration(
          const Duration(minutes: 2, seconds: 14),
          hourFormat: (h) => 'h$h',
          minuteFormat: (m) => 'm$m',
          secondFormat: (s) => 's$s',
        ),
        'm2 s14',
      );
    });

    test('handles zero duration', () {
      expect(
        formatCallDuration(
          Duration.zero,
          hourFormat: (h) => '${h}h',
          minuteFormat: (m) => '${m}m',
          secondFormat: (s) => '${s}s',
        ),
        '0s',
      );
    });
  });

  group('resolveCallChatItemStatusText', () {
    late AppLocalizations l10n;

    setUp(() {
      l10n = FakeAppLocalizations();
    });

    test('returns calling text for calling status from me', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.calling,
          isFromMe: true,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
        ),
        l10n.callChatItemCalling,
      );
    });

    test('returns ringing text for calling status from other', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.calling,
          isFromMe: false,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
        ),
        l10n.callChatItemRinging,
      );
    });

    test('returns ringing text for ringing status', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.ringing,
          isFromMe: true,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
        ),
        l10n.callChatItemRinging,
      );
    });

    test('returns tap to return for inProgress', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.inProgress,
          isFromMe: true,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
        ),
        l10n.callChatItemTapToReturn,
      );
    });

    test('returns formatted duration when ended with duration', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.ended,
          isFromMe: true,
          durationMs: 134000, // 2m 14s
          callStartedAt: null,
          l10n: l10n,
        ),
        '2m 14s',
      );
    });

    test('returns time string when ended without duration', () {
      final testTime = DateTime(2026, 6, 22, 12, 4, 0);
      final result = resolveCallChatItemStatusText(
        status: CallStatus.ended,
        isFromMe: true,
        durationMs: null,
        callStartedAt: testTime,
        l10n: l10n,
      );
      // Should be formatted time, not null
      expect(result, isNotEmpty);
      expect(result, contains(':'));
    });

    test('returns not answered for declined from me', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.declined,
          isFromMe: true,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
        ),
        l10n.callChatItemNotAnswered,
      );
    });

    test('returns missed for missed from other', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.missed,
          isFromMe: false,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
        ),
        l10n.callChatItemMissed,
      );
    });
  });

  group('resolveCallChatItemColors', () {
    late AppCustomColors customColors;
    late ColorScheme colorScheme;

    setUp(() {
      customColors = FakeAppCustomColors();
      colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
    });

    test('returns correct colors for calling from me', () {
      final colors = resolveCallChatItemColors(
        status: CallStatus.calling,
        isFromMe: true,
        chatItemColor: Colors.blue,
        colorScheme: colorScheme,
        customColors: customColors,
      );

      expect(colors.background, customColors.callChatItemFromMeBackground);
      expect(colors.icon, customColors.callChatItemPendingContent);
      expect(colors.content, customColors.callChatItemPendingContent);
    });

    test('returns correct colors for ringing from other', () {
      final colors = resolveCallChatItemColors(
        status: CallStatus.ringing,
        isFromMe: false,
        chatItemColor: Colors.blue,
        colorScheme: colorScheme,
        customColors: customColors,
      );

      expect(colors.background, customColors.callChatItemBackground);
      expect(colors.iconContainer, colorScheme.surface);
      expect(colors.icon, customColors.callChatItemPendingContent);
      expect(colors.content, customColors.callChatItemPendingContent);
    });

    test('returns error colors for missed', () {
      final colors = resolveCallChatItemColors(
        status: CallStatus.missed,
        isFromMe: false,
        chatItemColor: Colors.blue,
        colorScheme: colorScheme,
        customColors: customColors,
      );

      expect(colors.iconContainer, colorScheme.error.withAlpha(50));
      expect(colors.icon, colorScheme.error);
      expect(colors.content, colorScheme.onSurfaceVariant);
    });

    test('returns error colors for declined', () {
      final colors = resolveCallChatItemColors(
        status: CallStatus.declined,
        isFromMe: true,
        chatItemColor: Colors.blue,
        colorScheme: colorScheme,
        customColors: customColors,
      );

      expect(colors.iconContainer, colorScheme.error.withAlpha(50));
      expect(colors.icon, colorScheme.error);
    });

    test('returns correct colors for ended from me', () {
      final chatColor = Colors.green;
      final colors = resolveCallChatItemColors(
        status: CallStatus.ended,
        isFromMe: true,
        chatItemColor: chatColor,
        colorScheme: colorScheme,
        customColors: customColors,
      );

      expect(colors.iconContainer, chatColor.withAlpha(50));
      expect(colors.icon, chatColor);
      expect(colors.content, colorScheme.onSurface);
    });

    test('returns correct colors for ended from other', () {
      final colors = resolveCallChatItemColors(
        status: CallStatus.ended,
        isFromMe: false,
        chatItemColor: Colors.blue,
        colorScheme: colorScheme,
        customColors: customColors,
      );

      expect(colors.iconContainer, colorScheme.surface);
      expect(colors.icon, colorScheme.onSurface);
    });
  });
}
