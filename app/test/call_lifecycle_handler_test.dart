import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/call_audio_session_service/call_audio_session_service.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_state.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/call_lifecycle_update.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/handlers/call_lifecycle_handler.dart';

import 'fakes/fake_audio_session.dart';

class _FakeCallSession extends Fake implements AudioVideoCallSession {
  int setSpeakerphoneEnabledCalls = 0;
  bool? lastSpeakerphoneEnabled;

  @override
  Future<void> setSpeakerphoneEnabled(bool enabled) async {
    setSpeakerphoneEnabledCalls++;
    lastSpeakerphoneEnabled = enabled;
  }
}

class _FakeMeetingPlaceMatrixSDK extends Fake implements MeetingPlaceMatrixSDK {
  _FakeMeetingPlaceMatrixSDK({
    AudioVideoCallSession? session,
    this.startCallError,
  }) : leaveCurrentCallError = null,
       session = session ?? _FakeCallSession();

  final AudioVideoCallSession session;
  final Exception? startCallError;
  final Exception? leaveCurrentCallError;
  int startCallCount = 0;
  int leaveCurrentCallCount = 0;
  String? lastOtherPartyChannelDid;
  CallMediaType? lastMediaType;

  @override
  Future<AudioVideoCallSession> startCall({
    required String otherPartyChannelDid,
    required CallMediaType mediaType,
  }) async {
    startCallCount++;
    lastOtherPartyChannelDid = otherPartyChannelDid;
    lastMediaType = mediaType;
    if (startCallError != null) throw startCallError!;
    return session;
  }

  @override
  Future<void> leaveCurrentCall() async {
    leaveCurrentCallCount++;
    if (leaveCurrentCallError != null) throw leaveCurrentCallError!;
  }
}

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/call_lifecycle_handler_test.log'),
    );
  });

  late ProviderContainer container;
  late FakeAudioSession audioSession;
  late AudioVideoCallScreenState state;
  late AudioVideoCallSession? currentSession;
  late List<CallLifecycleUpdate> updates;
  late _FakeMeetingPlaceMatrixSDK sdk;

  CallLifecycleHandler buildHandler({String? channelDid = 'did:key:peer'}) {
    return CallLifecycleHandler(
      logger: AppLogger.instance,
      channelDid: channelDid,
      audioSessionService: container.read(
        callAudioSessionServiceProvider.notifier,
      ),
      getState: () => state,
      getSDK: () => sdk,
      getSession: () => currentSession,
      setSession: (session) => currentSession = session,
      onUpdate: updates.add,
    );
  }

  setUp(() {
    audioSession = FakeAudioSession();
    container = ProviderContainer(
      overrides: [
        canUsePlatformAudioSessionProvider.overrideWith((ref) => true),
        audioSessionProvider.overrideWith((ref) async => audioSession),
      ],
    );
    state = AudioVideoCallScreenState();
    currentSession = null;
    updates = [];
    sdk = _FakeMeetingPlaceMatrixSDK();
  });

  tearDown(() => container.dispose());

  group('joinCall', () {
    test('acquires audio session and starts an audio call', () async {
      state = state.copyWith(isAudioOnly: true);
      final session = _FakeCallSession();
      sdk = _FakeMeetingPlaceMatrixSDK(session: session);
      final handler = buildHandler();

      await handler.joinCall();

      expect(
        container.read(callAudioSessionServiceProvider).isAcquired,
        isTrue,
      );
      expect(audioSession.configureCalls, 1);
      expect(audioSession.setActiveCalls, 1);
      expect(audioSession.lastSetActiveValue, isTrue);
      expect(
        audioSession.lastConfiguration?.avAudioSessionMode,
        AVAudioSessionMode.voiceChat,
      );
      expect(sdk.startCallCount, 1);
      expect(sdk.lastOtherPartyChannelDid, 'did:key:peer');
      expect(sdk.lastMediaType, CallMediaType.audio);
      expect(session.setSpeakerphoneEnabledCalls, 1);
      expect(session.lastSpeakerphoneEnabled, isTrue);
      expect(updates.first.status, AudioVideoCallStatus.connecting);
      expect(updates.last.attachedSession, same(session));
    });

    test('releases audio session when startCall fails', () async {
      sdk = _FakeMeetingPlaceMatrixSDK(startCallError: Exception('boom'));
      final handler = buildHandler();

      await handler.joinCall();

      expect(audioSession.setActiveCalls, 2);
      expect(audioSession.lastSetActiveValue, isFalse);
      expect(
        container.read(callAudioSessionServiceProvider).isAcquired,
        isFalse,
      );
      expect(updates.last.status, AudioVideoCallStatus.error);
    });
  });

  group('leaveCall', () {
    test('releases audio session and emits ended update', () async {
      currentSession = _FakeCallSession();
      final handler = buildHandler();
      await container
          .read(callAudioSessionServiceProvider.notifier)
          .acquire(isAudioOnly: false);

      await handler.leaveCall();

      expect(sdk.leaveCurrentCallCount, 1);
      expect(audioSession.setActiveCalls, 2);
      expect(audioSession.lastSetActiveValue, isFalse);
      expect(
        audioSession.lastSetActiveOptions,
        AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      );
      expect(
        container.read(callAudioSessionServiceProvider).isAcquired,
        isFalse,
      );
      expect(currentSession, isNull);
      expect(updates.single.status, AudioVideoCallStatus.ended);
      expect(updates.single.clearIncomingCall, isTrue);
    });
  });
}
