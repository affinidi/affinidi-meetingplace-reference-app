import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
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
  final _cancelled = StreamController<IncomingAudioVideoCallEvent>.broadcast();
  final acceptedCallIds = <String>[];
  final declinedCallIds = <String>[];

  void emitIncoming(IncomingAudioVideoCallEvent event) => _incoming.add(event);
  void emitCancelled(IncomingAudioVideoCallEvent event) =>
      _cancelled.add(event);

  @override
  Stream<IncomingAudioVideoCallEvent> get incomingCalls => _incoming.stream;

  @override
  Stream<IncomingAudioVideoCallEvent> get cancelledCalls => _cancelled.stream;

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
  String callId = 'call-1',
  String callerPermanentChannelDid = 'did:key:caller',
  String otherPartyPermanentChannelDid = 'did:key:caller',
  CallMediaType mediaType = CallMediaType.video,
}) => IncomingAudioVideoCallEvent(
  callId: callId,
  callerPermanentChannelDid: callerPermanentChannelDid,
  otherPartyPermanentChannelDid: otherPartyPermanentChannelDid,
  mediaType: mediaType,
  invitedAt: clock.now(),
);

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
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
          ['did:key:caller'],
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

        fakeSDK.emitCancelled(_event());
        await pumpEventQueue();

        expect(container.read(incomingCallProvider).eventOrNull, isNull);
        expect(
          (container.read(contactsServiceProvider.notifier)
                  as FakeContactsService)
              .incrementMissedCallBadgeCalls,
          ['did:key:caller'],
        );
        expect(
          (container.read(contactsServiceProvider.notifier)
                  as FakeContactsService)
              .setPendingMissedCallCalls,
          ['did:key:caller'],
        );
      });

      test('distinct incoming calls each bump the badge with a distinct '
          'episode id, even when the transport call id is identical', () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK();
        final container = buildContainer(fakeSDK);
        addTearDown(container.dispose);

        container.read(incomingCallServiceProvider);
        await container.read(meetingPlaceSdkProvider.future);
        await pumpEventQueue();

        final contacts =
            container.read(contactsServiceProvider.notifier)
                as FakeContactsService;

        // Two separate calls that reuse the same transport call id (the Matrix
        // room id is constant for a 1:1 channel).
        for (var i = 0; i < 2; i++) {
          fakeSDK.emitIncoming(_event(callId: 'same-room'));
          await pumpEventQueue();
          fakeSDK.emitCancelled(_event(callId: 'same-room'));
          await pumpEventQueue();
        }

        // Both calls are counted...
        expect(contacts.incrementMissedCallBadgeCalls, [
          'did:key:caller',
          'did:key:caller',
        ]);
        // ...and keyed by DISTINCT, non-empty episode ids, so the per-callId
        // dedup in ContactsService accumulates them instead of collapsing on
        // the constant room id.
        final ids = contacts.incrementMissedCallBadgeCallIds;
        expect(ids, hasLength(2));
        expect(ids.first, isNotEmpty);
        expect(ids.first, isNot(ids.last));
      });

      test('it marks the third-party call as missed when busy auto-reject fires'
          ' while already in another call', () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK();
        final container = buildContainer(fakeSDK);
        addTearDown(container.dispose);

        container.read(incomingCallServiceProvider);
        await container.read(meetingPlaceSdkProvider.future);
        await pumpEventQueue();

        // A is ringing for the first caller (simulates an accepted/active call
        // where incomingCallProvider still holds the first caller's event).
        fakeSDK.emitIncoming(_event());
        await pumpEventQueue();
        expect(container.read(incomingCallProvider).eventOrNull, isNotNull);

        // A third party calls while A is busy — SDK auto-rejects and surfaces
        // the event on cancelledCalls with a different callId and caller DID.
        const thirdPartyDid = 'did:key:third-party';
        fakeSDK.emitCancelled(
          _event(
            callId: 'call-2',
            callerPermanentChannelDid: thirdPartyDid,
            otherPartyPermanentChannelDid: thirdPartyDid,
          ),
        );
        await pumpEventQueue();

        // The missed-call marker must be written to the third-party's DID,
        // not to the first caller's DID.
        expect(
          (container.read(contactsServiceProvider.notifier)
                  as FakeContactsService)
              .setPendingMissedCallCalls,
          [thirdPartyDid],
        );
        // A busy auto-reject of a third party is recorded only in the chat
        // log, without an unread badge.
        expect(
          (container.read(contactsServiceProvider.notifier)
                  as FakeContactsService)
              .incrementMissedCallBadgeCalls,
          isEmpty,
        );
      });

      test('it badges the group contact when a group cancel arrives before '
          'the incoming banner is emitted', () async {
        final fakeSDK = _FakeMeetingPlaceMatrixSDK();
        final container = buildContainer(fakeSDK);
        addTearDown(container.dispose);

        container.read(incomingCallServiceProvider);
        await container.read(meetingPlaceSdkProvider.future);
        await pumpEventQueue();

        // A group call is cancelled before the incoming banner is emitted, so
        // there is no active ring. The control-plane decline fans out through
        // the group channel, exactly as the SDK's CallSignalMapper emits it:
        //  - callerPermanentChannelDid = the group channel DID (keys the group
        //    contact),
        //  - otherPartyPermanentChannelDid = THIS device's own channel DID
        //    (never a contact — must not be used as the badge target),
        //  - callId falls back to the caller (group) DID because the transport
        //    call id is not yet visible.
        const groupDid = 'did:key:group-channel';
        const ownDid = 'did:key:own-channel';
        fakeSDK.emitCancelled(
          _event(
            callId: groupDid,
            callerPermanentChannelDid: groupDid,
            otherPartyPermanentChannelDid: ownDid,
          ),
        );
        await pumpEventQueue();
        await pumpEventQueue();

        final contacts =
            container.read(contactsServiceProvider.notifier)
                as FakeContactsService;
        final chatService =
            container.read(chatSessionServiceProvider(groupDid).notifier)
                as FakeChatSessionService;
        // The badge and marker land on the group contact
        // (callerPermanentChannelDid), not on this device's own DID.
        expect(contacts.incrementMissedCallBadgeCalls, [groupDid]);
        expect(contacts.setPendingMissedCallCalls, [groupDid]);
        expect(contacts.incrementMissedCallBadgeCallIds.single, isNotEmpty);
        // The caller-DID fallback call id is not persisted as a real marker.
        expect(chatService.lastResolveIncomingCallId, isNull);
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

          async.elapse(const Duration(seconds: 60));
          async.flushMicrotasks();

          expect(container.read(incomingCallProvider).eventOrNull, isNull);
          expect(fakeSDK.declinedCallIds, ['call-1']);
          expect(
            (container.read(contactsServiceProvider.notifier)
                    as FakeContactsService)
                .incrementMissedCallBadgeCalls,
            ['did:key:caller'],
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

    group('and the app resumes from the background', () {
      test('cleans up a ring that expired while backgrounded', () {
        fakeAsync((async) {
          final fakeSDK = _FakeMeetingPlaceMatrixSDK();
          final container = buildContainer(fakeSDK);

          final service = container.read(incomingCallServiceProvider.notifier);
          async.flushMicrotasks();

          fakeSDK.emitIncoming(_event());
          async.flushMicrotasks();
          expect(container.read(incomingCallProvider).eventOrNull, isNotNull);

          async.elapseBlocking(const Duration(seconds: 61));
          service.didChangeAppLifecycleState(AppLifecycleState.resumed);
          async.flushMicrotasks();

          expect(container.read(incomingCallProvider).eventOrNull, isNull);
          expect(fakeSDK.declinedCallIds, ['call-1']);
          expect(
            (container.read(contactsServiceProvider.notifier)
                    as FakeContactsService)
                .setPendingMissedCallCalls,
            ['did:key:caller'],
          );

          container.dispose();
        });
      });

      test('re-arms the timer when the ring has not yet expired', () {
        fakeAsync((async) {
          final fakeSDK = _FakeMeetingPlaceMatrixSDK();
          final container = buildContainer(fakeSDK);

          final service = container.read(incomingCallServiceProvider.notifier);
          async.flushMicrotasks();

          fakeSDK.emitIncoming(_event());
          async.flushMicrotasks();

          async.elapseBlocking(const Duration(seconds: 30));
          service.didChangeAppLifecycleState(AppLifecycleState.resumed);
          async.flushMicrotasks();

          expect(fakeSDK.declinedCallIds, isEmpty);
          expect(container.read(incomingCallProvider).eventOrNull, isNotNull);

          async.elapse(const Duration(seconds: 30));
          async.flushMicrotasks();

          expect(fakeSDK.declinedCallIds, ['call-1']);
          expect(container.read(incomingCallProvider).eventOrNull, isNull);

          container.dispose();
        });
      });
    });
  });
}
