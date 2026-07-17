import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service.dart';
import 'package:mpx_flutter_reference_app/application/services/identities_service/identities_service_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_state.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_state.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/profile_circle_avatar.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/video_call_peer_placeholder.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/video_call_pip_overlay.dart';

import 'fakes/fake_active_call_controller.dart';
import 'fakes/fake_audio_video_call_screen_controller.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_contacts_service.dart';
import 'fakes/fake_identities.dart';
import 'fakes/fake_identities_service.dart';

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
    contactsServiceProvider.overrideWith(
      () => FakeContactsService(contacts: [FakeContacts.individualContact]),
    ),
    identitiesServiceProvider.overrideWith(
      () => FakeIdentitiesService(
        IdentitiesServiceState(currentIdentity: FakeIdentities.primaryIdentity),
      ),
    ),
    audioVideoCallScreenControllerProvider.overrideWith(
      FakeAudioVideoCallScreenController.new,
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

    testWidgets('shows remote primary placeholder with local inset', (
      tester,
    ) async {
      final screenState = AudioVideoCallScreenState(
        isCameraEnabled: false,
        isMicEnabled: true,
        participants: const [
          AudioVideoCallParticipant(participantId: 'local', isSelf: true),
          AudioVideoCallParticipant(participantId: 'remote'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeCallControllerProvider.overrideWith(
              () => FakeActiveCallController(_kMinimizedVideoState),
            ),
            contactsServiceProvider.overrideWith(
              () => FakeContactsService(
                contacts: [FakeContacts.individualContact],
              ),
            ),
            identitiesServiceProvider.overrideWith(
              () => FakeIdentitiesService(
                IdentitiesServiceState(
                  currentIdentity: FakeIdentities.primaryIdentity,
                ),
              ),
            ),
            audioVideoCallScreenControllerProvider.overrideWith(
              () => FakeAudioVideoCallScreenController(screenState),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const Scaffold(
              body: Stack(children: [VideoCallPiPOverlay()]),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(VideoCallPeerPlaceholder), findsOneWidget);
      expect(find.byType(ProfileCircleAvatar), findsNWidgets(2));
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
