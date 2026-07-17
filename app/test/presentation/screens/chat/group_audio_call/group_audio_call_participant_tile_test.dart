import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mpx_flutter_reference_app/presentation/screens/chat/group_audio_call/group_audio_call_participant_tile.dart';

void main() {
  group('GroupAudioCallParticipantTile', () {
    testWidgets('renders display name when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupAudioCallParticipantTile(
              displayName: 'John Doe',
              isMuted: false,
              isSelf: false,
              size: 100,
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays mic_off icon when muted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupAudioCallParticipantTile(
              displayName: 'Alice',
              isMuted: true,
              isSelf: false,
              size: 100,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_off), findsOneWidget);
    });

    testWidgets('does not show mic_off icon when not muted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupAudioCallParticipantTile(
              displayName: 'Bob',
              isMuted: false,
              isSelf: false,
              size: 100,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_off), findsNothing);
    });

    testWidgets('shows self indicator when isSelf is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupAudioCallParticipantTile(
              displayName: 'Me',
              isMuted: false,
              isSelf: true,
              size: 100,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('renders with custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GroupAudioCallParticipantTile(
              displayName: 'Charlie',
              isMuted: false,
              isSelf: false,
              size: 200,
            ),
          ),
        ),
      );

      // Should render without error
      expect(find.byType(GroupAudioCallParticipantTile), findsOneWidget);
    });
  });
}
