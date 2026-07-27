import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/handlers/call_chat_item_handler.dart';

import '../../../../../mocks/fake_app_logger.dart';
import '../../../../../mocks/fake_audio_video_call_participant.dart';
import '../../../../../mocks/mock_audio_video_call_session.dart';

typedef CallChatItemId = String;

void main() {
  group('CallChatItemHandler', () {
    group('endCallWrite', () {
      test('returns null before endCall is called', () {
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              null,
          updateItem:
              (
                _, {
                required CallStatus status,
                Duration? duration,
                CallParticipation? participation,
              }) async {},
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        expect(handler.endCallWrite, isNull);
      });

      test('returns in-flight Future after endCall is called', () async {
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              'msg-123',
          updateItem:
              (
                _, {
                required CallStatus status,
                Duration? duration,
                CallParticipation? participation,
              }) async {},
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        handler.endCall(assumeRole: CallRole.caller);

        expect(handler.endCallWrite, isNotNull);
        expect(handler.endCallWrite, isA<Future<void>>());
      });

      test('captures the same Future on repeated access', () async {
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              'msg-456',
          updateItem:
              (
                _, {
                required CallStatus status,
                Duration? duration,
                CallParticipation? participation,
              }) async {},
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        handler.endCall(assumeRole: CallRole.recipient);

        expect(handler.endCallWrite, same(handler.endCallWrite));
      });

      test('allows callers to await the write before cleanup', () async {
        var updateCallCount = 0;
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              'msg-789',
          updateItem:
              (
                _, {
                required CallStatus status,
                Duration? duration,
                CallParticipation? participation,
              }) async {
                updateCallCount++;
              },
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        handler.endCall(assumeRole: CallRole.caller);

        final pendingWrite = handler.endCallWrite;
        expect(updateCallCount, isZero);

        await pendingWrite;

        expect(updateCallCount, equals(1));
      });
    });

    group('idempotency on endCall', () {
      test('second call to endCall is a no-op', () async {
        var updateCallCount = 0;
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              'msg-abc',
          updateItem:
              (
                _, {
                required CallStatus status,
                Duration? duration,
                CallParticipation? participation,
              }) async {
                updateCallCount++;
              },
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        handler.endCall(assumeRole: CallRole.caller);
        await handler.endCallWrite;

        final firstCount = updateCallCount;

        handler.endCall(assumeRole: CallRole.recipient);

        expect(updateCallCount, equals(firstCount));
      });

      test('callChatItemEnded flag prevents subsequent writes', () {
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              'msg-def',
          updateItem:
              (
                _, {
                required CallStatus status,
                Duration? duration,
                CallParticipation? participation,
              }) async {},
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        handler.endCall(assumeRole: CallRole.caller);

        expect(handler.callChatItemEnded, isTrue);

        handler.endCall(assumeRole: CallRole.recipient);

        expect(handler.endCallWrite, isNotNull);
      });
    });

    group('stream lifecycle: caller', () {
      test(
        'emit outgoing item on first session state with caller role',
        () async {
          final emitted = <CallChatItemId>[];
          final handler = CallChatItemHandler(
            onInitiator: (_) async {
              emitted.add('outgoing-item');
              return 'outgoing-id';
            },
            resolveItemId: ({required bool isCaller, String? callId}) async =>
                null,
            updateItem:
                (
                  _, {
                  required CallStatus status,
                  Duration? duration,
                  CallParticipation? participation,
                }) async {},
            isDisposed: () => false,
            logger: FakeAppLogger(),
          );

          final session = MockAudioVideoCallSession();
          handler.attach(session);

          // Emit first state with caller role
          await session.emitState(
            AudioVideoCallState(
              status: AudioVideoCallStatus.outgoingRinging,
              participants: [],
              ownRole: CallRole.caller,
              callId: 'test-call-id',
              callStartedAt: DateTime.now(),
            ),
          );

          await Future<void>.delayed(const Duration(milliseconds: 100));
          expect(emitted, equals(['outgoing-item']));
        },
      );

      test('caller in-progress write resolves the outgoing item, never the '
          'incoming one', () async {
        final updates = <(String, CallStatus)>[];
        final resolveCalls = <({bool isCaller, String? callId})>[];
        final handler = CallChatItemHandler(
          // Resolve the optimistic id late so the first in-progress write
          // must wait for it instead of resolving a stale item.
          onInitiator: (_) async {
            await Future<void>.delayed(const Duration(milliseconds: 60));
            return 'outgoing-id';
          },
          resolveItemId: ({required bool isCaller, String? callId}) async {
            resolveCalls.add((isCaller: isCaller, callId: callId));
            return isCaller ? 'outgoing-id' : 'incoming-id';
          },
          updateItem:
              (
                id, {
                required CallStatus status,
                Duration? duration,
                CallParticipation? participation,
              }) async {
                updates.add((id, status));
              },
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        final session = MockAudioVideoCallSession();
        final now = DateTime.now();
        handler.attach(session);

        // Peer already present so the first state triggers an in-progress
        // (ringing) write before onInitiator resolves.
        await session.emitState(
          AudioVideoCallState(
            status: AudioVideoCallStatus.outgoingRinging,
            participants: [FakeAudioVideoCallParticipant()],
            ownRole: CallRole.caller,
            callId: 'test-call-id',
            callStartedAt: now,
          ),
        );

        await session.emitState(
          AudioVideoCallState(
            status: AudioVideoCallStatus.declined,
            participants: [],
            ownRole: CallRole.caller,
            callId: 'test-call-id',
            callStartedAt: now,
          ),
        );

        await handler.endCallWrite;
        await Future<void>.delayed(const Duration(milliseconds: 120));

        expect(
          updates.map((u) => u.$1),
          everyElement(equals('outgoing-id')),
          reason:
              'The caller must never resolve the incoming item id; doing so '
              'updates a different message than the visible outgoing bubble, '
              'leaving it stuck on "Calling..."',
        );
        expect(
          resolveCalls,
          isEmpty,
          reason:
              'The caller resolves its item from the initiator write, never '
              'from direction-based lookup that could return a stale item',
        );
        expect(updates.last.$2, equals(CallStatus.declined));
      });

      test(
        'final status from the stream overrides pending in-progress write',
        () async {
          final updates = <(String, CallStatus)>[];
          final handler = CallChatItemHandler(
            onInitiator: (_) async => 'outgoing-id',
            resolveItemId: ({required bool isCaller, String? callId}) async =>
                'msg-123',
            updateItem:
                (
                  id, {
                  required CallStatus status,
                  Duration? duration,
                  CallParticipation? participation,
                }) async {
                  updates.add((id, status));
                },
            isDisposed: () => false,
            logger: FakeAppLogger(),
          );

          final session = MockAudioVideoCallSession();
          handler.attach(session);

          await session.emitState(
            AudioVideoCallState(
              status: AudioVideoCallStatus.outgoingRinging,
              participants: [],
              ownRole: CallRole.caller,
              callId: 'test-call-id',
              callStartedAt: DateTime.now(),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 50));

          await session.emitState(
            AudioVideoCallState(
              status: AudioVideoCallStatus.declined,
              participants: [],
              ownRole: CallRole.caller,
              callId: 'test-call-id',
              callStartedAt: DateTime.now(),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 100));

          expect(
            updates.last.$2,
            equals(CallStatus.declined),
            reason:
                'Final status must overwrite any pending in-progress '
                'write',
          );
        },
      );

      test(
        'slow in-progress write cannot overtake the terminal write',
        () async {
          final updates = <(String, CallStatus)>[];
          final handler = CallChatItemHandler(
            onInitiator: (_) async => 'outgoing-id',
            resolveItemId: ({required bool isCaller, String? callId}) async =>
                'msg-race',
            updateItem:
                (
                  id, {
                  required CallStatus status,
                  Duration? duration,
                  CallParticipation? participation,
                }) async {
                  if (status == CallStatus.ringing) {
                    await Future<void>.delayed(
                      const Duration(milliseconds: 80),
                    );
                  }
                  updates.add((id, status));
                },
            isDisposed: () => false,
            logger: FakeAppLogger(),
          );

          final session = MockAudioVideoCallSession();
          final now = DateTime.now();
          handler.attach(session);

          await session.emitState(
            AudioVideoCallState(
              status: AudioVideoCallStatus.outgoingRinging,
              participants: [FakeAudioVideoCallParticipant()],
              ownRole: CallRole.caller,
              callId: 'test-call-id',
              callStartedAt: now,
            ),
          );

          await session.emitState(
            AudioVideoCallState(
              status: AudioVideoCallStatus.declined,
              participants: [],
              ownRole: CallRole.caller,
              callId: 'test-call-id',
              callStartedAt: now,
            ),
          );

          await handler.endCallWrite;
          await Future<void>.delayed(const Duration(milliseconds: 150));

          expect(
            updates.last.$2,
            equals(CallStatus.declined),
            reason:
                'A slow in-progress ringing write must never land after the '
                'terminal declined write',
          );
        },
      );

      test('transitions calling -> ringing -> inProgress -> ended', () async {
        final updates = <(String, CallStatus)>[];
        final handler = CallChatItemHandler(
          onInitiator: (_) async => 'outgoing-id',
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              'msg-456',
          updateItem:
              (
                id, {
                required CallStatus status,
                Duration? duration,
                CallParticipation? participation,
              }) async {
                updates.add((id, status));
              },
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        final session = MockAudioVideoCallSession();
        final now = DateTime.now();
        handler.attach(session);

        // Caller emits calling (outgoingRinging before peer)
        await session.emitState(
          AudioVideoCallState(
            status: AudioVideoCallStatus.outgoingRinging,
            participants: [],
            ownRole: CallRole.caller,
            callId: 'test-call-id',
            callStartedAt: now,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Recipient picks up (peer joins); now it's ringing
        await session.emitState(
          AudioVideoCallState(
            status: AudioVideoCallStatus.outgoingRinging,
            participants: [FakeAudioVideoCallParticipant()],
            ownRole: CallRole.caller,
            callId: 'test-call-id',
            callStartedAt: now,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Recipient accepts (call connected)
        await session.emitState(
          AudioVideoCallState(
            status: AudioVideoCallStatus.connected,
            participants: [FakeAudioVideoCallParticipant()],
            ownRole: CallRole.caller,
            callId: 'test-call-id',
            callStartedAt: now,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        // Call ends
        await session.emitState(
          AudioVideoCallState(
            status: AudioVideoCallStatus.ended,
            participants: [FakeAudioVideoCallParticipant()],
            ownRole: CallRole.caller,
            callId: 'test-call-id',
            callStartedAt: now,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Verify that we wrote multiple transitions and final is ended
        expect(updates.length, greaterThanOrEqualTo(2));
        expect(updates.last.$2, equals(CallStatus.ended));
      });

      test('caller peer decline ends the already-emitted outgoing item as '
          'declined', () async {
        final updates = <(String, CallStatus)>[];
        final handler = CallChatItemHandler(
          onInitiator: (_) async => 'outgoing-id',
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              'fallback-id',
          updateItem:
              (
                id, {
                required CallStatus status,
                Duration? duration,
                CallParticipation? participation,
              }) async {
                updates.add((id, status));
              },
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        final session = MockAudioVideoCallSession();
        handler.attach(session);

        await session.emitState(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.outgoingRinging,
            ownRole: CallRole.caller,
            callId: 'test-call-id',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await session.emitState(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.declined,
            ownRole: CallRole.caller,
            callId: 'test-call-id',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(updates, isNotEmpty);
        expect(updates.last.$1, 'outgoing-id');
        expect(updates.last.$2, CallStatus.declined);
      });

      test(
        'does not resolve or write any item before ownRole is known',
        () async {
          final resolveCalls = <bool>[];
          final updates = <String>[];
          final handler = CallChatItemHandler(
            onInitiator: (_) async => 'outgoing-id',
            resolveItemId: ({required bool isCaller, String? callId}) async {
              resolveCalls.add(isCaller);
              return isCaller ? 'outgoing-id' : 'incoming-id';
            },
            updateItem:
                (
                  id, {
                  required CallStatus status,
                  Duration? duration,
                  CallParticipation? participation,
                }) async {
                  updates.add(id);
                },
            isDisposed: () => false,
            logger: FakeAppLogger(),
          );

          final session = MockAudioVideoCallSession();
          handler.attach(session);

          await session.emitState(
            const AudioVideoCallState(
              status: AudioVideoCallStatus.connecting,
              participants: [],
              callId: 'test-call-id',
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 50));

          expect(resolveCalls, isEmpty);
          expect(updates, isEmpty);

          await session.emitState(
            const AudioVideoCallState(
              status: AudioVideoCallStatus.outgoingRinging,
              participants: [],
              ownRole: CallRole.caller,
              callId: 'test-call-id',
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 50));

          expect(resolveCalls, everyElement(isTrue));
          expect(updates, everyElement(equals('outgoing-id')));
        },
      );

      test(
        'caller targets the freshly emitted item, never a stale outgoing id',
        () async {
          final updates = <String>[];
          final handler = CallChatItemHandler(
            onInitiator: (_) async {
              await Future<void>.delayed(const Duration(milliseconds: 40));
              return 'fresh-id';
            },
            resolveItemId: ({required bool isCaller, String? callId}) async =>
                'stale-id',
            updateItem:
                (
                  id, {
                  required CallStatus status,
                  Duration? duration,
                  CallParticipation? participation,
                }) async {
                  updates.add(id);
                },
            isDisposed: () => false,
            logger: FakeAppLogger(),
          );

          final session = MockAudioVideoCallSession();
          handler.attach(session);

          await session.emitState(
            const AudioVideoCallState(
              status: AudioVideoCallStatus.outgoingRinging,
              participants: [],
              ownRole: CallRole.caller,
              callId: 'test-call-id',
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 100));

          expect(updates, isNotEmpty);
          expect(updates, everyElement(equals('fresh-id')));
        },
      );
    });

    group('group call participation', () {
      AudioVideoCallParticipant self(String did) => AudioVideoCallParticipant(
        participantId: 'self',
        did: did,
        isSelf: true,
      );

      AudioVideoCallParticipant peer(String id) =>
          AudioVideoCallParticipant(participantId: id, did: 'did:$id');

      test('leaves participation null for a 1:1 call', () async {
        final captured = <CallParticipation?>[];
        final handler = CallChatItemHandler(
          onInitiator: (_) async => 'msg-1',
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              'msg-1',
          updateItem:
              (
                _, {
                required CallStatus status,
                Duration? duration,
                CallParticipation? participation,
              }) async {
                captured.add(participation);
              },
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        final session = MockAudioVideoCallSession();
        final now = DateTime.now();
        handler.attach(session);

        await session.emitState(
          AudioVideoCallState(
            status: AudioVideoCallStatus.connected,
            participants: [self('did:me'), peer('p1')],
            ownRole: CallRole.caller,
            callId: 'c',
            callStartedAt: now,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(captured, isNotEmpty);
        expect(captured, everyElement(isNull));
      });

      test('counts distinct peers and latches self join', () async {
        final captured = <CallParticipation?>[];
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              'g-1',
          updateItem:
              (
                _, {
                required CallStatus status,
                Duration? duration,
                CallParticipation? participation,
              }) async {
                captured.add(participation);
              },
          isDisposed: () => false,
          logger: FakeAppLogger(),
          isGroupCall: true,
        );

        final session = MockAudioVideoCallSession();
        final now = DateTime.now();
        handler.attach(session);

        await session.emitState(
          AudioVideoCallState(
            status: AudioVideoCallStatus.connected,
            participants: [self('did:me'), peer('p1')],
            ownRole: CallRole.recipient,
            callId: 'c',
            callStartedAt: now,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        await session.emitState(
          AudioVideoCallState(
            status: AudioVideoCallStatus.active,
            participants: [self('did:me'), peer('p1'), peer('p2')],
            ownRole: CallRole.recipient,
            callId: 'c',
            callStartedAt: now,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));

        handler.endCall(assumeRole: CallRole.recipient);
        await handler.endCallWrite;

        final last = captured.whereType<CallParticipation>().last;
        expect(last.participantCount, 2);
        expect(last.didSelfJoin, isTrue);
        expect(last.selfLeftBeforeEnd, isTrue);
        expect(last.initiatorDid, isNull);
      });

      test('marks self left before end when hanging up with a peer '
          'present', () async {
        final captured = <CallParticipation?>[];
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller, String? callId}) async =>
              'g-2',
          updateItem:
              (
                _, {
                required CallStatus status,
                Duration? duration,
                CallParticipation? participation,
              }) async {
                captured.add(participation);
              },
          isDisposed: () => false,
          logger: FakeAppLogger(),
          isGroupCall: true,
        );

        final session = MockAudioVideoCallSession();
        final now = DateTime.now();
        handler.attach(session);

        await session.emitState(
          AudioVideoCallState(
            status: AudioVideoCallStatus.active,
            participants: [self('did:me'), peer('p1')],
            ownRole: CallRole.recipient,
            callId: 'c',
            callStartedAt: now,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));

        handler.endCall(assumeRole: CallRole.recipient);
        await handler.endCallWrite;

        final last = captured.whereType<CallParticipation>().last;
        expect(last.selfLeftBeforeEnd, isTrue);
      });

      test(
        'records initiator did only when this device is the caller',
        () async {
          final captured = <CallParticipation?>[];
          final handler = CallChatItemHandler(
            onInitiator: (_) async => 'g-3',
            resolveItemId: ({required bool isCaller, String? callId}) async =>
                'g-3',
            updateItem:
                (
                  _, {
                  required CallStatus status,
                  Duration? duration,
                  CallParticipation? participation,
                }) async {
                  captured.add(participation);
                },
            isDisposed: () => false,
            logger: FakeAppLogger(),
            isGroupCall: true,
          );

          final session = MockAudioVideoCallSession();
          final now = DateTime.now();
          handler.attach(session);

          await session.emitState(
            AudioVideoCallState(
              status: AudioVideoCallStatus.active,
              participants: [self('did:caller'), peer('p1')],
              ownRole: CallRole.caller,
              callId: 'c',
              callStartedAt: now,
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 100));

          final last = captured.whereType<CallParticipation>().last;
          expect(last.initiatorDid, 'did:caller');
        },
      );
    });
  });
}
