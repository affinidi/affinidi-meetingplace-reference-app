import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/group_audio_call/group_audio_call_participant_tile.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_custom_colors.dart';

Future<void> _pumpTile(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        extensions: const <ThemeExtension<dynamic>>[AppCustomColors()],
      ),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('GroupAudioCallParticipantTile', () {
    testWidgets('renders display name when provided', (
      WidgetTester tester,
    ) async {
      await _pumpTile(
        tester,
        const Scaffold(
          body: GroupAudioCallParticipantTile(
            displayName: 'John Doe',
            isMuted: false,
            isSelf: false,
            size: 100,
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays mic_off icon when muted', (
      WidgetTester tester,
    ) async {
      await _pumpTile(
        tester,
        const Scaffold(
          body: GroupAudioCallParticipantTile(
            displayName: 'Alice',
            isMuted: true,
            isSelf: false,
            size: 100,
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_off), findsOneWidget);
    });

    testWidgets('does not show mic_off icon when not muted', (
      WidgetTester tester,
    ) async {
      await _pumpTile(
        tester,
        const Scaffold(
          body: GroupAudioCallParticipantTile(
            displayName: 'Bob',
            isMuted: false,
            isSelf: false,
            size: 100,
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_off), findsNothing);
    });

    testWidgets('shows self indicator when isSelf is true', (
      WidgetTester tester,
    ) async {
      await _pumpTile(
        tester,
        const Scaffold(
          body: GroupAudioCallParticipantTile(
            displayName: 'Me',
            isMuted: false,
            isSelf: true,
            size: 100,
          ),
        ),
      );

      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('renders with custom size', (WidgetTester tester) async {
      await _pumpTile(
        tester,
        const Scaffold(
          body: GroupAudioCallParticipantTile(
            displayName: 'Charlie',
            isMuted: false,
            isSelf: false,
            size: 200,
          ),
        ),
      );

      // Should render without error
      expect(find.byType(GroupAudioCallParticipantTile), findsOneWidget);
    });
  });
}
