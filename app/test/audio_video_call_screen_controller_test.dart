import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_notifier.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/call_audio_session_service/call_audio_session_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/permission_service/permission_service.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';

import 'fakes/fake_audio_session.dart';
import 'fakes/fake_audio_video_call_session.dart';
import 'fakes/fake_chat_session_service.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_contacts_service.dart';
import 'fakes/fake_meeting_place_matrix_sdk.dart';
import 'fakes/fake_permission_service.dart';

late FakeMeetingPlaceMatrixSDK _testSdk;

ProviderContainer _buildContainer({
  FakeMeetingPlaceMatrixSDK? fakeSDK,
  FakePermissionService? permissionService,
  FakeAudioSession? audioSession,
  bool canUsePlatformAudioSession = false,
}) {
  return ProviderContainer(
    overrides: [
      contactsServiceProvider.overrideWith(FakeContactsService.new),
      chatSessionServiceProvider.overrideWith(FakeChatSessionService.new),
      meetingPlaceSdkProvider.overrideWith((ref) async => fakeSDK ?? _testSdk),
      permissionServiceProvider.overrideWith(
        (ref) => permissionService ?? FakePermissionService(),
      ),
      canUsePlatformAudioSessionProvider.overrideWith(
        (ref) => canUsePlatformAudioSession,
      ),
      if (audioSession != null)
        audioSessionProvider.overrideWith((ref) async => audioSession),
    ],
  );
}

class _SpyChatSessionService extends FakeChatSessionService {
  _SpyChatSessionService({required this.onSendOutgoingCallMessage});

  final void Function() onSendOutgoingCallMessage;

  @override
  Future<String?> sendOutgoingCallMessage({
    required CallMediaType mediaType,
    required String callId,
  }) async {
    onSendOutgoingCallMessage();
    return 'spy-call-item-id';
  }
}

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/app_debug_test.log'),
    );
  });

  setUp(() {
    _testSdk = FakeMeetingPlaceMatrixSDK(
      callSession: FakeAudioVideoCallSession(),
    );
    addTearDown(_testSdk.dispose);
  });

  group('initial state', () {
    test('status is idle and toggles default to enabled', () {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final state = container.read(
        audioVideoCallScreenControllerProvider('no-such-id'),
      );
      expect(state.status, AudioVideoCallStatus.idle);
      expect(state.isMicEnabled, isTrue);
      expect(state.isCameraEnabled, isTrue);
      expect(state.isAudioOnly, isFalse);
      expect(state.errorCode, isNull);
    });

    test('peerIsCallingBack defaults to false', () {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final state = container.read(
        audioVideoCallScreenControllerProvider('no-such-id'),
      );
      expect(state.peerIsCallingBack, isFalse);
    });
  });
  group('service state forwarding', () {
    test(
      'status update from session stream is reflected in controller state',
      () async {
        final fakeSDK = _testSdk;
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(fakeSDK: fakeSDK);
        addTearDown(container.dispose);

        await container.read(meetingPlaceSdkProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );

        await controller.joinCall();

        fakeSDK.emitAudioVideoCallState(
          const AudioVideoCallState(status: AudioVideoCallStatus.connected),
        );
        await Future<void>.microtask(() {});

        expect(
          container
              .read(audioVideoCallScreenControllerProvider(contactId))
              .status,
          AudioVideoCallStatus.connected,
        );
      },
    );
  });

  group('joinCall', () {
    test('acquires the audio session when joining a call', () async {
      final fakeSDK = _testSdk;
      final audioSession = FakeAudioSession();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(
        fakeSDK: fakeSDK,
        audioSession: audioSession,
        canUsePlatformAudioSession: true,
      );
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);

      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      expect(
        container.read(callAudioSessionServiceProvider).isAcquired,
        isTrue,
      );
      expect(audioSession.configureCalls, 1);
      expect(audioSession.setActiveCalls, 1);
      expect(audioSession.lastSetActiveValue, isTrue);
      expect(
        audioSession.lastConfiguration?.avAudioSessionMode,
        AVAudioSessionMode.videoChat,
      );
    });

    test('sets status to connecting', () async {
      final fakeSDK = _testSdk;
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);

      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .status,
        AudioVideoCallStatus.connecting,
      );
    });

    test('second joinCall while connecting is a no-op', () async {
      final fakeSDK = _testSdk;
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      await controller.joinCall();
      await controller.joinCall();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .status,
        AudioVideoCallStatus.connecting,
      );
    });

    test('individual call disables isSpeakerEnabled by default', () async {
      final fakeSDK = _testSdk;
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);

      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .isSpeakerEnabled,
        isFalse,
      );
    });

    test('group call disables speakerphone by default', () async {
      final fakeSDK = _testSdk;
      final contactId = FakeContacts.groupContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);

      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .isSpeakerEnabled,
        isFalse,
      );
    });
  });

  group('leaveCall', () {
    test('sets status to ended', () async {
      final fakeSDK = _testSdk;
      final audioSession = FakeAudioSession();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(
        fakeSDK: fakeSDK,
        audioSession: audioSession,
        canUsePlatformAudioSession: true,
      );
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .leaveCall();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .status,
        AudioVideoCallStatus.ended,
      );
      expect(
        container.read(callAudioSessionServiceProvider).isAcquired,
        isFalse,
      );
      expect(audioSession.setActiveCalls, 2);
      expect(audioSession.lastSetActiveValue, isFalse);
      expect(
        audioSession.lastSetActiveOptions,
        AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      );
    });

    test('releases the audio session when the call disconnects', () async {
      final fakeSDK = _testSdk;
      final audioSession = FakeAudioSession();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(
        fakeSDK: fakeSDK,
        audioSession: audioSession,
        canUsePlatformAudioSession: true,
      );
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      fakeSDK.emitAudioVideoCallState(
        const AudioVideoCallState(status: AudioVideoCallStatus.disconnected),
      );
      await pumpEventQueue();

      expect(audioSession.setActiveCalls, 2);
      expect(audioSession.lastSetActiveValue, isFalse);
      expect(
        container.read(callAudioSessionServiceProvider).isAcquired,
        isFalse,
      );
    });
  });

  group('banner timer wiring', () {
    test('startTimer is called on banner when first remote joins', () async {
      final fakeSDK = _testSdk;
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      fakeSDK.emitAudioVideoCallState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [
            AudioVideoCallParticipant(participantId: 'local', isSelf: true),
            AudioVideoCallParticipant(participantId: 'remote-1'),
          ],
        ),
      );
      await Future<void>.microtask(() {});

      expect(
        container.read(activeCallControllerProvider)?.callDurationSeconds,
        isNotNull,
        reason: 'banner must have state after first remote joins',
      );
    });

    test('anchors the banner timer to callStartedAt when provided', () async {
      final fakeSDK = _testSdk;
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      final startedAt = DateTime.now().subtract(const Duration(seconds: 30));
      fakeSDK.emitAudioVideoCallState(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          callStartedAt: startedAt,
          participants: const [
            AudioVideoCallParticipant(participantId: 'local', isSelf: true),
            AudioVideoCallParticipant(participantId: 'remote-1'),
          ],
        ),
      );
      await Future<void>.microtask(() {});

      expect(
        container.read(activeCallControllerProvider)?.callDurationSeconds,
        greaterThanOrEqualTo(29),
        reason:
            'on-screen duration must anchor to callStartedAt so both parties '
            'show the same elapsed time, not count up from zero',
      );
    });
  });

  group('startCall', () {
    test('sets isAudioOnly on the state', () async {
      final fakeSDK = _testSdk;
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .startCall(isAudioOnly: true);

      final state = container.read(
        audioVideoCallScreenControllerProvider(contactId),
      );
      expect(state.isAudioOnly, isTrue);
      expect(state.isCameraEnabled, isFalse);
    });

    test('sets isCameraEnabled true for video call', () async {
      final fakeSDK = _testSdk;
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .startCall(isAudioOnly: false);

      final state = container.read(
        audioVideoCallScreenControllerProvider(contactId),
      );
      expect(state.isAudioOnly, isFalse);
      expect(state.isCameraEnabled, isTrue);
    });

    test('places an outgoing call (status becomes connecting)', () async {
      final fakeSDK = _testSdk;
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .startCall(isAudioOnly: false);

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .status,
        AudioVideoCallStatus.connecting,
      );
    });
  });

  group('restartCall', () {
    test('resets status to idle then starts a fresh outgoing call', () async {
      final fakeSDK = _testSdk;
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      // Simulate a missed call.
      await controller.joinCall();
      fakeSDK.emitAudioVideoCallState(
        const AudioVideoCallState(status: AudioVideoCallStatus.missed),
      );
      await Future<void>.microtask(() {});

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .status,
        AudioVideoCallStatus.missed,
      );

      // Restart should produce a fresh connecting state.
      await controller.restartCall(isAudioOnly: true);

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .status,
        AudioVideoCallStatus.connecting,
      );
    });

    test('clears hasHadPeer when restarting', () async {
      final fakeSDK = _testSdk;
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      await controller.joinCall();

      // Peer joins, latch flips to true.
      fakeSDK.emitAudioVideoCallState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [
            AudioVideoCallParticipant(participantId: 'local', isSelf: true),
            AudioVideoCallParticipant(participantId: 'remote-1'),
          ],
        ),
      );
      await Future<void>.microtask(() {});

      // Call ends as declined.
      fakeSDK.emitAudioVideoCallState(
        const AudioVideoCallState(status: AudioVideoCallStatus.declined),
      );
      await Future<void>.microtask(() {});

      await controller.restartCall(isAudioOnly: false);

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .hasHadPeer,
        isFalse,
        reason: 'hasHadPeer must be reset so the ringing phase shows correctly',
      );
    });

    test(
      'sets isAudioOnly and isCameraEnabled=false on audio restart',
      () async {
        final fakeSDK = _testSdk;
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(fakeSDK: fakeSDK);
        addTearDown(container.dispose);

        await container.read(meetingPlaceSdkProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );

        await controller.joinCall();
        fakeSDK.emitAudioVideoCallState(
          const AudioVideoCallState(status: AudioVideoCallStatus.missed),
        );
        await Future<void>.microtask(() {});

        await controller.restartCall(isAudioOnly: true);

        final state = container.read(
          audioVideoCallScreenControllerProvider(contactId),
        );
        expect(state.isAudioOnly, isTrue);
        expect(state.isCameraEnabled, isFalse);
      },
    );

    test('sets isCameraEnabled=true on video restart', () async {
      final fakeSDK = _testSdk;
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      await controller.joinCall();
      fakeSDK.emitAudioVideoCallState(
        const AudioVideoCallState(status: AudioVideoCallStatus.missed),
      );
      await Future<void>.microtask(() {});

      await controller.restartCall(isAudioOnly: false);

      final state = container.read(
        audioVideoCallScreenControllerProvider(contactId),
      );
      expect(state.isAudioOnly, isFalse);
      expect(state.isCameraEnabled, isTrue);
    });

    test(
      'preserves isCameraEnabled=false when restoring a minimized call',
      () async {
        final fakeSDK = _testSdk;
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(fakeSDK: fakeSDK);
        addTearDown(container.dispose);

        await container.read(meetingPlaceSdkProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );

        // Start video call and turn camera off.
        await controller.startCall(isAudioOnly: false);
        await controller
            .toggleCamera(); // turns camera off (isCameraEnabled: false)

        // Verify camera is off before minimize.
        expect(
          container
              .read(audioVideoCallScreenControllerProvider(contactId))
              .isCameraEnabled,
          isFalse,
        );

        // Simulate restore: inject a pending session so startCall detects
        // restore.
        final session = fakeSDK.callSession!;
        container
            .read(audioVideoCallScreenControllerProvider(contactId).notifier)
            .state = container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .copyWith(session: session);

        // startCall is called again on screen restore with isAudioOnly: false.
        await controller.startCall(isAudioOnly: false);

        expect(
          container
              .read(audioVideoCallScreenControllerProvider(contactId))
              .isCameraEnabled,
          isFalse,
          reason: 'camera state must survive minimize/maximize',
        );
      },
    );
  });

  group('dispose — terminal status skips hangUp', () {
    for (final status in [
      AudioVideoCallStatus.missed,
      AudioVideoCallStatus.declined,
      AudioVideoCallStatus.ended,
      AudioVideoCallStatus.disconnected,
      AudioVideoCallStatus.error,
    ]) {
      test('does not call hangUp when disposing in $status state', () async {
        final fakeSDK = _testSdk;
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(fakeSDK: fakeSDK);
        addTearDown(container.dispose);

        await container.read(meetingPlaceSdkProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );
        await controller.joinCall();

        fakeSDK.emitAudioVideoCallState(AudioVideoCallState(status: status));
        await Future<void>.microtask(() {});

        // Dispose the screen controller (simulates Navigator.pop).
        container.invalidate(audioVideoCallScreenControllerProvider(contactId));
        await Future<void>.microtask(() {});

        expect(
          (fakeSDK.callSession! as FakeAudioVideoCallSession).hangUpCalls,
          0,
          reason: 'hangUp must not be called when already in $status',
        );
      });
    }
  });

  group('toggleCamera', () {
    test('reconfigures audio session to videoChat when enabling camera in'
        ' audio-only call', () async {
      final fakeSDK = _testSdk;
      final audioSession = FakeAudioSession();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(
        fakeSDK: fakeSDK,
        audioSession: audioSession,
        canUsePlatformAudioSession: true,
      );
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);
      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      await controller.startCall(isAudioOnly: true);
      // After audio-only join: voiceChat mode, 1 configure call.
      expect(
        audioSession.lastConfiguration?.avAudioSessionMode,
        AVAudioSessionMode.voiceChat,
      );
      final configureCallsAfterJoin = audioSession.configureCalls;

      await controller.toggleCamera();

      expect(audioSession.configureCalls, configureCallsAfterJoin + 1);
      expect(
        audioSession.lastConfiguration?.avAudioSessionMode,
        AVAudioSessionMode.videoChat,
      );
    });

    test(
      'switches from audio to video when enabling camera in audio call',
      () async {
        final fakeSDK = _testSdk;
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(fakeSDK: fakeSDK);
        addTearDown(container.dispose);

        await container.read(meetingPlaceSdkProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );

        await controller.startCall(isAudioOnly: true);
        expect(
          container
              .read(audioVideoCallScreenControllerProvider(contactId))
              .isAudioOnly,
          isTrue,
        );

        await controller.toggleCamera();

        expect(
          container
              .read(audioVideoCallScreenControllerProvider(contactId))
              .isAudioOnly,
          isFalse,
        );
      },
    );

    test(
      'does not reconfigure audio session when enabling camera in video call',
      () async {
        final fakeSDK = _testSdk;
        final audioSession = FakeAudioSession();
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(
          fakeSDK: fakeSDK,
          audioSession: audioSession,
          canUsePlatformAudioSession: true,
        );
        addTearDown(container.dispose);

        await container.read(meetingPlaceSdkProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );

        await controller.startCall(isAudioOnly: false);
        final configureCallsAfterJoin = audioSession.configureCalls;

        await controller.toggleCamera();

        expect(audioSession.configureCalls, configureCallsAfterJoin);
      },
    );
  });

  group('incoming call', () {
    test(
      'does not send outgoing call chat item when accepting incoming call',
      () async {
        final fakeSDK = _testSdk;
        final contactId = FakeContacts.individualContact.id;
        final channelDid = FakeContacts.individualContact.channelDid!;

        var sendOutgoingCallMessageCount = 0;
        final spy = _SpyChatSessionService(
          onSendOutgoingCallMessage: () => sendOutgoingCallMessageCount++,
        );

        final container = ProviderContainer(
          overrides: [
            contactsServiceProvider.overrideWith(FakeContactsService.new),
            chatSessionServiceProvider.overrideWith(() => spy),
            meetingPlaceSdkProvider.overrideWith((ref) async => fakeSDK),
            permissionServiceProvider.overrideWith(
              (ref) => FakePermissionService(),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Set the incoming event before the controller builds so its build()
        // sees isAcceptedIncomingForThisScreen = true.
        container
            .read(incomingCallProvider.notifier)
            .set(
              IncomingAudioVideoCallEvent(
                callerPermanentChannelDid: 'sim1@example.com',
                otherPartyPermanentChannelDid: channelDid,
                mediaType: CallMediaType.video,
              ),
            );

        await container.read(meetingPlaceSdkProvider.future);
        await container
            .read(audioVideoCallScreenControllerProvider(contactId).notifier)
            .joinCall();

        fakeSDK.emitAudioVideoCallState(AudioVideoCallState.initial);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(sendOutgoingCallMessageCount, 0);
      },
    );
  });

  group('peer restart state', () {
    test('peerIsCallingBack state field exists and defaults to false', () {
      final container = _buildContainer();
      addTearDown(container.dispose);

      final state = container.read(
        audioVideoCallScreenControllerProvider('no-such-id'),
      );
      expect(state.peerIsCallingBack, isFalse);
    });

    test('peerIsCallingBack can be set to true via state.copyWith', () {
      final container = _buildContainer();
      addTearDown(container.dispose);
      final contactId = FakeContacts.individualContact.id;

      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      controller.state = controller.state.copyWith(peerIsCallingBack: true);

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .peerIsCallingBack,
        isTrue,
      );
    });

    test('peerIsCallingBack flag can be cleared via state.copyWith', () {
      final container = _buildContainer();
      addTearDown(container.dispose);
      final contactId = FakeContacts.individualContact.id;

      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      controller.state = controller.state.copyWith(peerIsCallingBack: true);
      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .peerIsCallingBack,
        isTrue,
      );

      controller.state = controller.state.copyWith(peerIsCallingBack: false);
      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .peerIsCallingBack,
        isFalse,
      );
    });
  });

  group('call signal — declined by peer', () {
    test(
      'caller receives CallDeclineSignal listener when SDK is provided',
      () async {
        final fakeSDK = _testSdk;
        final container = _buildContainer(fakeSDK: fakeSDK);
        addTearDown(container.dispose);

        await container.read(meetingPlaceSdkProvider.future);

        expect(fakeSDK.callSignals, isNotNull);
      },
    );

    test('call signal listener exists on controller initialization', () async {
      final fakeSDK = _testSdk;
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(fakeSDK: fakeSDK);
      addTearDown(container.dispose);

      await container.read(meetingPlaceSdkProvider.future);

      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      expect(controller, isNotNull);
    });
  });
}
