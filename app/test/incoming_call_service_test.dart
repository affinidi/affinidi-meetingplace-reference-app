import 'dart:async';
import 'dart:io';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_service.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/audio_video_call_plugin_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/incoming_call_state_provider.dart';

import 'mocks/fake_chat_session_service.dart';

class _FakeCallPlugin extends Fake implements AudioVideoCallPlugin {
  final _incoming = StreamController<IncomingAudioVideoCallEvent>.broadcast();
  final _cancelled = StreamController<String>.broadcast();
  final acceptedCallIds = <String>[];
  final declinedCallIds = <String>[];

  void emitIncoming(IncomingAudioVideoCallEvent event) => _incoming.add(event);

  @override
  Stream<IncomingAudioVideoCallEvent> get incomingCalls => _incoming.stream;

  @override
  Stream<String> get cancelledCalls => _cancelled.stream;

  @override
  Future<void> acceptCall({required String callId}) async =>
      acceptedCallIds.add(callId);

  @override
  Future<void> declineCall({required String callId}) async =>
      declinedCallIds.add(callId);
}

IncomingAudioVideoCallEvent _event({
  String callId = 'call-1',
  CallMediaType mediaType = CallMediaType.video,
}) => IncomingAudioVideoCallEvent(
  callId: callId,
  otherPartyChannelDid: 'did:key:caller',
  mediaType: mediaType,
);

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/incoming_call_service_test.log'),
    );
  });

  ProviderContainer buildContainer(_FakeCallPlugin plugin) => ProviderContainer(
    overrides: [
      audioVideoCallPluginProvider.overrideWith((ref) async => plugin),
      chatSessionServiceProvider.overrideWith(FakeChatSessionService.new),
    ],
  );

  group('incoming call', () {
    test('preserves audio media type on the incoming call state', () async {
      final plugin = _FakeCallPlugin();
      final container = buildContainer(plugin);
      addTearDown(container.dispose);

      container.read(incomingCallServiceProvider);
      await container.read(audioVideoCallPluginProvider.future);
      await pumpEventQueue();

      final event = _event(mediaType: CallMediaType.audio);
      plugin.emitIncoming(event);
      await pumpEventQueue();

      expect(
        container.read(incomingCallStateProvider)?.mediaType,
        CallMediaType.audio,
      );
    });

    test('sets the incoming call state when an event arrives', () async {
      final plugin = _FakeCallPlugin();
      final container = buildContainer(plugin);
      addTearDown(container.dispose);

      container.read(incomingCallServiceProvider);
      await container.read(audioVideoCallPluginProvider.future);
      await pumpEventQueue();

      final event = _event();
      plugin.emitIncoming(event);
      await pumpEventQueue();

      expect(container.read(incomingCallStateProvider), same(event));
    });
  });

  group('accept', () {
    test(
      'preserves incoming-call state for the call screen and forwards the call'
      ' id to the plugin',
      () async {
        final plugin = _FakeCallPlugin();
        final container = buildContainer(plugin);
        addTearDown(container.dispose);

        container.read(incomingCallServiceProvider);
        await container.read(audioVideoCallPluginProvider.future);
        await pumpEventQueue();

        plugin.emitIncoming(_event());
        await pumpEventQueue();

        container
            .read(incomingCallServiceProvider.notifier)
            .accept(callId: 'call-1');
        await pumpEventQueue();

        expect(container.read(incomingCallStateProvider), isNotNull);
        expect(plugin.acceptedCallIds, ['call-1']);
        expect(plugin.declinedCallIds, isEmpty);
      },
    );
  });

  group('decline', () {
    test('clears the state and forwards the call id to the plugin', () async {
      final plugin = _FakeCallPlugin();
      final container = buildContainer(plugin);
      addTearDown(container.dispose);

      container.read(incomingCallServiceProvider);
      await container.read(audioVideoCallPluginProvider.future);
      await pumpEventQueue();

      plugin.emitIncoming(_event());
      await pumpEventQueue();

      container
          .read(incomingCallServiceProvider.notifier)
          .decline(callId: 'call-1');
      await pumpEventQueue();

      expect(container.read(incomingCallStateProvider), isNull);
      expect(plugin.declinedCallIds, ['call-1']);
      expect(plugin.acceptedCallIds, isEmpty);
    });
  });

  group('ring timeout', () {
    test('auto-declines and clears the state after the timeout', () {
      fakeAsync((async) {
        final plugin = _FakeCallPlugin();
        final container = buildContainer(plugin);

        container.read(incomingCallServiceProvider);
        async.flushMicrotasks();

        plugin.emitIncoming(_event());
        async.flushMicrotasks();
        expect(container.read(incomingCallStateProvider), isNotNull);

        async.elapse(const Duration(seconds: 15));

        expect(container.read(incomingCallStateProvider), isNull);
        expect(plugin.declinedCallIds, ['call-1']);

        container.dispose();
      });
    });

    test('does not auto-decline once the call is accepted', () {
      fakeAsync((async) {
        final plugin = _FakeCallPlugin();
        final container = buildContainer(plugin);

        container.read(incomingCallServiceProvider);
        async.flushMicrotasks();

        plugin.emitIncoming(_event());
        async.flushMicrotasks();

        container
            .read(incomingCallServiceProvider.notifier)
            .accept(callId: 'call-1');
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 30));

        expect(plugin.declinedCallIds, isEmpty);
        expect(plugin.acceptedCallIds, ['call-1']);

        container.dispose();
      });
    });
  });
}
