import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart';
import 'package:mpx_flutter_reference_app/infrastructure/loggers/app_logger/app_logger.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_screen_state.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/audio_video_call_state_update.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/handlers/call_session_handler.dart';

class _FakeCallSession extends Fake implements AudioVideoCallSession {
  final _controller = StreamController<AudioVideoCallState>.broadcast();

  void emit(AudioVideoCallState s) => _controller.add(s);

  @override
  Stream<AudioVideoCallState> get state => _controller.stream;
}

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

  late _FakeCallSession session;
  late List<AudioVideoCallStateUpdate> updates;
  late CallSessionHandler handler;

  setUp(() {
    session = _FakeCallSession();
    updates = [];
    handler = CallSessionHandler(
      logger: AppLogger.instance,
      logKey: 'CallSessionHandlerTest',
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

      final event = updates.last.participantEvent;
      expect(event, isNotNull);
      expect(event!.type, CallParticipantChangeType.joined);
      expect(event.count, 1);
    });

    test('emits a left event when a remote disappears mid-call', () async {
      handler.attach(session);

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
      session.emit(
        AudioVideoCallState(
          status: AudioVideoCallStatus.active,
          participants: [_selfParticipant(), _peerParticipant('a')],
        ),
      );
      await pumpEventQueue();

      final event = updates.last.participantEvent;
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
}
