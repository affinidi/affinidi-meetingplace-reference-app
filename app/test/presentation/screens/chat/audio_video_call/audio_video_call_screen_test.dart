import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_livekit_flutter/meeting_place_livekit_flutter.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_notifier.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_state.dart';
import 'package:mpx_flutter_reference_app/domain/models/contacts/contact.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/permission_service/permission_service.dart';
import 'package:mpx_flutter_reference_app/l10n/app_localizations.dart';
import 'package:mpx_flutter_reference_app/presentation/painting/cached_base64_image.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_state.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/chat_screen_state.dart';
import 'package:mpx_flutter_reference_app/presentation/themes/app_theme.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/call/video_call_peer_placeholder.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/call/video_call_pip_window.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/call_ended/call_ended_overlay.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/profile_circle_avatar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../fakes/fake_contacts.dart';
import '../../../../fakes/fake_contacts_service.dart';
import '../../../../fakes/fake_permission_service.dart';
import '../../../../mocks/fake_active_call_controller.dart';
import '../../../../mocks/fake_app_logger.dart';
import '../../../../mocks/fake_meeting_place_matrix_sdk.dart';

const _kContactId = 'smoke-test-contact';

class _FakeIncomingCallState extends IncomingCallNotifier {
  @override
  IncomingCallState build() => const IncomingCallState.idle();
}

class _FixedStateController extends AudioVideoCallScreenController {
  _FixedStateController(this._fixed);

  final AudioVideoCallScreenState _fixed;
  int toggleCameraCalls = 0;
  int switchCameraCalls = 0;
  int restartCallCalls = 0;
  int minimizeCalls = 0;

  @override
  AudioVideoCallScreenState build(String contactId) => _fixed;

  @override
  Future<void> startCall({bool isAudioOnly = false}) async {}

  @override
  Future<void> restartCall({bool isAudioOnly = false}) async =>
      restartCallCalls++;

  @override
  Future<void> toggleCamera() async => toggleCameraCalls++;

  @override
  Future<void> switchCamera() async => switchCameraCalls++;

  @override
  void minimize() => minimizeCalls++;
}

class _CoveredChatController extends ChatScreenController {
  int pauseCalls = 0;
  int restoreCalls = 0;

  @override
  ChatScreenState build(String contactId) => ChatScreenState();

  @override
  bool pauseReadStateForCoveringCall() {
    pauseCalls++;
    return true;
  }

  @override
  void restoreReadStateAfterCoveringCall() => restoreCalls++;
}

Widget _wrap({
  required AudioVideoCallScreenState controllerState,
  _FixedStateController? controller,
  FakeContactsService? contactsService,
}) {
  final fixedController = controller ?? _FixedStateController(controllerState);
  final fakeContactsService =
      contactsService ??
      FakeContactsService(contacts: [FakeContacts.groupContact]);

  return ProviderScope(
    overrides: [
      appLoggerProvider.overrideWithValue(FakeAppLogger()),
      contactsServiceProvider.overrideWith(() => fakeContactsService),
      meetingPlaceSdkProvider.overrideWith(
        (ref) async => FakeMeetingPlaceMatrixSDK(),
      ),
      permissionServiceProvider.overrideWithValue(FakePermissionService()),
      incomingCallProvider.overrideWith(_FakeIncomingCallState.new),
      activeCallControllerProvider.overrideWith(FakeActiveCallController.new),
      audioVideoCallScreenControllerProvider(
        _kContactId,
      ).overrideWith(() => fixedController),
    ],
    child: MaterialApp(
      theme: AppTheme.dark.copyWith(splashFactory: NoSplash.splashFactory),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const MediaQuery(
        data: MediaQueryData(size: Size(430, 932)),
        child: Stack(
          children: [
            AudioVideoCallScreen(contactId: _kContactId),
            CallEndedOverlay(),
          ],
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/audio_video_call_screen_test.log'),
    );
  });

  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.single.physicalSize = const Size(
      1290,
      2796,
    );
    binding.platformDispatcher.views.single.devicePixelRatio = 3.0;
  });

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.single.resetPhysicalSize();
    binding.platformDispatcher.views.single.resetDevicePixelRatio();
  });

  group('AudioVideoCallScreen smoke', () {
    testWidgets(
      'delegates covered chat read-state handoff to chat controller',
      (tester) async {
        final state = AudioVideoCallScreenState(
          status: AudioVideoCallStatus.connecting,
          peerName: 'Alice',
        );
        final contact = FakeContacts.newIndividualContact(
          id: _kContactId,
          channelDid: 'did:key:call-channel',
        );
        final contactsService = FakeContactsService(contacts: [contact]);
        final controller = _FixedStateController(state);
        final chatController = _CoveredChatController();
        final container = ProviderContainer(
          overrides: [
            appLoggerProvider.overrideWithValue(FakeAppLogger()),
            contactsServiceProvider.overrideWith(() => contactsService),
            meetingPlaceSdkProvider.overrideWith(
              (ref) async => FakeMeetingPlaceMatrixSDK(),
            ),
            permissionServiceProvider.overrideWithValue(
              FakePermissionService(),
            ),
            incomingCallProvider.overrideWith(_FakeIncomingCallState.new),
            activeCallControllerProvider.overrideWith(
              FakeActiveCallController.new,
            ),
            audioVideoCallScreenControllerProvider(
              _kContactId,
            ).overrideWith(() => controller),
            chatScreenControllerProvider(
              _kContactId,
            ).overrideWith(() => chatController),
          ],
        );
        addTearDown(container.dispose);
        container.listen(chatScreenControllerProvider(_kContactId), (_, _) {});

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: AppTheme.dark.copyWith(
                splashFactory: NoSplash.splashFactory,
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const AudioVideoCallScreen(contactId: _kContactId),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        await tester.pump();
        expect(chatController.pauseCalls, 1);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const SizedBox.shrink(),
          ),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(chatController.restoreCalls, 1);
        expect(contactsService.resetBadgeCalledWith, isNull);
      },
    );

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
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AudioVideoCallScreen)),
      )!;
      final errorMessage = l10n.videoCallError('channelNotFound');

      expect(tester.takeException(), isNull);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
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
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows group icon in audio outgoing ringing state', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.outgoingRinging,
        peerName: 'Study Group',
        isGroupContact: true,
        isAudioOnly: true,
        isMicEnabled: true,
        isSpeakerEnabled: false,
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.group), findsOneWidget);
      expect(find.text('Study Group'), findsOneWidget);
      expect(find.text('Waiting for others...'), findsNothing);
    });

    testWidgets('shows initial group state when only self has joined', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Study Group',
        isGroupContact: true,
        isAudioOnly: true,
        participants: const [
          AudioVideoCallParticipant(
            participantId: 'self-1',
            isSelf: true,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.group), findsOneWidget);
      expect(find.text('You'), findsNothing);
    });

    testWidgets('shows single peer tile when one other member has joined', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Study Group',
        isGroupContact: true,
        isAudioOnly: true,
        participants: const [
          AudioVideoCallParticipant(
            participantId: 'self-1',
            isSelf: true,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-1',
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
      expect(find.byType(GridView), findsNothing);
      expect(find.text('Study Group'), findsNWidgets(2));
      expect(find.text('You'), findsNothing);
    });

    testWidgets('shows grid for two other joined group members', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Study Group',
        isGroupContact: true,
        isAudioOnly: true,
        participants: const [
          AudioVideoCallParticipant(
            participantId: 'self-1',
            isSelf: true,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-1',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-2',
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
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
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
      expect(find.byType(VideoCallPiPWindow), findsNothing);
      expect(find.byType(VideoCallPeerPlaceholder), findsOneWidget);
    });

    testWidgets('shows audio-like group video scaffold with self full stage', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Study Group',
        isGroupContact: true,
        isAudioOnly: false,
        isCameraEnabled: true,
        participants: const [
          AudioVideoCallParticipant(
            participantId: 'self-1',
            did: 'did:key:group-channel',
            isSelf: true,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-1',
            did: 'did:key:peer-1',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: true,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-2',
            did: 'did:key:peer-2',
            isSelf: false,
            hasVideo: false,
            hasAudio: false,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrap(
          controllerState: state,
          contactsService: FakeContactsService(
            contacts: [FakeContacts.groupContact],
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(VideoCallPiPWindow), findsNothing);
      expect(find.byType(AudioVideoCallView), findsOneWidget);
      expect(find.byType(AudioVideoCallScreen), findsOneWidget);
    });

    testWidgets('shows audio-like group video scaffold for overflow groups', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Study Group',
        isGroupContact: true,
        isAudioOnly: false,
        isCameraEnabled: true,
        participants: const [
          AudioVideoCallParticipant(
            participantId: 'self-1',
            did: 'did:key:group-channel',
            isSelf: true,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-1',
            did: 'did:key:peer-1',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: true,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-2',
            did: 'did:key:peer-2',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-3',
            did: 'did:key:peer-3',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-4',
            did: 'did:key:peer-4',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-5',
            did: 'did:key:peer-5',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-6',
            did: 'did:key:peer-6',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-7',
            did: 'did:key:peer-7',
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
      expect(find.byType(SmoothPageIndicator), findsOneWidget);
      expect(find.byIcon(Icons.close_fullscreen), findsOneWidget);
      expect(find.byType(AudioVideoCallScreen), findsOneWidget);
    });

    testWidgets('shows self video full screen while ringing '
        'when camera preview is available', (tester) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.outgoingRinging,
        peerName: 'Bob',
        isAudioOnly: false,
        isCameraEnabled: true,
        participants: const [
          AudioVideoCallParticipant(
            participantId: 'self-1',
            isSelf: true,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(AudioVideoCallScreen), findsOneWidget);
      expect(find.byType(VideoCallPiPWindow), findsNothing);
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

    testWidgets('renders audio active state with a peer participant', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Eve',
        isAudioOnly: true,
        hasHadPeer: true,
        participants: [
          const AudioVideoCallParticipant(
            participantId: 'peer-1',
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

    testWidgets('renders video active state with a single peer participant', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Frank',
        isAudioOnly: false,
        hasHadPeer: true,
        participants: [
          const AudioVideoCallParticipant(
            participantId: 'self-1',
            isSelf: true,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
          const AudioVideoCallParticipant(
            participantId: 'peer-1',
            isSelf: false,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
        ],
      );

      final controller = _FixedStateController(state);

      await tester.pumpWidget(
        _wrap(controllerState: state, controller: controller),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Frank'), findsOneWidget);
      expect(find.byType(VideoCallPiPWindow), findsOneWidget);
      expect(find.byType(VideoCallPeerPlaceholder), findsOneWidget);
      expect(find.byIcon(Icons.people_alt_outlined), findsNothing);
      expect(find.byIcon(Icons.flip_camera_ios), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.flip_camera_ios).first);
      await tester.pump();

      expect(controller.switchCameraCalls, 1);
    });

    testWidgets('renders self video full screen before the peer answers', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Solo',
        isAudioOnly: false,
        hasHadPeer: false,
        isCameraEnabled: true,
        participants: const [
          AudioVideoCallParticipant(
            participantId: 'self-1',
            isSelf: true,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(VideoCallPiPWindow), findsNothing);
      expect(find.byType(AudioVideoCallScreen), findsOneWidget);
    });

    testWidgets(
      'renders group video active state with multiple peer participants',
      (tester) async {
        final state = AudioVideoCallScreenState(
          status: AudioVideoCallStatus.active,
          peerName: 'Group Call',
          isGroupContact: true,
          isAudioOnly: false,
          hasHadPeer: true,
          participants: [
            const AudioVideoCallParticipant(
              participantId: 'peer-1',
              isSelf: false,
              hasVideo: false,
              hasAudio: true,
              isSpeaking: false,
            ),
            const AudioVideoCallParticipant(
              participantId: 'peer-2',
              isSelf: false,
              hasVideo: false,
              hasAudio: true,
              isSpeaking: false,
            ),
          ],
        );
        final controller = _FixedStateController(state);

        await tester.pumpWidget(
          _wrap(controllerState: state, controller: controller),
        );
        await tester.pump();

        expect(tester.takeException(), isNull);
        expect(find.byType(AudioVideoCallScreen), findsOneWidget);
        expect(find.byType(VideoCallPiPWindow), findsNothing);
        expect(find.byIcon(Icons.close_fullscreen), findsOneWidget);
        expect(find.byType(ProfileCircleAvatar), findsAtLeastNWidgets(1));
      },
    );

    testWidgets('renders group video scaffold before other members answer', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Group Call',
        isGroupContact: true,
        isAudioOnly: false,
        participants: const [
          AudioVideoCallParticipant(
            participantId: 'self-1',
            isSelf: true,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byIcon(Icons.close_fullscreen), findsOneWidget);
      expect(find.byIcon(Icons.flip_camera_ios), findsOneWidget);
    });

    testWidgets('truncates long peer names and keeps muted pill in '
        'the header', (tester) async {
      const longPeerName =
          'This is a very long peer name that should be ellipsized in the '
          'header';
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: longPeerName,
        isGroupContact: false,
        isAudioOnly: true,
        participants: const [
          AudioVideoCallParticipant(
            participantId: 'self-1',
            isSelf: true,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-1',
            isSelf: false,
            hasVideo: false,
            hasAudio: false,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('This is a very long peer name'), findsNothing);
      expect(find.textContaining('is muted'), findsOneWidget);

      final peerNameText = tester.widget<Text>(find.text(longPeerName));
      expect(peerNameText.maxLines, 1);
      expect(peerNameText.overflow, TextOverflow.ellipsis);
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

    testWidgets('shows network error message in error ended state', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.error,
        peerName: 'Nora',
        errorCode: AudioVideoCallErrorCode.networkError,
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AudioVideoCallScreen)),
      )!;
      final errorMessage = l10n.videoCallError(
        AudioVideoCallErrorCode.networkError.name,
      );

      expect(tester.takeException(), isNull);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text(l10n.videoCallCallEnded), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('dismisses ended overlay when closing error banner screen', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.error,
        peerName: 'Nora',
        errorCode: AudioVideoCallErrorCode.networkError,
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
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

    testWidgets(
      'renders group video connecting state without loading spinner',
      (tester) async {
        final state = AudioVideoCallScreenState(
          status: AudioVideoCallStatus.connecting,
          peerName: 'Loading Group',
          isGroupContact: true,
          isAudioOnly: false,
          participants: const [
            AudioVideoCallParticipant(
              participantId: 'peer-1',
              isSelf: false,
              hasVideo: false,
              hasAudio: true,
              isSpeaking: false,
            ),
            AudioVideoCallParticipant(
              participantId: 'peer-2',
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
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(AudioVideoCallScreen), findsOneWidget);
        expect(find.byType(ProfileCircleAvatar), findsAtLeastNWidgets(1));
      },
    );

    testWidgets(
      'renders group video waitingForKeys state without loading spinner',
      (tester) async {
        final state = AudioVideoCallScreenState(
          status: AudioVideoCallStatus.waitingForKeys,
          peerName: 'Encrypted Group',
          isGroupContact: true,
          isAudioOnly: false,
          participants: const [
            AudioVideoCallParticipant(
              participantId: 'peer-1',
              isSelf: false,
              hasVideo: false,
              hasAudio: true,
              isSpeaking: false,
            ),
            AudioVideoCallParticipant(
              participantId: 'peer-2',
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
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(AudioVideoCallScreen), findsOneWidget);
        expect(find.byType(ProfileCircleAvatar), findsAtLeastNWidgets(1));
      },
    );

    testWidgets('renders focused layout with self label in group video', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Quiet Group',
        isGroupContact: true,
        isAudioOnly: false,
        hasHadPeer: true,
        participants: const [
          AudioVideoCallParticipant(
            participantId: 'self-1',
            isSelf: true,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-1',
            isSelf: false,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
          AudioVideoCallParticipant(
            participantId: 'peer-2',
            isSelf: false,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(VideoCallPiPWindow), findsNothing);
      expect(find.byType(AudioVideoCallView), findsAtLeastNWidgets(1));
    });

    testWidgets('renders focused participant layout for group video', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Focus Group',
        isGroupContact: true,
        isAudioOnly: false,
        hasHadPeer: true,
        participants: [
          const AudioVideoCallParticipant(
            participantId: 'self-1',
            isSelf: true,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
          const AudioVideoCallParticipant(
            participantId: 'peer-1',
            isSelf: false,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
          const AudioVideoCallParticipant(
            participantId: 'peer-2',
            isSelf: false,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
        ],
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(VideoCallPiPWindow), findsNothing);
      expect(find.byType(AudioVideoCallView), findsAtLeastNWidgets(1));
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
      expect(find.text(l10n.videoCallNoAnswer), findsOneWidget);
      expect(find.text(l10n.videoCallCancel), findsOneWidget);
      expect(find.text(l10n.videoCallAgain), findsOneWidget);
    });

    testWidgets('renders audio active state with self and peer participants', (
      tester,
    ) async {
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
            participantId: 'peer-1',
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
    });

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

  group('audio call screen — camera button', () {
    testWidgets('tapping camera icon shows switch-to-video dialog', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Alice',
        isAudioOnly: true,
        hasHadPeer: true,
        showControlsBar: true,
      );

      await tester.pumpWidget(_wrap(controllerState: state));
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AudioVideoCallScreen)),
      )!;

      await tester.tap(find.byIcon(Icons.videocam_off));
      await tester.pumpAndSettle();

      expect(find.text(l10n.videoCallSwitchToVideoTitle), findsOneWidget);
    });

    testWidgets('camera button calls toggleCamera, not restartCall', (
      tester,
    ) async {
      final state = AudioVideoCallScreenState(
        status: AudioVideoCallStatus.active,
        peerName: 'Alice',
        isAudioOnly: true,
        hasHadPeer: true,
        showControlsBar: true,
      );

      late _FixedStateController controller;
      final container = ProviderContainer(
        overrides: [
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
          contactsServiceProvider.overrideWith(FakeContactsService.new),
          meetingPlaceSdkProvider.overrideWith(
            (ref) async => FakeMeetingPlaceMatrixSDK(),
          ),
          permissionServiceProvider.overrideWithValue(FakePermissionService()),
          incomingCallProvider.overrideWith(_FakeIncomingCallState.new),
          activeCallControllerProvider.overrideWith(
            FakeActiveCallController.new,
          ),
          audioVideoCallScreenControllerProvider(_kContactId).overrideWith(() {
            controller = _FixedStateController(state);
            return controller;
          }),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.dark.copyWith(
              splashFactory: NoSplash.splashFactory,
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AudioVideoCallScreen(contactId: _kContactId),
          ),
        ),
      );
      await tester.pump();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(AudioVideoCallScreen)),
      )!;

      await tester.tap(find.byIcon(Icons.videocam_off));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.videoCallSwitch));
      await tester.pumpAndSettle();

      expect(controller.toggleCameraCalls, 1);
      expect(controller.restartCallCalls, 0);
    });
  });

  group('audio call screen — peer avatar refresh', () {
    testWidgets(
      'rebuilds peer avatar when contact card profile picture changes',
      (tester) async {
        final baseContact = FakeContacts.newIndividualContact(
          id: _kContactId,
          channelDid: FakeContacts.individualContact.channelDid!,
        );
        final contactWithInitialAvatar = Contact(
          id: baseContact.id,
          channelDid: baseContact.channelDid,
          channelDidSha256: baseContact.channelDidSha256,
          offerLink: baseContact.offerLink,
          card: FakeContacts.individualContact.card.copyWith(
            profilePic: 'initial-base64-avatar',
          ),
          dateAdded: baseContact.dateAdded,
          type: baseContact.type,
          status: baseContact.status,
          mediatorDid: baseContact.mediatorDid,
          origin: baseContact.origin,
          category: baseContact.category,
          otherPartyCard: baseContact.otherPartyCard,
          displayName: baseContact.displayName,
          badgeUpdateInProgress: baseContact.badgeUpdateInProgress,
          badgeCount: baseContact.badgeCount,
          currentMessageSeqNo: baseContact.currentMessageSeqNo,
          missedCallCount: baseContact.missedCallCount,
          pendingMissedCallAt: baseContact.pendingMissedCallAt,
          pendingMissedCallId: baseContact.pendingMissedCallId,
          activeIncomingCallId: baseContact.activeIncomingCallId,
          hasBeenOpened: baseContact.hasBeenOpened,
          lastKeepAliveMessage: baseContact.lastKeepAliveMessage,
          notificationBannerDismissed: baseContact.notificationBannerDismissed,
        );
        final contactsService = FakeContactsService(
          contacts: [contactWithInitialAvatar],
        );

        final state = AudioVideoCallScreenState(
          status: AudioVideoCallStatus.active,
          peerName: 'Alice',
          isAudioOnly: true,
          hasHadPeer: true,
          showControlsBar: true,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appLoggerProvider.overrideWithValue(FakeAppLogger()),
              contactsServiceProvider.overrideWith(() => contactsService),
              meetingPlaceSdkProvider.overrideWith(
                (ref) async => FakeMeetingPlaceMatrixSDK(),
              ),
              permissionServiceProvider.overrideWithValue(
                FakePermissionService(),
              ),
              incomingCallProvider.overrideWith(_FakeIncomingCallState.new),
              activeCallControllerProvider.overrideWith(
                FakeActiveCallController.new,
              ),
              audioVideoCallScreenControllerProvider(
                _kContactId,
              ).overrideWith(() => _FixedStateController(state)),
            ],
            child: MaterialApp(
              theme: AppTheme.dark,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const AudioVideoCallScreen(contactId: _kContactId),
            ),
          ),
        );
        await tester.pump();

        var avatar = tester.widget<ProfileCircleAvatar>(
          find.byType(ProfileCircleAvatar),
        );
        expect(avatar.image, isNotNull);
        expect(avatar.image, isA<CachedBase64Image>());
        expect(
          (avatar.image! as CachedBase64Image).base64String,
          'initial-base64-avatar',
        );

        contactsService.setContacts([
          Contact(
            id: baseContact.id,
            channelDid: baseContact.channelDid,
            channelDidSha256: baseContact.channelDidSha256,
            offerLink: baseContact.offerLink,
            card: FakeContacts.individualContact.card.copyWith(
              profilePic: 'updated-base64-avatar',
            ),
            dateAdded: baseContact.dateAdded,
            type: baseContact.type,
            status: baseContact.status,
            mediatorDid: baseContact.mediatorDid,
            origin: baseContact.origin,
            category: baseContact.category,
            otherPartyCard: baseContact.otherPartyCard,
            displayName: baseContact.displayName,
            badgeUpdateInProgress: baseContact.badgeUpdateInProgress,
            badgeCount: baseContact.badgeCount,
            currentMessageSeqNo: baseContact.currentMessageSeqNo,
            missedCallCount: baseContact.missedCallCount,
            pendingMissedCallAt: baseContact.pendingMissedCallAt,
            pendingMissedCallId: baseContact.pendingMissedCallId,
            activeIncomingCallId: baseContact.activeIncomingCallId,
            hasBeenOpened: baseContact.hasBeenOpened,
            lastKeepAliveMessage: baseContact.lastKeepAliveMessage,
            notificationBannerDismissed:
                baseContact.notificationBannerDismissed,
          ),
        ]);
        await tester.pump();

        avatar = tester.widget<ProfileCircleAvatar>(
          find.byType(ProfileCircleAvatar),
        );
        expect(avatar.image, isNotNull);
        expect(avatar.image, isA<CachedBase64Image>());
        expect(
          (avatar.image! as CachedBase64Image).base64String,
          'updated-base64-avatar',
        );
      },
    );
  });
}
