import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_state.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_state_update.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/handlers/call_session_handler.dart';

import 'fakes/fake_audio_video_call_session.dart';

AudioVideoCallParticipant _selfParticipant() =>
    const AudioVideoCallParticipant(participantId: 'local', isSelf: true);

AudioVideoCallParticipant _peerParticipant(String id) =>
    AudioVideoCallParticipant(participantId: id);

void main() {
  setUpAll(() {
    AppLogger.initialize(
      File('${Directory.systemTemp.path}/call_session_handler_test.log'),
    );
  });

  late FakeAudioVideoCallSession session;
  late List<AudioVideoCallStateUpdate> updates;
  late CallSessionHandler handler;

  setUp(() {
    session = FakeAudioVideoCallSession();
    updates = [];
    handler = CallSessionHandler(
      logger: AppLogger.instance,
      onUpdate: updates.add,
    );
  });

  tearDown(() => handler.dispose());

  group('justGotFirstOther', () {
    test('is false while only the own participant is present', () async {
      handler.attach(session);

      session.emit(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [_selfParticipant()],
        ),
      );
      await pumpEventQueue();

      expect(updates.single.peerJustJoined, isFalse);
    });

    test('fires exactly once on the first other participant join', () async {
      handler.attach(session);

      session.emit(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [_selfParticipant()],
        ),
      );
      session.emit(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [_selfParticipant(), _peerParticipant('a')],
        ),
      );
      session.emit(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [
            _selfParticipant(),
            _peerParticipant('a'),
            _peerParticipant('b'),
          ],
        ),
      );
      await pumpEventQueue();

      final flagged = updates
          .where((u) => u.peerJustJoined)
          .toList(growable: false);
      expect(flagged, hasLength(1));
    });
  });

  group('participant change events', () {
    test('emits a joined event when a new remote appears mid-call', () async {
      handler.attach(session);

      await session.emitParticipantEvent(
        CallParticipantEvent(
          type: CallParticipantEventType.joined,
          participant: _peerParticipant('b'),
        ),
      );
      await pumpEventQueue();

      final event = updates.single.participantEvent;
      expect(event, isNotNull);
      expect(event!.type, CallParticipantChangeType.joined);
      expect(event.count, 1);
    });

    test('emits a left event when a remote disappears mid-call', () async {
      handler.attach(session);

      await session.emitParticipantEvent(
        CallParticipantEvent(
          type: CallParticipantEventType.left,
          participant: _peerParticipant('a'),
        ),
      );
      await pumpEventQueue();

      final event = updates.single.participantEvent;
      expect(event, isNotNull);
      expect(event!.type, CallParticipantChangeType.left);
      expect(event.count, 1);
    });

    test(
      'does not emit participant events before the call is active',
      () async {
        handler.attach(session);

        session.emit(
          AudioVideoCallState(
            status: AudioVideoCallStatus.outgoingRinging,
            participants: [_selfParticipant()],
          ),
        );
        await pumpEventQueue();

        expect(updates.single.participantEvent, isNull);
      },
    );
  });

  group('disposal', () {
    test('ignores session emissions after dispose', () async {
      handler.attach(session);
      handler.dispose();

      session.emit(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [_selfParticipant(), _peerParticipant('a')],
        ),
      );
      await pumpEventQueue();

      expect(updates, isEmpty);
    });

    test('double dispose does not throw', () {
      handler.attach(session);
      handler.dispose();
      expect(handler.dispose, returnsNormally);
    });
  });

  group('ownRole passthrough', () {
    test('emits ownRole from session state', () async {
      handler.attach(session);

      session.emit(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          ownRole: CallRole.caller,
          participants: [_selfParticipant()],
        ),
      );
      await pumpEventQueue();

      expect(updates.single.ownRole, CallRole.caller);
    });

    test('emits null ownRole when session has no role yet', () async {
      handler.attach(session);

      session.emit(
        AudioVideoCallState(
          status: AudioVideoCallStatus.connecting,
          participants: [_selfParticipant()],
        ),
      );
      await pumpEventQueue();

      expect(updates.single.ownRole, isNull);
    });
  });

  group('media state from self participant', () {
    test('isMicEnabled is null until mic has been enabled once', () async {
      handler.attach(session);

      session.emit(
        const AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [
            AudioVideoCallParticipant(
              participantId: 'local',
              isSelf: true,
              hasAudio: false,
            ),
          ],
        ),
      );
      await pumpEventQueue();

      expect(updates.single.isMicEnabled, isNull);
    });

    test(
      'isMicEnabled is reported after mic has been on at least once',
      () async {
        handler.attach(session);

        session.emit(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.active,
            participants: [
              AudioVideoCallParticipant(
                participantId: 'local',
                isSelf: true,
                hasAudio: true,
              ),
            ],
          ),
        );
        session.emit(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.active,
            participants: [
              AudioVideoCallParticipant(
                participantId: 'local',
                isSelf: true,
                hasAudio: false,
              ),
            ],
          ),
        );
        await pumpEventQueue();

        expect(updates.last.isMicEnabled, isFalse);
      },
    );

    test(
      'isCameraEnabled is null until camera has been enabled once',
      () async {
        handler.attach(session);

        session.emit(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.active,
            participants: [
              AudioVideoCallParticipant(
                participantId: 'local',
                isSelf: true,
                hasVideo: false,
              ),
            ],
          ),
        );
        await pumpEventQueue();

        expect(updates.single.isCameraEnabled, isNull);
      },
    );

    test(
      'isCameraEnabled is reported after camera has been on at least once',
      () async {
        handler.attach(session);

        session.emit(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.active,
            participants: [
              AudioVideoCallParticipant(
                participantId: 'local',
                isSelf: true,
                hasVideo: true,
              ),
            ],
          ),
        );
        session.emit(
          const AudioVideoCallState(
            status: AudioVideoCallStatus.active,
            participants: [
              AudioVideoCallParticipant(
                participantId: 'local',
                isSelf: true,
                hasVideo: false,
              ),
            ],
          ),
        );
        await pumpEventQueue();

        expect(updates.last.isCameraEnabled, isFalse);
      },
    );
  });

  group('hasHadPeer latch', () {
    test('is false when no remote has ever joined', () async {
      handler.attach(session);

      session.emit(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [_selfParticipant()],
        ),
      );
      await pumpEventQueue();

      expect(updates.single.hasHadPeer, isFalse);
    });

    test(
      'latches true once a remote joins and stays true after they leave',
      () async {
        handler.attach(session);

        session.emit(
          AudioVideoCallState(
            status: AudioVideoCallStatus.active,
            participants: [_selfParticipant(), _peerParticipant('a')],
          ),
        );
        session.emit(
          AudioVideoCallState(
            status: AudioVideoCallStatus.active,
            participants: [_selfParticipant()],
          ),
        );
        await pumpEventQueue();

        expect(updates.last.hasHadPeer, isTrue);
      },
    );
  });

  group('re-attach', () {
    test('cancels prior subscription when attached to a new session', () async {
      handler.attach(session);

      final session2 = FakeAudioVideoCallSession();
      handler.attach(session2);

      session.emit(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [_selfParticipant(), _peerParticipant('a')],
        ),
      );
      await pumpEventQueue();

      expect(updates, isEmpty);
    });
  });

  group('participantEvents forwarding', () {
    test('forwards a joined event as a participantEvent update', () async {
      handler.attach(session);

      await session.emitParticipantEvent(
        CallParticipantEvent(
          type: CallParticipantEventType.joined,
          participant: _peerParticipant('p1'),
        ),
      );
      await pumpEventQueue();

      expect(updates, hasLength(1));
      expect(
        updates.single.participantEvent?.type,
        CallParticipantChangeType.joined,
      );
    });

    test('forwards a left event as a participantEvent update', () async {
      handler.attach(session);

      await session.emitParticipantEvent(
        CallParticipantEvent(
          type: CallParticipantEventType.left,
          participant: _peerParticipant('p1'),
        ),
      );
      await pumpEventQueue();

      expect(updates, hasLength(1));
      expect(
        updates.single.participantEvent?.type,
        CallParticipantChangeType.left,
      );
    });

    test('does not forward participant events after dispose', () async {
      handler.attach(session);
      handler.dispose();

      await session.emitParticipantEvent(
        CallParticipantEvent(
          type: CallParticipantEventType.left,
          participant: _peerParticipant('p1'),
        ),
      );
      await pumpEventQueue();

      expect(updates, isEmpty);
    });
  });
}
