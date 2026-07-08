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
          resolveItemId: ({required bool isCaller}) async => null,
          updateItem:
              (_, {required CallStatus status, Duration? duration}) async {},
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        expect(handler.endCallWrite, isNull);
      });

      test('returns in-flight Future after endCall is called', () async {
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller}) async => 'msg-123',
          updateItem:
              (_, {required CallStatus status, Duration? duration}) async {},
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        handler.endCall(assumeRole: CallRole.caller);

        expect(handler.endCallWrite, isNotNull);
        expect(handler.endCallWrite, isA<Future<void>>());
      });

      test('captures the same Future on repeated access', () async {
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller}) async => 'msg-456',
          updateItem:
              (_, {required CallStatus status, Duration? duration}) async {},
          isDisposed: () => false,
          logger: FakeAppLogger(),
        );

        handler.endCall(assumeRole: CallRole.recipient);

        expect(handler.endCallWrite, same(handler.endCallWrite));
      });

      test('allows callers to await the write before cleanup', () async {
        var updateCallCount = 0;
        final handler = CallChatItemHandler(
          resolveItemId: ({required bool isCaller}) async => 'msg-789',
          updateItem:
              (_, {required CallStatus status, Duration? duration}) async {
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
          resolveItemId: ({required bool isCaller}) async => 'msg-abc',
          updateItem:
              (_, {required CallStatus status, Duration? duration}) async {
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
          resolveItemId: ({required bool isCaller}) async => 'msg-def',
          updateItem:
              (_, {required CallStatus status, Duration? duration}) async {},
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
            onInitiator: () async {
              emitted.add('outgoing-item');
              return 'outgoing-id';
            },
            resolveItemId: ({required bool isCaller}) async => null,
            updateItem:
                (_, {required CallStatus status, Duration? duration}) async {},
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
              callStartedAt: DateTime.now(),
            ),
          );

          await Future<void>.delayed(const Duration(milliseconds: 100));
          expect(emitted, equals(['outgoing-item']));
        },
      );

      test(
        'terminal status from the stream overrides pending in-progress write',
        () async {
          final updates = <(String, CallStatus)>[];
          final handler = CallChatItemHandler(
            onInitiator: () async => 'outgoing-id',
            resolveItemId: ({required bool isCaller}) async => 'msg-123',
            updateItem:
                (id, {required CallStatus status, Duration? duration}) async {
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
              callStartedAt: DateTime.now(),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 50));

          await session.emitState(
            AudioVideoCallState(
              status: AudioVideoCallStatus.declined,
              participants: [],
              ownRole: CallRole.caller,
              callStartedAt: DateTime.now(),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 100));

          expect(
            updates.last.$2,
            equals(CallStatus.declined),
            reason:
                'Terminal status must overwrite any pending in-progress '
                'write',
          );
        },
      );

      test('transitions calling -> ringing -> inProgress -> ended', () async {
        final updates = <(String, CallStatus)>[];
        final handler = CallChatItemHandler(
          onInitiator: () async => 'outgoing-id',
          resolveItemId: ({required bool isCaller}) async => 'msg-456',
          updateItem:
              (id, {required CallStatus status, Duration? duration}) async {
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
            callStartedAt: now,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));

        // Verify that we wrote multiple transitions and final is ended
        expect(updates.length, greaterThanOrEqualTo(2));
        expect(updates.last.$2, equals(CallStatus.ended));
      });
    });
  });
}
