import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/audio_video_call_plugin_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/incoming_call_state_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/permission_service/permission_service.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import 'package:mpx_flutter_reference_app/presentation/widgets/banners/active_call/active_call_controller.dart';

import 'fakes/fake_chat_session_service.dart';
import 'fakes/fake_contacts.dart';
import 'fakes/fake_contacts_service.dart';
import 'fakes/fake_permission_service.dart';

class _FakeCallSession extends Fake implements AudioVideoCallSession {
  final _controller = StreamController<AudioVideoCallState>.broadcast();
  int hangUpCalls = 0;

  void emit(AudioVideoCallState s) => _controller.add(s);

  @override
  Stream<AudioVideoCallState> get state => _controller.stream;

  @override
  Future<void> setMicrophoneEnabled(bool enabled) async {}

  @override
  Future<void> setCameraEnabled(bool enabled) async {}

  @override
  Future<void> setSpeakerphoneEnabled(bool enabled) async {}

  @override
  Future<void> hangUp() async => hangUpCalls++;
}

class _FakePlugin extends Fake implements AudioVideoCallPlugin {
  _FakePlugin() : _session = _FakeCallSession();

  final _FakeCallSession _session;

  @override
  bool get isSupported => true;

  @override
  Stream<IncomingAudioVideoCallEvent> get incomingCalls =>
      const Stream<IncomingAudioVideoCallEvent>.empty();

  @override
  Future<AudioVideoCallSession> startCall({
    required String otherPartyChannelDid,
    required CallMediaType mediaType,
  }) async => _session;

  @override
  Future<void> acceptCall({required String callId}) async {}

  @override
  Future<void> declineCall({required String callId}) async {}

  void emitState(AudioVideoCallState s) => _session.emit(s);
}

ProviderContainer _buildContainer({
  _FakePlugin? plugin,
  FakePermissionService? permissionService,
}) {
  return ProviderContainer(
    overrides: [
      contactsServiceProvider.overrideWith(FakeContactsService.new),
      chatSessionServiceProvider.overrideWith(FakeChatSessionService.new),
      audioVideoCallPluginProvider.overrideWith(
        (ref) async => plugin ?? _FakePlugin(),
      ),
      permissionServiceProvider.overrideWith(
        (ref) => permissionService ?? FakePermissionService(),
      ),
    ],
  );
}

class _SpyChatSessionService extends FakeChatSessionService {
  _SpyChatSessionService({required this.onSendOutgoingCallMessage});

  final void Function() onSendOutgoingCallMessage;

  @override
  Future<String?> sendOutgoingCallMessage({
    required CallMediaType mediaType,
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
  });
  group('service state forwarding', () {
    test(
      'status update from session stream is reflected in controller state',
      () async {
        final plugin = _FakePlugin();
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(plugin: plugin);
        addTearDown(container.dispose);

        await container.read(audioVideoCallPluginProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );

        await controller.joinCall();

        plugin.emitState(
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
    test('sets status to connecting', () async {
      final plugin = _FakePlugin();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(plugin: plugin);
      addTearDown(container.dispose);

      await container.read(audioVideoCallPluginProvider.future);

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
      final plugin = _FakePlugin();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(plugin: plugin);
      addTearDown(container.dispose);

      await container.read(audioVideoCallPluginProvider.future);
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

    test('individual call keeps isSpeakerEnabled false', () async {
      final plugin = _FakePlugin();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(plugin: plugin);
      addTearDown(container.dispose);

      await container.read(audioVideoCallPluginProvider.future);

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

    test('group call enables speakerphone', () async {
      final plugin = _FakePlugin();
      final contactId = FakeContacts.groupContact.id;
      final container = _buildContainer(plugin: plugin);
      addTearDown(container.dispose);

      await container.read(audioVideoCallPluginProvider.future);

      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .isSpeakerEnabled,
        isTrue,
      );
    });
  });

  group('leaveCall', () {
    test('sets status to ended', () async {
      final container = _buildContainer();
      addTearDown(container.dispose);

      await container
          .read(audioVideoCallScreenControllerProvider('no-such-id').notifier)
          .leaveCall();

      expect(
        container
            .read(audioVideoCallScreenControllerProvider('no-such-id'))
            .status,
        AudioVideoCallStatus.ended,
      );
    });
  });

  group('banner timer wiring', () {
    test('startTimer is called on banner when first remote joins', () async {
      final plugin = _FakePlugin();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(plugin: plugin);
      addTearDown(container.dispose);

      await container.read(audioVideoCallPluginProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .joinCall();

      plugin.emitState(
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
  });

  group('startCall', () {
    test('sets isAudioOnly on the state', () async {
      final plugin = _FakePlugin();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(plugin: plugin);
      addTearDown(container.dispose);

      await container.read(audioVideoCallPluginProvider.future);
      await container
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .startCall(isAudioOnly: true);

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .isAudioOnly,
        isTrue,
      );
    });

    test('places an outgoing call (status becomes connecting)', () async {
      final plugin = _FakePlugin();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(plugin: plugin);
      addTearDown(container.dispose);

      await container.read(audioVideoCallPluginProvider.future);
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
      final plugin = _FakePlugin();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(plugin: plugin);
      addTearDown(container.dispose);

      await container.read(audioVideoCallPluginProvider.future);
      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      // Simulate a missed call.
      await controller.joinCall();
      plugin.emitState(
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
      final plugin = _FakePlugin();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(plugin: plugin);
      addTearDown(container.dispose);

      await container.read(audioVideoCallPluginProvider.future);
      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      await controller.joinCall();

      // Peer joins, latch flips to true.
      plugin.emitState(
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
      plugin.emitState(
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

    test('sets isAudioOnly on the restarted call', () async {
      final plugin = _FakePlugin();
      final contactId = FakeContacts.individualContact.id;
      final container = _buildContainer(plugin: plugin);
      addTearDown(container.dispose);

      await container.read(audioVideoCallPluginProvider.future);
      final controller = container.read(
        audioVideoCallScreenControllerProvider(contactId).notifier,
      );

      await controller.joinCall();
      plugin.emitState(
        const AudioVideoCallState(status: AudioVideoCallStatus.missed),
      );
      await Future<void>.microtask(() {});

      await controller.restartCall(isAudioOnly: true);

      expect(
        container
            .read(audioVideoCallScreenControllerProvider(contactId))
            .isAudioOnly,
        isTrue,
      );
    });
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
        final plugin = _FakePlugin();
        final contactId = FakeContacts.individualContact.id;
        final container = _buildContainer(plugin: plugin);
        addTearDown(container.dispose);

        await container.read(audioVideoCallPluginProvider.future);
        final controller = container.read(
          audioVideoCallScreenControllerProvider(contactId).notifier,
        );
        await controller.joinCall();

        plugin.emitState(AudioVideoCallState(status: status));
        await Future<void>.microtask(() {});

        // Dispose the screen controller (simulates Navigator.pop).
        container.invalidate(audioVideoCallScreenControllerProvider(contactId));
        await Future<void>.microtask(() {});

        expect(
          plugin._session.hangUpCalls,
          0,
          reason: 'hangUp must not be called when already in $status',
        );
      });
    }
  });

  group('incoming call', () {
    test(
      'does not send outgoing call chat item when accepting incoming call',
      () async {
        final plugin = _FakePlugin();
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
            audioVideoCallPluginProvider.overrideWith((ref) async => plugin),
            permissionServiceProvider.overrideWith(
              (ref) => FakePermissionService(),
            ),
          ],
        );
        addTearDown(container.dispose);

        // Set the incoming event before the controller builds so its build()
        // sees isAcceptedIncomingForThisScreen = true.
        container
            .read(incomingCallStateProvider.notifier)
            .set(
              IncomingAudioVideoCallEvent(
                callId: 'call-123',
                otherPartyChannelDid: channelDid,
                mediaType: CallMediaType.video,
              ),
            );

        await container.read(audioVideoCallPluginProvider.future);
        await container
            .read(audioVideoCallScreenControllerProvider(contactId).notifier)
            .joinCall();

        plugin.emitState(AudioVideoCallState.initial);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(sendOutgoingCallMessageCount, 0);
      },
    );
  });
}
