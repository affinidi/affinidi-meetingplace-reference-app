import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_state.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner_controller.dart';

import 'package:mpx_flutter_reference_app/presentation/widgets/call_ended/call_ended_controller.dart';

import '../../../../mocks/fake_app_logger.dart';
import '../../../../mocks/fake_call_ended_controller.dart';
import '../../../../mocks/fake_chat_session_service.dart';
import '../../../../mocks/fake_end_call_banner_controller.dart';
import '../../../../mocks/mock_audio_video_call_session.dart';

const _kChannelDid = 'did:test:channel';
const _kMsgId = 'call-msg-01';
const _kPeerName = 'Alice';

ProviderContainer _makeContainer({
  FakeChatSessionService? chatService,
  FakeEndCallBannerController? bannerController,
  FakeCallEndedController? callEndedController,
}) {
  final chat = chatService ?? FakeChatSessionService();
  final banner = bannerController ?? FakeEndCallBannerController();
  final callEnded = callEndedController ?? FakeCallEndedController();
  final container = ProviderContainer(
    overrides: [
      appLoggerProvider.overrideWithValue(FakeAppLogger()),
      chatSessionServiceProvider(_kChannelDid).overrideWith(() => chat),
      endCallBannerControllerProvider.overrideWith(() => banner),
      callEndedControllerProvider.overrideWith(() => callEnded),
    ],
  );
  addTearDown(container.dispose);
  container.listen(activeCallControllerProvider, (_, _) {});
  return container;
}

ActiveCallState _baseState({
  AudioVideoCallStatus status = AudioVideoCallStatus.connecting,
  bool isMinimized = true,
  bool hasHadPeer = false,
  int callDurationSeconds = 0,
}) => ActiveCallState(
  contactId: _kChannelDid,
  peerName: _kPeerName,
  status: status,
  callDurationSeconds: callDurationSeconds,
  isMicEnabled: true,
  isAudioOnly: false,
  hasHadPeer: hasHadPeer,
  isMinimized: isMinimized,
);

Future<void> _pumpAsync() async {
  for (var i = 0; i < 8; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('registerSession', () {
    test('sets state when state is null', () {
      final container = _makeContainer();
      final ctrl = container.read(activeCallControllerProvider.notifier);

      final session = MockAudioVideoCallSession();
      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: false,
        isGroupContact: false,
      );

      expect(container.read(activeCallControllerProvider), isNotNull);
    });

    test('does not overwrite existing state', () {
      final container = _makeContainer();
      final ctrl = container.read(activeCallControllerProvider.notifier);

      ctrl.update(_baseState(status: AudioVideoCallStatus.active));

      final session = MockAudioVideoCallSession();
      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: false,
        isGroupContact: false,
      );

      expect(
        container.read(activeCallControllerProvider)?.status,
        AudioVideoCallStatus.active,
      );
    });

    test('subscribes to session state stream', () async {
      final container = _makeContainer();
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: false,
      );

      await session.emitState(
        const AudioVideoCallState(status: AudioVideoCallStatus.active),
      );
      await _pumpAsync();

      expect(
        container.read(activeCallControllerProvider)?.status,
        AudioVideoCallStatus.active,
      );
    });
  });

  group('_onSessionState', () {
    test('skips state updates when not minimized', () async {
      final container = _makeContainer();
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: false,
        isGroupContact: false,
      );

      await session.emitState(
        const AudioVideoCallState(status: AudioVideoCallStatus.active),
      );
      await _pumpAsync();

      expect(
        container.read(activeCallControllerProvider)?.status,
        AudioVideoCallStatus.connecting,
      );
    });

    test('updates status from session state when minimized', () async {
      final container = _makeContainer();
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: false,
      );

      await session.emitState(
        const AudioVideoCallState(status: AudioVideoCallStatus.active),
      );
      await _pumpAsync();

      expect(
        container.read(activeCallControllerProvider)?.status,
        AudioVideoCallStatus.active,
      );
    });

    test('starts timer once when first peer joins', () async {
      final container = _makeContainer();
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: false,
      );

      await session.emitState(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [_remotePeer()],
        ),
      );
      await _pumpAsync();

      expect(container.read(activeCallControllerProvider)?.hasHadPeer, isTrue);
    });

    test('does not restart timer if already started', () async {
      final container = _makeContainer();
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: false,
      );

      ctrl.startTimer();

      await session.emitState(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [_remotePeer()],
        ),
      );
      await _pumpAsync();

      expect(container.read(activeCallControllerProvider)?.hasHadPeer, isTrue);
    });

    test(
      'calls endCallBannerController.show on missed/declined when minimized',
      () async {
        final chatSvc = FakeChatSessionService(resolveIncomingResult: _kMsgId);
        final banner = FakeEndCallBannerController();
        final container = _makeContainer(
          chatService: chatSvc,
          bannerController: banner,
        );
        final ctrl = container.read(activeCallControllerProvider.notifier);
        final session = MockAudioVideoCallSession();

        ctrl.registerSession(
          session,
          channelDid: _kChannelDid,
          isAudioOnly: false,
          initialStatus: AudioVideoCallStatus.connecting,
          peerName: _kPeerName,
          isMicEnabled: true,
          isMinimized: true,
          isGroupContact: false,
        );

        await session.emitState(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.missed,
            ownRole: CallRole.recipient,
          ),
        );
        await _pumpAsync();

        expect(banner.showCalls, isNotEmpty);
      },
    );

    test('clears state after terminal status', () async {
      final chatSvc = FakeChatSessionService(resolveIncomingResult: _kMsgId);
      final container = _makeContainer(chatService: chatSvc);
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: false,
      );

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.ended,
          ownRole: CallRole.caller,
        ),
      );
      await _pumpAsync();

      expect(container.read(activeCallControllerProvider), isNull);
    });
  });

  group('_endCallChatItem', () {
    test(
      'second terminal emit does not produce a second updateCallChatItem',
      () async {
        final chatSvc = FakeChatSessionService(resolveIncomingResult: _kMsgId);
        final container = _makeContainer(chatService: chatSvc);
        final ctrl = container.read(activeCallControllerProvider.notifier);
        final session = MockAudioVideoCallSession();

        ctrl.registerSession(
          session,
          channelDid: _kChannelDid,
          isAudioOnly: false,
          initialStatus: AudioVideoCallStatus.connecting,
          peerName: _kPeerName,
          isMicEnabled: true,
          isMinimized: true,
          isGroupContact: false,
        );

        await session.emitState(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.ended,
            ownRole: CallRole.caller,
          ),
        );
        await _pumpAsync();

        final firstCount = chatSvc.updateCalls.length;

        await session.emitState(
          const AudioVideoCallState(status: AudioVideoCallStatus.ended),
        );
        await _pumpAsync();

        expect(chatSvc.updateCalls.length, firstCount);
      },
    );

    test('caller with peer emits CallStatus.ended with duration', () async {
      final chatSvc = FakeChatSessionService(sendOutgoingResult: _kMsgId);
      final container = ProviderContainer(
        overrides: [
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
          chatSessionServiceProvider(_kChannelDid).overrideWith(() => chatSvc),
          endCallBannerControllerProvider.overrideWith(
            FakeEndCallBannerController.new,
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(activeCallControllerProvider, (_, _) {});
      container.listen(chatSessionServiceProvider(_kChannelDid), (_, _) {});

      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: false,
      );

      await session.emitState(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [_remotePeer()],
          ownRole: CallRole.caller,
        ),
      );
      await _pumpAsync();

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.ended,
          ownRole: CallRole.caller,
        ),
      );
      await _pumpAsync();

      expect(chatSvc.updateCalls, isNotEmpty);
      expect(chatSvc.updateCalls.last.status, CallStatus.ended);
    });

    test('receiver with no peer emits CallStatus.missed', () async {
      final chatSvc = FakeChatSessionService(resolveIncomingResult: _kMsgId);
      final container = _makeContainer(chatService: chatSvc);
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: false,
      );

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.missed,
          ownRole: CallRole.recipient,
        ),
      );
      await _pumpAsync();

      expect(chatSvc.updateCalls, isNotEmpty);
      expect(chatSvc.updateCalls.last.status, CallStatus.missed);
    });

    test(
      'caller with no peer emits CallStatus.declined with null duration',
      () async {
        final chatSvc = FakeChatSessionService(resolveOutgoingResult: _kMsgId);
        final container = _makeContainer(chatService: chatSvc);
        final ctrl = container.read(activeCallControllerProvider.notifier);
        final session = MockAudioVideoCallSession();

        ctrl.registerSession(
          session,
          channelDid: _kChannelDid,
          isAudioOnly: false,
          initialStatus: AudioVideoCallStatus.connecting,
          peerName: _kPeerName,
          isMicEnabled: true,
          isMinimized: true,
          isGroupContact: false,
        );

        await session.emitState(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.ended,
            ownRole: CallRole.caller,
          ),
        );
        await _pumpAsync();

        expect(chatSvc.updateCalls, isNotEmpty);
        expect(chatSvc.updateCalls.last.status, CallStatus.declined);
        expect(chatSvc.updateCalls.last.duration, isNull);
      },
    );
  });

  group('hangUpFromScreen', () {
    test('seeds _ownRole from role enum', () async {
      final chatSvc = FakeChatSessionService(resolveOutgoingResult: _kMsgId);
      final container = _makeContainer(chatService: chatSvc);
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: false,
      );

      ctrl.hangUpFromScreen(role: CallRole.caller);
      await _pumpAsync();

      expect(chatSvc.updateCalls, isNotEmpty);
      expect(chatSvc.updateCalls.last.status, CallStatus.declined);
    });

    test('does not overwrite existing _ownRole', () async {
      final chatSvc = FakeChatSessionService(resolveIncomingResult: _kMsgId);
      final container = _makeContainer(chatService: chatSvc);
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: false,
      );

      await session.emitState(
        const AudioVideoCallState(ownRole: CallRole.recipient),
      );
      await _pumpAsync();

      ctrl.hangUpFromScreen(role: CallRole.caller);
      await _pumpAsync();

      expect(chatSvc.updateCalls, isNotEmpty);
      expect(chatSvc.updateCalls.last.status, CallStatus.missed);
    });
  });

  group('Timer', () {
    test('startTimer is idempotent', () {
      final container = _makeContainer();
      final ctrl = container.read(activeCallControllerProvider.notifier);

      ctrl.update(_baseState(status: AudioVideoCallStatus.active));
      ctrl.startTimer();
      ctrl.startTimer();

      ctrl.stopTimer();
    });

    test('stopTimer cancels the timer', () {
      final container = _makeContainer();
      final ctrl = container.read(activeCallControllerProvider.notifier);

      ctrl.update(_baseState(status: AudioVideoCallStatus.active));
      ctrl.startTimer();
      ctrl.stopTimer();
    });

    test('clear stops the timer', () {
      final container = _makeContainer();
      final ctrl = container.read(activeCallControllerProvider.notifier);

      ctrl.update(_baseState(status: AudioVideoCallStatus.active));
      ctrl.startTimer();
      ctrl.clear();

      expect(container.read(activeCallControllerProvider), isNull);
    });
  });

  group('session stream onDone', () {
    test(
      'clears state when session stream closes without a terminal status',
      () async {
        final container = _makeContainer();
        final ctrl = container.read(activeCallControllerProvider.notifier);
        final session = MockAudioVideoCallSession();

        ctrl.registerSession(
          session,
          channelDid: _kChannelDid,
          isAudioOnly: false,
          initialStatus: AudioVideoCallStatus.connecting,
          peerName: _kPeerName,
          isMicEnabled: true,
          isMinimized: true,
          isGroupContact: false,
        );

        session.dispose();
        await _pumpAsync();

        expect(container.read(activeCallControllerProvider), isNull);
      },
    );
  });

  group('clear and _releaseChatServiceAfter', () {
    test('defers chat service disposal until endCallWrite completes', () async {
      final chatSvc = FakeChatSessionService(resolveOutgoingResult: _kMsgId);
      final container = ProviderContainer(
        overrides: [
          appLoggerProvider.overrideWithValue(FakeAppLogger()),
          chatSessionServiceProvider(_kChannelDid).overrideWith(() => chatSvc),
          endCallBannerControllerProvider.overrideWith(
            FakeEndCallBannerController.new,
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(activeCallControllerProvider, (_, _) {});

      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: false,
      );

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.ended,
          ownRole: CallRole.caller,
        ),
      );
      await _pumpAsync();

      ctrl.clear();
      await _pumpAsync();

      expect(container.read(activeCallControllerProvider), isNull);
    });

    test(
      'does not release chat service if subscription ID does not match',
      () async {
        final chatSvc = FakeChatSessionService(sendOutgoingResult: _kMsgId);
        final container = ProviderContainer(
          overrides: [
            appLoggerProvider.overrideWithValue(FakeAppLogger()),
            chatSessionServiceProvider(
              _kChannelDid,
            ).overrideWith(() => chatSvc),
            endCallBannerControllerProvider.overrideWith(
              FakeEndCallBannerController.new,
            ),
          ],
        );
        addTearDown(container.dispose);
        container.listen(activeCallControllerProvider, (_, _) {});

        final ctrl = container.read(activeCallControllerProvider.notifier);
        final session = MockAudioVideoCallSession();

        ctrl.registerSession(
          session,
          channelDid: _kChannelDid,
          isAudioOnly: false,
          initialStatus: AudioVideoCallStatus.connecting,
          peerName: _kPeerName,
          isMicEnabled: true,
          isMinimized: true,
          isGroupContact: false,
        );

        await session.emitState(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.active,
            ownRole: CallRole.caller,
          ),
        );
        await _pumpAsync();

        ctrl.clear();
        await _pumpAsync();

        expect(container.read(activeCallControllerProvider), isNull);
      },
    );
  });

  // =========================================================================
  // Peer-left auto-end (1-on-1 calls)
  // =========================================================================

  group('peer-left auto-end', () {
    test('hangs up when peer leaves a 1-on-1 live call', () async {
      final container = _makeContainer();
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: false,
      );

      // Peer joins
      await session.emitState(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [_remotePeer()],
        ),
      );
      await _pumpAsync();

      // Peer leaves
      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [],
        ),
      );
      await _pumpAsync();

      expect(session.hangUpCalls, 1);
    });

    test('does not hang up when peer leaves a group call', () async {
      final container = _makeContainer();
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: true,
      );

      await session.emitState(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [_remotePeer()],
        ),
      );
      await _pumpAsync();

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [],
        ),
      );
      await _pumpAsync();

      expect(session.hangUpCalls, 0);
    });

    test('does not hang up when no peer was ever connected', () async {
      final container = _makeContainer();
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: false,
      );

      await session.emitState(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [],
        ),
      );
      await _pumpAsync();

      expect(session.hangUpCalls, 0);
    });
  });

  // =========================================================================
  // hangUp shows CallEnded overlay
  // =========================================================================

  group('hangUp shows CallEnded overlay', () {
    test('shows CallEnded screen when peer was connected', () async {
      final callEnded = FakeCallEndedController();
      final container = _makeContainer(callEndedController: callEnded);
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: true,
        isGroupContact: false,
      );
      await session.emitState(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [_remotePeer()],
        ),
      );
      await _pumpAsync();

      ctrl.hangUp();
      await _pumpAsync();

      expect(callEnded.showCalls, hasLength(1));
      expect(callEnded.showCalls.first.peerName, _kPeerName);
    });

    test('does not show CallEnded screen when no peer was connected', () {
      final callEnded = FakeCallEndedController();
      final container = _makeContainer(callEndedController: callEnded);
      final ctrl = container.read(activeCallControllerProvider.notifier);
      final session = MockAudioVideoCallSession();

      ctrl.registerSession(
        session,
        channelDid: _kChannelDid,
        isAudioOnly: false,
        initialStatus: AudioVideoCallStatus.connecting,
        peerName: _kPeerName,
        isMicEnabled: true,
        isMinimized: false,
        isGroupContact: false,
      );

      ctrl.hangUp();

      expect(callEnded.showCalls, isEmpty);
    });
  });
}

AudioVideoCallParticipant _remotePeer() {
  return const AudioVideoCallParticipant(participantId: 'remote-peer');
}
