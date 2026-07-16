import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_state.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_state.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/video_call_pip_overlay.dart';

import 'fakes/fake_active_call_controller.dart';

class _FakeScreenController extends AudioVideoCallScreenController {
  @override
  AudioVideoCallScreenState build(String contactId) =>
      AudioVideoCallScreenState(
        isCameraEnabled: true,
        isMicEnabled: true,
        participants: const [
          AudioVideoCallParticipant(participantId: 'local', isSelf: true),
        ],
      );
}

const _kContactId = 'contact-1';

const _kMinimizedVideoState = ActiveCallState(
  contactId: _kContactId,
  peerName: 'Alice',
  status: AudioVideoCallStatus.active,
  callDurationSeconds: 5,
  isMicEnabled: true,
  isAudioOnly: false,
  isMinimized: true,
  isCameraEnabled: true,
  selfParticipant: AudioVideoCallParticipant(
    participantId: 'local',
    isSelf: true,
  ),
);

Widget _wrap(ActiveCallState? callState) => ProviderScope(
  overrides: [
    activeCallControllerProvider.overrideWith(
      () => FakeActiveCallController(callState),
    ),
    audioVideoCallScreenControllerProvider.overrideWith(
      _FakeScreenController.new,
    ),
  ],
  child: MaterialApp(
    theme: AppTheme.dark,
    home: const Scaffold(body: Stack(children: [VideoCallPiPOverlay()])),
  ),
);

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/pip_overlay_test.log'),
    );
  });

  group('VideoCallPiPOverlay visibility', () {
    testWidgets('renders nothing when there is no active call', (tester) async {
      await tester.pumpWidget(_wrap(null));
      await tester.pump();

      expect(find.byType(VideoCallPiPOverlay), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byIcon(Icons.flip_camera_ios), findsNothing);
      expect(find.byIcon(Icons.mic), findsNothing);
    });

    testWidgets('renders nothing when call is not minimized', (tester) async {
      await tester.pumpWidget(
        _wrap(_kMinimizedVideoState.copyWith(isMinimized: false)),
      );
      await tester.pump();

      expect(find.byIcon(Icons.flip_camera_ios), findsNothing);
    });

    testWidgets('renders nothing when call is audio-only', (tester) async {
      await tester.pumpWidget(
        _wrap(_kMinimizedVideoState.copyWith(isAudioOnly: true)),
      );
      await tester.pump();

      expect(find.byIcon(Icons.flip_camera_ios), findsNothing);
    });

    testWidgets('renders the PiP with self avatar when camera is disabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_kMinimizedVideoState.copyWith(isCameraEnabled: false)),
      );
      await tester.pump();

      // The window renders (camera-off shows the self avatar). Tapping reveals
      // the control bar.
      await tester.tap(find.byType(VideoCallPiPOverlay));
      await tester.pump();

      expect(find.byIcon(Icons.mic), findsOneWidget);
    });
  });

  group('VideoCallPiPOverlay controls overlay', () {
    testWidgets('controls are hidden before first tap', (tester) async {
      await tester.pumpWidget(_wrap(_kMinimizedVideoState));
      await tester.pump();

      expect(find.byIcon(Icons.flip_camera_ios), findsNothing);
      expect(find.byIcon(Icons.open_in_full), findsNothing);
    });

    testWidgets('controls appear after tapping the PiP window', (tester) async {
      await tester.pumpWidget(_wrap(_kMinimizedVideoState));
      await tester.pump();

      await tester.tap(find.byType(VideoCallPiPOverlay));
      await tester.pump();

      expect(find.byIcon(Icons.flip_camera_ios), findsOneWidget);
      expect(find.byIcon(Icons.open_in_full), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('controls auto-collapse after 2 seconds', (tester) async {
      await tester.pumpWidget(_wrap(_kMinimizedVideoState));
      await tester.pump();

      await tester.tap(find.byType(VideoCallPiPOverlay));
      await tester.pump();

      expect(find.byIcon(Icons.flip_camera_ios), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));

      expect(find.byIcon(Icons.flip_camera_ios), findsNothing);
    });

    testWidgets('second tap collapses controls immediately', (tester) async {
      await tester.pumpWidget(_wrap(_kMinimizedVideoState));
      await tester.pump();

      await tester.tap(find.byType(VideoCallPiPOverlay));
      await tester.pump();

      expect(find.byIcon(Icons.flip_camera_ios), findsOneWidget);

      await tester.tap(find.byType(VideoCallPiPOverlay));
      await tester.pump();

      expect(find.byIcon(Icons.flip_camera_ios), findsNothing);
    });
  });
}
