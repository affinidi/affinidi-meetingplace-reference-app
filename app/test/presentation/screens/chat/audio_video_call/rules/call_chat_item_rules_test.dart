import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/call_chat_item_rules.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_custom_colors.dart';

import '../../../../../mocks/fake_app_custom_colors.dart';
import '../../../../../mocks/fake_app_localizations.dart';

void main() {
  group('resolveEndStatus', () {
    group('caller (isFromMe=true)', () {
      test('returns declined for an unanswered outcome', () {
        expect(
          resolveEndStatus(outcome: CallOutcome.declined, isFromMe: true),
          CallStatus.declined,
        );
      });

      test('returns ended for ended outcome', () {
        expect(
          resolveEndStatus(outcome: CallOutcome.ended, isFromMe: true),
          CallStatus.ended,
        );
      });

      test('returns missed (not declined) for a timed-out outcome', () {
        expect(
          resolveEndStatus(outcome: CallOutcome.timedOut, isFromMe: true),
          CallStatus.missed,
        );
      });

      test('returns missed (not declined) for a cancelled outcome', () {
        expect(
          resolveEndStatus(outcome: CallOutcome.cancelled, isFromMe: true),
          CallStatus.missed,
        );
      });
    });

    group('receiver (isFromMe=false)', () {
      test('returns missed for an unanswered outcome', () {
        expect(
          resolveEndStatus(outcome: CallOutcome.declined, isFromMe: false),
          CallStatus.missed,
        );
      });

      test('returns ended for ended outcome', () {
        expect(
          resolveEndStatus(outcome: CallOutcome.ended, isFromMe: false),
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

    test('returns false for calling and ringing statuses', () {
      expect(
        isCallChatItemTappable(status: CallStatus.calling, isFromMe: false),
        isFalse,
      );
      expect(
        isCallChatItemTappable(status: CallStatus.calling, isFromMe: true),
        isFalse,
      );
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

  group('isCallChatItemRecallable', () {
    test('returns true for ended, missed, and declined statuses', () {
      expect(isCallChatItemRecallable(CallStatus.ended), isTrue);
      expect(isCallChatItemRecallable(CallStatus.missed), isTrue);
      expect(isCallChatItemRecallable(CallStatus.declined), isTrue);
    });

    test('returns false for inProgress status', () {
      expect(isCallChatItemRecallable(CallStatus.inProgress), isFalse);
    });

    test('returns false for calling and ringing statuses', () {
      expect(isCallChatItemRecallable(CallStatus.calling), isFalse);
      expect(isCallChatItemRecallable(CallStatus.ringing), isFalse);
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

    test('returns declined for declined from me', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.declined,
          isFromMe: true,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
        ),
        l10n.callChatItemDeclined,
      );
    });

    test('returns declined for declined from other', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.declined,
          isFromMe: false,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
        ),
        l10n.callChatItemDeclined,
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

  group('resolveCallChatItemStatusText group calls', () {
    late AppLocalizations l10n;

    setUp(() {
      l10n = FakeAppLocalizations();
    });

    CallParticipation participation({
      int count = 2,
      bool didSelfJoin = true,
      bool selfLeftBeforeEnd = false,
    }) => CallParticipation(
      participantCount: count,
      didSelfJoin: didSelfJoin,
      selfLeftBeforeEnd: selfLeftBeforeEnd,
    );

    test('returns ongoing video text while in progress for video call', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.inProgress,
          isFromMe: true,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
          mediaType: CallMediaType.video,
          participation: participation(count: 3),
        ),
        l10n.callChatItemGroupOngoingVideo(3),
      );
    });

    test('returns ongoing audio text while in progress for audio call', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.inProgress,
          isFromMe: true,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
          mediaType: CallMediaType.audio,
          participation: participation(count: 2),
        ),
        l10n.callChatItemGroupOngoingAudio(2),
      );
    });

    test('group audio ringing falls back to shared ringing text', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.ringing,
          isFromMe: true,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
          mediaType: CallMediaType.audio,
          participation: participation(count: 2),
        ),
        l10n.callChatItemRinging,
      );
    });

    test('group video ringing falls back to shared ringing text', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.ringing,
          isFromMe: true,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
          mediaType: CallMediaType.video,
          participation: participation(count: 2),
        ),
        l10n.callChatItemRinging,
      );
    });

    test('ended group call where self was last to leave shows duration', () {
      final sharedEndedText = resolveCallChatItemStatusText(
        status: CallStatus.ended,
        isFromMe: true,
        durationMs: 120000,
        callStartedAt: null,
        l10n: l10n,
      );

      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.ended,
          isFromMe: true,
          durationMs: 120000,
          callStartedAt: null,
          l10n: l10n,
          mediaType: CallMediaType.video,
          participation: participation(count: 4, selfLeftBeforeEnd: false),
        ),
        sharedEndedText,
      );
    });

    test('returns you-left label when self left before end', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.ended,
          isFromMe: true,
          durationMs: 120000,
          callStartedAt: null,
          l10n: l10n,
          mediaType: CallMediaType.video,
          participation: participation(count: 2, selfLeftBeforeEnd: true),
        ),
        l10n.callChatItemYouLeft,
      );
    });

    test('ended group call with no peers falls back to duration text', () {
      final sharedEndedText = resolveCallChatItemStatusText(
        status: CallStatus.ended,
        isFromMe: true,
        durationMs: 120000,
        callStartedAt: null,
        l10n: l10n,
      );

      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.ended,
          isFromMe: true,
          durationMs: 120000,
          callStartedAt: null,
          l10n: l10n,
          mediaType: CallMediaType.video,
          participation: participation(count: 0, selfLeftBeforeEnd: false),
        ),
        sharedEndedText,
      );
    });

    test('a never-joined group call falls back to 1:1 missed text', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.missed,
          isFromMe: false,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
          mediaType: CallMediaType.video,
          participation: participation(count: 2, didSelfJoin: false),
        ),
        l10n.callChatItemMissed,
      );
    });

    test('a never-answered group call falls back to 1:1 not answered text', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.missed,
          isFromMe: true,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
          mediaType: CallMediaType.video,
          participation: participation(count: 2, didSelfJoin: false),
        ),
        l10n.callChatItemNotAnswered,
      );
    });

    test('a never-answered group call the caller declined falls back to 1:1 '
        'declined text', () {
      expect(
        resolveCallChatItemStatusText(
          status: CallStatus.declined,
          isFromMe: true,
          durationMs: null,
          callStartedAt: null,
          l10n: l10n,
          mediaType: CallMediaType.video,
          participation: participation(count: 2, didSelfJoin: false),
        ),
        l10n.callChatItemDeclined,
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

  group('group participation rules', () {
    AudioVideoCallParticipant participant(
      String id, {
      String? did,
      bool isSelf = false,
    }) =>
        AudioVideoCallParticipant(participantId: id, did: did, isSelf: isSelf);

    group('accumulateSeenPeerIds', () {
      test('adds non-self participant ids to the running set', () {
        final result = accumulateSeenPeerIds(
          previous: const {},
          participants: [
            participant('self', isSelf: true),
            participant('p1'),
            participant('p2'),
          ],
        );

        expect(result, {'p1', 'p2'});
      });

      test('merges with the previous set and de-duplicates', () {
        final result = accumulateSeenPeerIds(
          previous: const {'p1'},
          participants: [participant('p1'), participant('p3')],
        );

        expect(result, {'p1', 'p3'});
      });
    });

    group('computeDidSelfJoin', () {
      test('latches true once a connected status is seen', () {
        expect(
          computeDidSelfJoin(
            previous: false,
            status: AudioVideoCallStatus.connected,
          ),
          isTrue,
        );
      });

      test('stays true after connecting even if status regresses', () {
        expect(
          computeDidSelfJoin(
            previous: true,
            status: AudioVideoCallStatus.outgoingRinging,
          ),
          isTrue,
        );
      });

      test('stays false while never connected', () {
        expect(
          computeDidSelfJoin(
            previous: false,
            status: AudioVideoCallStatus.outgoingRinging,
          ),
          isFalse,
        );
      });
    });

    group('resolveSelfDid', () {
      test('returns the self participant did', () {
        final did = resolveSelfDid([
          participant('p1', did: 'did:p1'),
          participant('self', did: 'did:me', isSelf: true),
        ]);

        expect(did, 'did:me');
      });

      test('returns null when no self participant is present', () {
        expect(resolveSelfDid([participant('p1', did: 'did:p1')]), isNull);
      });
    });

    group('buildCallParticipation', () {
      test('maps peer count and flags onto the model', () {
        final participation = buildCallParticipation(
          seenPeerIds: const {'p1', 'p2'},
          didSelfJoin: true,
          selfLeftBeforeEnd: true,
          initiatorDid: 'did:caller',
        );

        expect(participation.participantCount, 2);
        expect(participation.didSelfJoin, isTrue);
        expect(participation.selfLeftBeforeEnd, isTrue);
        expect(participation.initiatorDid, 'did:caller');
      });
    });
  });
}
