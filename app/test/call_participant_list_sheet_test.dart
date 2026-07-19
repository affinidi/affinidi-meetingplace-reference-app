import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/participants/call_participant.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/participants/call_participant_list_sheet.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.dark,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

const _kAlice = CallParticipant(
  id: 'alice',
  firstName: 'Alice',
  connection: CallParticipantConnection.connected,
);

const _kBob = CallParticipant(
  id: 'bob',
  firstName: 'Bob',
  connection: CallParticipantConnection.notConnected,
);

const _kCarol = CallParticipant(
  id: 'carol',
  firstName: 'Carol',
  connection: CallParticipantConnection.notConnected,
  ringState: CallRingState.ringing,
);

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/participant_sheet_test.log'),
    );
  });

  // ---------------------------------------------------------------------------
  // 1. Renders title with connected count and both section labels
  // ---------------------------------------------------------------------------
  testWidgets('renders title and both section labels', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CallParticipantListSheet(
          participants: const [_kAlice, _kBob],
          onCall: (_) {},
          onRingingTap: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('1 connected'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Not connected'), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // 2. Connected participant has no bell and no triple-dot
  // ---------------------------------------------------------------------------
  testWidgets('connected participant shows name, no bell, no triple-dot', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CallParticipantListSheet(
          participants: const [_kAlice],
          onCall: (_) {},
          onRingingTap: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsNothing);
    expect(find.byIcon(Icons.more_horiz), findsNothing);
  });

  // ---------------------------------------------------------------------------
  // 3. Not-connected idle participant shows the bell; tapping calls onCall
  // ---------------------------------------------------------------------------
  testWidgets('idle not-connected shows bell; tapping calls onCall', (
    tester,
  ) async {
    String? calledId;

    await tester.pumpWidget(
      _wrap(
        CallParticipantListSheet(
          participants: const [_kBob],
          onCall: (id) => calledId = id,
          onRingingTap: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz), findsNothing);

    await tester.tap(find.byIcon(Icons.notifications));
    expect(calledId, 'bob');
  });

  // ---------------------------------------------------------------------------
  // 4. Not-connected ringing: triple-dot; tapping calls onRingingTap
  // ---------------------------------------------------------------------------
  testWidgets(
    'ringing not-connected shows triple-dot; tapping calls onRingingTap',
    (tester) async {
      String? ringingId;

      await tester.pumpWidget(
        _wrap(
          CallParticipantListSheet(
            participants: const [_kCarol],
            onCall: (_) {},
            onRingingTap: (id) => ringingId = id,
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsNothing);

      await tester.tap(find.byIcon(Icons.more_horiz));
      expect(ringingId, 'carol');
    },
  );

  // ---------------------------------------------------------------------------
  // 5. Section transition: move participant from notConnected → connected
  // ---------------------------------------------------------------------------
  testWidgets(
    'moving participant to connected increments count and removes bell',
    (tester) async {
      var participants = const <CallParticipant>[_kBob];

      await tester.pumpWidget(
        _wrap(
          StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                CallParticipantListSheet(
                  participants: participants,
                  onCall: (_) {},
                  onRingingTap: (_) {},
                ),
                ElevatedButton(
                  onPressed: () => setState(() {
                    participants = [
                      _kBob.copyWith(
                        connection: CallParticipantConnection.connected,
                      ),
                    ];
                  }),
                  child: const Text('Move'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      // Initial: 0 connected, bell visible
      expect(find.text('0 connected'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);

      await tester.tap(find.text('Move'));
      await tester.pump();

      // After: 1 connected, no bell
      expect(find.text('1 connected'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsNothing);
    },
  );

  // ---------------------------------------------------------------------------
  // 6. Timeout: timedOut participant shows bell (not triple-dot)
  // ---------------------------------------------------------------------------
  testWidgets('timedOut participant shows bell like idle', (tester) async {
    const timedOut = CallParticipant(
      id: 'dave',
      firstName: 'Dave',
      connection: CallParticipantConnection.notConnected,
      ringState: CallRingState.timedOut,
    );

    await tester.pumpWidget(
      _wrap(
        CallParticipantListSheet(
          participants: const [timedOut],
          onCall: (_) {},
          onRingingTap: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz), findsNothing);
  });
}
