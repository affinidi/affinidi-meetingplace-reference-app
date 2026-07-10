import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/application/services/chat_service/chat_session_service.dart';
import 'package:mpx_flutter_reference_app/application/services/contacts_service/contacts_service.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_notifier.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_service.dart';
import 'package:mpx_flutter_reference_app/application/services/incoming_call_service/incoming_call_state.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/infrastructure/providers/meeting_place_sdk_provider.dart';
import 'package:mpx_flutter_reference_app/infrastructure/services/call_audio_session_service/call_audio_session_service.dart';

import 'fakes/fake_audio_session.dart';
import 'fakes/fake_chat_session_service.dart';
import 'fakes/fake_contacts_service.dart';

class _FakeMeetingPlaceMatrixSDK extends Fake implements MeetingPlaceMatrixSDK {
  final _incoming = StreamController<IncomingAudioVideoCallEvent>.broadcast();
  final _cancelled = StreamController<String>.broadcast();
  final acceptedCallIds = <String>[];
  final declinedCallIds = <String>[];

  void emitIncoming(IncomingAudioVideoCallEvent event) => _incoming.add(event);
  void emitCancelled(String callId) => _cancelled.add(callId);

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

  @override
  Future<void> leaveCurrentCall() async {}
}

IncomingAudioVideoCallEvent _event({
  String callerPermanentChannelDid = 'did:key:caller',
  CallMediaType mediaType = CallMediaType.video,
}) => IncomingAudioVideoCallEvent(
  callerPermanentChannelDid: callerPermanentChannelDid,
  otherPartyPermanentChannelDid: 'did:key:caller',
  mediaType: mediaType,
);

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/incoming_call_service_test.log'),
    );
  });

  ProviderContainer buildContainer(
    _FakeMeetingPlaceMatrixSDK fakeSDK, {
    FakeAudioSession? audioSession,
    bool canUsePlatformAudioSession = false,
  }) => ProviderContainer(
    overrides: [
      meetingPlaceSdkProvider.overrideWith((ref) async => fakeSDK),
      chatSessionServiceProvider.overrideWith(FakeChatSessionService.new),
      contactsServiceProvider.overrideWith(FakeContactsService.new),
      canUsePlatformAudioSessionProvider.overrideWith(
        (ref) => canUsePlatformAudioSession,
      ),
      if (audioSession != null)
        audioSessionProvider.overrideWith((ref) async => audioSession),
    ],
  );

  group('when there is an incoming call', () {
    test('it preserves audio media type on the incoming call state', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final container = buildContainer(fakeSDK);
      addTearDown(container.dispose);

      container.read(incomingCallServiceProvider);
      await container.read(meetingPlaceSdkProvider.future);
      await pumpEventQueue();

      final event = _event(mediaType: CallMediaType.audio);
      fakeSDK.emitIncoming(event);
      await pumpEventQueue();

      expect(
        container.read(incomingCallProvider).eventOrNull?.mediaType,
        CallMediaType.audio,
      );
    });

    test('it sets the incoming call state when an event arrives', () async {
      final fakeSDK = _FakeMeetingPlaceMatrixSDK();
      final container = buildContainer(fakeSDK);
      addTearDown(container.dispose);

      container.read(incomingCallServiceProvider);
      await container.read(meetingPlaceSdkProvider.future);
      await pumpEventQueue();

      final event = _event();
      fakeSDK.emitIncoming(event);
      await pumpEventQueue();

      expect(
        container.read(incomingCallProvider),
        IncomingCallState.ringing(event),
      );
    });

    group('and the recipient accepts the call', () {
      test(
        '''it preserves incoming-call state for the call screen and forwards the call id to the SDK''',
        () async {
          final fakeSDK = _FakeMeetingPlaceMatrixSDK();
          final audioSession = FakeAudioSession();
          final container = buildContainer(
            fakeSDK,
            audioSession: audioSession,
            canUsePlatformAudioSession: true,
          );
          addTearDown(container.dispose);

          container.read(incomingCallServiceProvider);
          await container.read(meetingPlaceSdkProvider.future);
          await pumpEventQueue();

          fakeSDK.emitIncoming(_event());
          await pumpEventQueue();

          container
              .read(incomingCallServiceProvider.notifier)
              .accept(callId: 'call-1');
          await pumpEventQueue();

          expect(container.read(incomingCallProvider).eventOrNull, isNotNull);
          expect(fakeSDK.acceptedCallIds, ['call-1']);
          expect(fakeSDK.declinedCallIds, isEmpty);
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
        },
      );
    });

    group('and the recipient declines the call', () {
      test('it clears the state and forwards the call id to the SDK', () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK();
        final container = buildContainer(fakeSDK);
        addTearDown(container.dispose);

        container.read(incomingCallServiceProvider);
        await container.read(meetingPlaceSdkProvider.future);
        await pumpEventQueue();

        fakeSDK.emitIncoming(_event());
        await pumpEventQueue();

        container
            .read(incomingCallServiceProvider.notifier)
            .decline(callId: 'call-1');
        await pumpEventQueue();

        expect(container.read(incomingCallProvider).eventOrNull, isNull);
        expect(fakeSDK.declinedCallIds, ['call-1']);
        expect(fakeSDK.acceptedCallIds, isEmpty);
        expect(
          (container.read(contactsServiceProvider.notifier)
                  as FakeContactsService)
              .incrementMissedCallBadgeCalls,
          isEmpty,
        );
        expect(
          (container.read(contactsServiceProvider.notifier)
                  as FakeContactsService)
              .setPendingMissedCallCalls,
          ['did:key:caller'],
        );
      });
    });

    group('and the caller cancels the call', () {
      test('it clears the incoming call state', () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK();
        final container = buildContainer(fakeSDK);
        addTearDown(container.dispose);

        container.read(incomingCallServiceProvider);
        await container.read(meetingPlaceSdkProvider.future);
        await pumpEventQueue();

        fakeSDK.emitIncoming(_event());
        await pumpEventQueue();

        fakeSDK.emitCancelled('did:key:caller');
        await pumpEventQueue();

        expect(container.read(incomingCallProvider).eventOrNull, isNull);
        expect(
          (container.read(contactsServiceProvider.notifier)
                  as FakeContactsService)
              .incrementMissedCallBadgeCalls,
          isEmpty,
        );
        expect(
          (container.read(contactsServiceProvider.notifier)
                  as FakeContactsService)
              .setPendingMissedCallCalls,
          ['did:key:caller'],
        );
      });
    });

    group('and the recipient does not respond', () {
      test('auto-declines and clears the state after the timeout', () {
        fakeAsync((async) {
          final fakeSDK = _FakeMeetingPlaceMatrixSDK();
          final container = buildContainer(fakeSDK);

          container.read(incomingCallServiceProvider);
          async.flushMicrotasks();

          fakeSDK.emitIncoming(_event());
          async.flushMicrotasks();
          expect(container.read(incomingCallProvider).eventOrNull, isNotNull);

          async.elapse(const Duration(seconds: 15));

          expect(container.read(incomingCallProvider).eventOrNull, isNull);
          expect(fakeSDK.declinedCallIds, ['did:key:caller']);
          async.flushMicrotasks();
          expect(
            (container.read(contactsServiceProvider.notifier)
                    as FakeContactsService)
                .incrementMissedCallBadgeCalls,
            isEmpty,
          );
          expect(
            (container.read(contactsServiceProvider.notifier)
                    as FakeContactsService)
                .setPendingMissedCallCalls,
            ['did:key:caller'],
          );

          container.dispose();
        });
      });

      test('it does not auto-decline once the call is accepted', () {
        fakeAsync((async) {
          final fakeSDK = _FakeMeetingPlaceMatrixSDK();
          final container = buildContainer(fakeSDK);

          container.read(incomingCallServiceProvider);
          async.flushMicrotasks();

          fakeSDK.emitIncoming(_event());
          async.flushMicrotasks();

          container
              .read(incomingCallServiceProvider.notifier)
              .accept(callId: 'call-1');
          async.flushMicrotasks();

          async.elapse(const Duration(seconds: 30));

          expect(fakeSDK.declinedCallIds, isEmpty);
          expect(fakeSDK.acceptedCallIds, ['call-1']);
          expect(
            (container.read(contactsServiceProvider.notifier)
                    as FakeContactsService)
                .incrementMissedCallBadgeCalls,
            isEmpty,
          );

          container.dispose();
        });
      });
    });
  });
}
