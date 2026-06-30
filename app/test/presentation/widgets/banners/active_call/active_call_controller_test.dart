import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show
        AudioVideoCallParticipant,
        AudioVideoCallState,
        AudioVideoCallStatus,
        CallRole,
        CallStatus;
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/app_logger_provider.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_state.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/end_call/end_call_banner_controller.dart';

import '../../../../mocks/fake_app_logger.dart';
import '../../../../mocks/fake_chat_session_service.dart';
import '../../../../mocks/fake_end_call_banner_controller.dart';
import '../../../../mocks/mock_audio_video_call_session.dart';

const _kChannelDid = 'did:test:channel';
const _kMsgId = 'call-msg-01';
const _kPeerName = 'Alice';

ProviderContainer _makeContainer({
  FakeChatSessionService? chatService,
  FakeEndCallBannerController? bannerController,
}) {
  final chat = chatService ?? FakeChatSessionService();
  final banner = bannerController ?? FakeEndCallBannerController();
  final container = ProviderContainer(
    overrides: [
      appLoggerProvider.overrideWithValue(FakeAppLogger()),
      chatSessionServiceProvider(_kChannelDid).overrideWith(() => chat),
      endCallBannerControllerProvider.overrideWith(() => banner),
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
        );

        session.dispose();
        await _pumpAsync();

        expect(container.read(activeCallControllerProvider), isNull);
      },
    );
  });
}

AudioVideoCallParticipant _remotePeer() {
  return const AudioVideoCallParticipant(participantId: 'remote-peer');
}
