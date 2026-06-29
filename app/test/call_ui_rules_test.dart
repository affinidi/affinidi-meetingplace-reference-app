import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallParticipant, AudioVideoCallStatus;
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/call_ui_rules.dart';

const _selfParticipant = AudioVideoCallParticipant(
  participantId: 'local',
  isSelf: true,
);
const _peerParticipant = AudioVideoCallParticipant(participantId: 'remote-1');

void main() {
  group('isLiveCallStatus', () {
    test('is true for waitingForKeys, connected and active', () {
      expect(isLiveCallStatus(AudioVideoCallStatus.waitingForKeys), isTrue);
      expect(isLiveCallStatus(AudioVideoCallStatus.connected), isTrue);
      expect(isLiveCallStatus(AudioVideoCallStatus.active), isTrue);
    });

    test('is false before the call is live', () {
      expect(isLiveCallStatus(AudioVideoCallStatus.idle), isFalse);
      expect(isLiveCallStatus(AudioVideoCallStatus.connecting), isFalse);
      expect(isLiveCallStatus(AudioVideoCallStatus.outgoingRinging), isFalse);
    });
  });

  group('isTerminalCallStatus', () {
    test('is true for all end states', () {
      for (final s in [
        AudioVideoCallStatus.ended,
        AudioVideoCallStatus.disconnected,
        AudioVideoCallStatus.error,
        AudioVideoCallStatus.missed,
        AudioVideoCallStatus.declined,
      ]) {
        expect(isEndedCallStatus(s), isTrue, reason: '$s');
      }
    });

    test('is false for live states', () {
      expect(isEndedCallStatus(AudioVideoCallStatus.active), isFalse);
    });
  });

  group('computeHasHadPeer', () {
    test(
      'latches true when another participant is present during a live status',
      () {
        final result = computeHasHadPeer(
          previous: false,
          participants: const [_selfParticipant, _peerParticipant],
          status: AudioVideoCallStatus.waitingForKeys,
        );
        expect(result, isTrue);
      },
    );

    test('ignores a participant that appears before the call is live', () {
      final result = computeHasHadPeer(
        previous: false,
        participants: const [_selfParticipant, _peerParticipant],
        status: AudioVideoCallStatus.connecting,
      );
      expect(result, isFalse);
    });

    test('ignores a participant list with no other participant', () {
      final result = computeHasHadPeer(
        previous: false,
        participants: const [_selfParticipant],
        status: AudioVideoCallStatus.active,
      );
      expect(result, isFalse);
    });

    test('never un-latches once true', () {
      final result = computeHasHadPeer(
        previous: true,
        participants: const [_selfParticipant],
        status: AudioVideoCallStatus.active,
      );
      expect(result, isTrue);
    });
  });

  group('resolveCallUiPhase', () {
    test('is ended for terminal statuses regardless of latch', () {
      expect(
        resolveCallUiPhase(
          status: AudioVideoCallStatus.ended,
          hasHadPeer: true,
        ),
        CallUiPhase.ended,
      );
    });

    test('is inCall once a remote has joined', () {
      expect(
        resolveCallUiPhase(
          status: AudioVideoCallStatus.waitingForKeys,
          hasHadPeer: true,
        ),
        CallUiPhase.inCall,
      );
    });

    test('is ringing while outgoingRinging and no remote yet', () {
      expect(
        resolveCallUiPhase(
          status: AudioVideoCallStatus.outgoingRinging,
          hasHadPeer: false,
        ),
        CallUiPhase.ringing,
      );
    });

    test('is calling while connecting and no remote yet', () {
      expect(
        resolveCallUiPhase(
          status: AudioVideoCallStatus.connecting,
          hasHadPeer: false,
        ),
        CallUiPhase.calling,
      );
    });
  });

  group('resolveCallEndState', () {
    test('returns missedCall for missed status', () {
      expect(
        resolveCallEndState(AudioVideoCallStatus.missed),
        CallEndState.missedCall,
      );
    });

    test('returns declinedCall for declined status', () {
      expect(
        resolveCallEndState(AudioVideoCallStatus.declined),
        CallEndState.declinedCall,
      );
    });

    test('returns null for ended (normal end)', () {
      expect(resolveCallEndState(AudioVideoCallStatus.ended), isNull);
    });

    test('returns null for error', () {
      expect(resolveCallEndState(AudioVideoCallStatus.error), isNull);
    });

    test('returns null for disconnected', () {
      expect(resolveCallEndState(AudioVideoCallStatus.disconnected), isNull);
    });
  });
}
