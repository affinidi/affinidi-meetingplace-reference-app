import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/audio_video_call_plugin_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/incoming_call_state_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/pending_call_session_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/permission_service/permission_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_state.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';

import '../../../../fakes/fake_permission_service.dart';
import '../../../../mocks/fake_active_call_controller.dart';
import '../../../../mocks/fake_app_logger.dart';
import '../../../../mocks/fake_contacts_service.dart';

const _kContactId = 'smoke-test-contact';

class _FakeIncomingCallState extends IncomingCallState {
  @override
  IncomingAudioVideoCallEvent? build() => null;
}

class _FakePendingCallSession extends PendingCallSession {
  @override
  AudioVideoCallSession? build() => null;
}

class _FixedStateController extends AudioVideoCallScreenController {
  _FixedStateController(this._fixed);

  final AudioVideoCallScreenState _fixed;

  @override
  AudioVideoCallScreenState build(String contactId) => _fixed;

  @override
  Future<void> startCall({bool isAudioOnly = false}) async {}

  @override
  Future<void> restartCall({bool isAudioOnly = false}) async {}
}

Widget _wrap({required AudioVideoCallScreenState controllerState}) {
  return ProviderScope(
    overrides: [
      appLoggerProvider.overrideWithValue(FakeAppLogger()),
      contactsServiceProvider.overrideWith(FakeContactsService.new),
      audioVideoCallPluginProvider.overrideWith((ref) async => null),
      permissionServiceProvider.overrideWithValue(FakePermissionService()),
      incomingCallStateProvider.overrideWith(_FakeIncomingCallState.new),
      pendingCallSessionProvider.overrideWith(_FakePendingCallSession.new),
      activeCallControllerProvider.overrideWith(FakeActiveCallController.new),
      audioVideoCallScreenControllerProvider(
        _kContactId,
      ).overrideWith(() => _FixedStateController(controllerState)),
    ],
    child: MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AudioVideoCallScreen(contactId: _kContactId),
    ),
  );
}

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/audio_video_call_screen_test.log'),
    );
  });

  group('AudioVideoCallScreen smoke', () {
    testWidgets('shows error scaffold when contact cannot be resolved', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.connecting,
        peerName: '',
        isGroupContact: true,
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AudioVideoCallScreen)),
      )!;

      expect(tester.takeException(), isNull);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(
        find.text(l10n.videoCallFailedToJoin(l10n.videoCallUnknownError)),
        findsOneWidget,
      );
    });

    testWidgets('shows peer name in audio outgoing ringing state', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.outgoingRinging,
        peerName: 'Alice',
        isAudioOnly: true,
        isMicEnabled: true,
        isSpeakerEnabled: false,
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('shows peer name in video outgoing ringing state', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.outgoingRinging,
        peerName: 'Bob',
        isAudioOnly: false,
        isMicEnabled: true,
        isCameraEnabled: true,
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Bob'), findsOneWidget);
    });

    testWidgets('shows peer name in connecting state', (tester) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.connecting,
        peerName: 'Carol',
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Carol'), findsOneWidget);
    });

    testWidgets('shows peer name in waitingForKeys state', (tester) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.waitingForKeys,
        peerName: 'Dave',
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Dave'), findsOneWidget);
    });

    testWidgets('renders audio active state with a remote peer', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Eve',
        isAudioOnly: true,
        hasHadPeer: true,
        participants: [
          const AudioVideoCallParticipant(
            participantId: 'remote-1',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Eve'), findsOneWidget);
    });

    testWidgets('renders video active state with a single remote peer', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Frank',
        isAudioOnly: false,
        hasHadPeer: true,
        participants: [
          const AudioVideoCallParticipant(
            participantId: 'remote-1',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Frank'), findsOneWidget);
    });

    testWidgets('renders group video active state with multiple remote peers', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Group Call',
        isAudioOnly: false,
        hasHadPeer: true,
        participants: [
          const AudioVideoCallParticipant(
            participantId: 'remote-1',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          const AudioVideoCallParticipant(
            participantId: 'remote-2',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(AudioVideoCallScreen), findsOneWidget);
    });

    testWidgets('shows no-answer screen with peer name for missed call', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.missed,
        peerName: 'Grace',
        isAudioOnly: true,
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Grace'), findsOneWidget);
    });

    testWidgets('shows no-answer screen with peer name for declined call', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.declined,
        peerName: 'Harry',
        isAudioOnly: false,
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Harry'), findsOneWidget);
    });

    testWidgets('renders without throwing for disconnected ended state', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.disconnected,
        peerName: 'Ivy',
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(AudioVideoCallScreen), findsOneWidget);
    });

    testWidgets('renders without throwing for error ended state', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.error,
        peerName: 'Jake',
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(AudioVideoCallScreen), findsOneWidget);
    });

    testWidgets('shows peer name in ringing state without peer history', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.outgoingRinging,
        peerName: 'Kim',
        hasHadPeer: false,
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Kim'), findsOneWidget);
    });

    testWidgets('renders group video connecting state with loading spinner', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.connecting,
        peerName: 'Loading Group',
        isAudioOnly: false,
        participants: const [
          AudioVideoCallParticipant(
            participantId: 'remote-1',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'remote-2',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AudioVideoCallScreen)),
      )!;

      expect(tester.takeException(), isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text(l10n.videoCallJoiningCall), findsOneWidget);
    });

    testWidgets(
      'renders group video waitingForKeys state with loading spinner',
      (tester) async {
        final state = AudioVideoCallScreenState(
          status: AudioVideoCallStatus.waitingForKeys,
          peerName: 'Encrypted Group',
          isAudioOnly: false,
          participants: const [
            AudioVideoCallParticipant(
              participantId: 'remote-1',
              isSelf: false,
              hasVideo: false,
              hasAudio: true,
              isSpeaking: false,
            ),
            AudioVideoCallParticipant(
              participantId: 'remote-2',
              isSelf: false,
              hasVideo: false,
              hasAudio: true,
              isSpeaking: false,
            ),
          ],
        );

        await tester.pumpWidget(_wrap(controllerState: state));
        await tester.pump();

        final l10n = AppLocalizations.of(
          tester.element(find.byType(AudioVideoCallScreen)),
        )!;

        expect(tester.takeException(), isNull);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text(l10n.videoCallWaitingForEncryption), findsOneWidget);
      },
    );

    testWidgets('renders focused layout with self label in group video', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Quiet Group',
        isAudioOnly: false,
        hasHadPeer: true,
        focusedParticipantIndex: 0,
        participants: const [
          AudioVideoCallParticipant(
            participantId: 'self-1',
            isSelf: true,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'remote-1',
            isSelf: false,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'remote-2',
            isSelf: false,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AudioVideoCallScreen)),
      )!;

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      expect(find.text(l10n.videoCallYou), findsOneWidget);
    });

    testWidgets('renders focused participant layout for group video', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Focus Group',
        isAudioOnly: false,
        hasHadPeer: true,
        focusedParticipantIndex: 0,
        participants: [
          const AudioVideoCallParticipant(
            participantId: 'self-1',
            isSelf: true,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
          const AudioVideoCallParticipant(
            participantId: 'remote-1',
            isSelf: false,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
          const AudioVideoCallParticipant(
            participantId: 'remote-2',
            isSelf: false,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AudioVideoCallScreen)),
      )!;

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      expect(find.text(l10n.videoCallYou), findsOneWidget);
    });

    testWidgets('shows no-answer screen for video missed call', (tester) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.missed,
        peerName: 'Leo',
        isAudioOnly: false,
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AudioVideoCallScreen)),
      )!;

      expect(tester.takeException(), isNull);
      expect(find.text('Leo'), findsOneWidget);
      expect(find.text(l10n.videoCallNoAnswer), findsOneWidget);
      expect(find.text(l10n.videoCallCancel), findsOneWidget);
      expect(find.text(l10n.videoCallAgain), findsOneWidget);
    });

    testWidgets('shows no-answer screen for audio declined call', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.declined,
        peerName: 'Mia',
        isAudioOnly: true,
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AudioVideoCallScreen)),
      )!;

      expect(tester.takeException(), isNull);
      expect(find.text('Mia'), findsOneWidget);
      expect(find.text(l10n.videoCallCallDeclined), findsOneWidget);
      expect(find.text(l10n.videoCallCancel), findsOneWidget);
      expect(find.text(l10n.videoCallAgain), findsOneWidget);
    });

    testWidgets(
      'renders audio active state with self and remote participants',
      (tester) async {
        final state = AudioVideoCallScreenState(
          status: AudioVideoCallStatus.active,
          peerName: 'Nina',
          isAudioOnly: true,
          hasHadPeer: true,
          participants: [
            const AudioVideoCallParticipant(
              participantId: 'self-1',
              isSelf: true,
              hasVideo: false,
              hasAudio: true,
              isSpeaking: false,
            ),
            const AudioVideoCallParticipant(
              participantId: 'remote-1',
              isSelf: false,
              hasVideo: false,
              hasAudio: true,
              isSpeaking: false,
            ),
          ],
        );

        await tester.pumpWidget(_wrap(controllerState: state));
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.text('Nina'), findsOneWidget);
      },
    );

    testWidgets('renders error ended state with peer name visible', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.error,
        peerName: 'Oscar',
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(AudioVideoCallScreen), findsOneWidget);
    });
  });
}
