import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/call_ui_rules.dart';

AudioVideoCallParticipant _selfParticipant() => const AudioVideoCallParticipant(
  participantId: 'self',
  isSelf: true,
  hasVideo: false,
  hasAudio: true,
  isSpeaking: false,
);

AudioVideoCallParticipant _peerParticipant([String id = 'peer']) =>
    AudioVideoCallParticipant(
      participantId: id,
      isSelf: false,
      hasVideo: true,
      hasAudio: true,
      isSpeaking: false,
    );

void main() {
  group('isLiveCallStatus', () {
    test('returns true for waitingForKeys', () {
      expect(isLiveCallStatus(AudioVideoCallStatus.waitingForKeys), isTrue);
    });

    test('returns true for connected', () {
      expect(isLiveCallStatus(AudioVideoCallStatus.connected), isTrue);
    });

    test('returns true for active', () {
      expect(isLiveCallStatus(AudioVideoCallStatus.active), isTrue);
    });

    test('returns false for idle', () {
      expect(isLiveCallStatus(AudioVideoCallStatus.idle), isFalse);
    });

    test('returns false for connecting', () {
      expect(isLiveCallStatus(AudioVideoCallStatus.connecting), isFalse);
    });

    test('returns false for outgoingRinging', () {
      expect(isLiveCallStatus(AudioVideoCallStatus.outgoingRinging), isFalse);
    });

    test('returns false for final statuses', () {
      expect(isLiveCallStatus(AudioVideoCallStatus.ended), isFalse);
      expect(isLiveCallStatus(AudioVideoCallStatus.disconnected), isFalse);
      expect(isLiveCallStatus(AudioVideoCallStatus.error), isFalse);
      expect(isLiveCallStatus(AudioVideoCallStatus.missed), isFalse);
      expect(isLiveCallStatus(AudioVideoCallStatus.declined), isFalse);
    });
  });

  group('isTerminalCallStatus', () {
    test('returns true for ended', () {
      expect(isEndedCallStatus(AudioVideoCallStatus.ended), isTrue);
    });

    test('returns true for disconnected', () {
      expect(isEndedCallStatus(AudioVideoCallStatus.disconnected), isTrue);
    });

    test('returns true for error', () {
      expect(isEndedCallStatus(AudioVideoCallStatus.error), isTrue);
    });

    test('returns true for missed', () {
      expect(isEndedCallStatus(AudioVideoCallStatus.missed), isTrue);
    });

    test('returns true for declined', () {
      expect(isEndedCallStatus(AudioVideoCallStatus.declined), isTrue);
    });

    test('returns false for non-final statuses', () {
      expect(isEndedCallStatus(AudioVideoCallStatus.idle), isFalse);
      expect(isEndedCallStatus(AudioVideoCallStatus.connecting), isFalse);
      expect(isEndedCallStatus(AudioVideoCallStatus.outgoingRinging), isFalse);
      expect(isEndedCallStatus(AudioVideoCallStatus.waitingForKeys), isFalse);
      expect(isEndedCallStatus(AudioVideoCallStatus.connected), isFalse);
      expect(isEndedCallStatus(AudioVideoCallStatus.active), isFalse);
    });
  });

  group('hasPeerParticipant', () {
    test('returns false for empty list', () {
      expect(hasPeerParticipant([]), isFalse);
    });

    test('returns false when only self participant present', () {
      expect(
        hasPeerParticipant([
          const AudioVideoCallParticipant(
            participantId: 'self',
            isSelf: true,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
        ]),
        isFalse,
      );
    });

    test('returns true when peer participant present', () {
      expect(
        hasPeerParticipant([
          const AudioVideoCallParticipant(
            participantId: 'self',
            isSelf: true,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          const AudioVideoCallParticipant(
            participantId: 'peer-1',
            isSelf: false,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
        ]),
        isTrue,
      );
    });

    test('returns true with multiple peers', () {
      expect(
        hasPeerParticipant([
          const AudioVideoCallParticipant(
            participantId: 'self',
            isSelf: true,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          const AudioVideoCallParticipant(
            participantId: 'peer-1',
            isSelf: false,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
          const AudioVideoCallParticipant(
            participantId: 'peer-2',
            isSelf: false,
            hasVideo: true,
            hasAudio: false,
            isSpeaking: false,
          ),
        ]),
        isTrue,
      );
    });
  });

  group('computeHasHadPeer', () {
    test('returns false when no previous peer and status not connected', () {
      expect(
        computeHasHadPeer(
          previous: false,
          status: AudioVideoCallStatus.connecting,
          participants: [],
        ),
        isFalse,
      );
    });

    test('returns true when previous was true', () {
      expect(
        computeHasHadPeer(
          previous: true,
          status: AudioVideoCallStatus.connecting,
          participants: [_selfParticipant()],
        ),
        isTrue,
      );
    });

    test(
      'returns false when status is connected but no peer participant present',
      () {
        expect(
          computeHasHadPeer(
            previous: false,
            status: AudioVideoCallStatus.connected,
            participants: [_selfParticipant()],
          ),
          isFalse,
        );
      },
    );

    test('returns true when status is connected with peer participant', () {
      expect(
        computeHasHadPeer(
          previous: false,
          status: AudioVideoCallStatus.connected,
          participants: [_selfParticipant(), _peerParticipant()],
        ),
        isTrue,
      );
    });

    test(
      'returns false when status is active but no peer participant present',
      () {
        expect(
          computeHasHadPeer(
            previous: false,
            status: AudioVideoCallStatus.active,
            participants: [_selfParticipant()],
          ),
          isFalse,
        );
      },
    );

    test('returns true when status is active with peer participant', () {
      expect(
        computeHasHadPeer(
          previous: false,
          status: AudioVideoCallStatus.active,
          participants: [_selfParticipant(), _peerParticipant()],
        ),
        isTrue,
      );
    });

    test(
      'returns false when status not connected even with peer participant',
      () {
        expect(
          computeHasHadPeer(
            previous: false,
            status: AudioVideoCallStatus.outgoingRinging,
            participants: [_selfParticipant(), _peerParticipant()],
          ),
          isFalse,
        );
      },
    );

    test('stays true once true even when peer leaves', () {
      var hasHadPeer = computeHasHadPeer(
        previous: false,
        status: AudioVideoCallStatus.active,
        participants: [_selfParticipant(), _peerParticipant()],
      );
      expect(hasHadPeer, isTrue);

      hasHadPeer = computeHasHadPeer(
        previous: hasHadPeer,
        status: AudioVideoCallStatus.active,
        participants: [_selfParticipant()],
      );
      expect(hasHadPeer, isTrue);
    });
  });

  group('resolveCallUiPhase', () {
    test('returns ended for final statuses regardless of hasHadPeer', () {
      expect(
        resolveCallUiPhase(
          status: AudioVideoCallStatus.ended,
          hasHadPeer: false,
        ),
        CallUiPhase.ended,
      );
      expect(
        resolveCallUiPhase(
          status: AudioVideoCallStatus.missed,
          hasHadPeer: true,
        ),
        CallUiPhase.ended,
      );
    });

    test('returns inCall when hasHadPeer is true', () {
      expect(
        resolveCallUiPhase(
          status: AudioVideoCallStatus.active,
          hasHadPeer: true,
        ),
        CallUiPhase.inCall,
      );
      expect(
        resolveCallUiPhase(
          status: AudioVideoCallStatus.waitingForKeys,
          hasHadPeer: true,
        ),
        CallUiPhase.inCall,
      );
    });

    test('returns ringing for outgoingRinging when no peer', () {
      expect(
        resolveCallUiPhase(
          status: AudioVideoCallStatus.outgoingRinging,
          hasHadPeer: false,
        ),
        CallUiPhase.ringing,
      );
    });

    test('returns calling for connecting or early statuses', () {
      expect(
        resolveCallUiPhase(
          status: AudioVideoCallStatus.connecting,
          hasHadPeer: false,
        ),
        CallUiPhase.calling,
      );
      expect(
        resolveCallUiPhase(
          status: AudioVideoCallStatus.idle,
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

    test('returns callEnded for ended status when hasHadPeer is true', () {
      expect(
        resolveCallEndState(AudioVideoCallStatus.ended, hasHadPeer: true),
        CallEndState.callEnded,
      );
    });

    test(
      'returns callEnded for disconnected status when hasHadPeer is true',
      () {
        expect(
          resolveCallEndState(
            AudioVideoCallStatus.disconnected,
            hasHadPeer: true,
          ),
          CallEndState.callEnded,
        );
      },
    );

    test('returns null for ended status without hasHadPeer', () {
      expect(resolveCallEndState(AudioVideoCallStatus.ended), isNull);
    });

    test('returns null for disconnected status without hasHadPeer', () {
      expect(resolveCallEndState(AudioVideoCallStatus.disconnected), isNull);
    });

    test('returns null for error status', () {
      expect(resolveCallEndState(AudioVideoCallStatus.error), isNull);
    });

    test('returns null for non-final statuses', () {
      expect(resolveCallEndState(AudioVideoCallStatus.idle), isNull);
      expect(resolveCallEndState(AudioVideoCallStatus.active), isNull);
    });
  });

  group('isEndedWithNoScreen', () {
    test('is true for a call cancelled before the peer ever joined', () {
      expect(
        isEndedWithNoScreen(
          phase: CallUiPhase.ended,
          endState: null,
          peerIsCallingBack: false,
          isJoinFailure: false,
        ),
        isTrue,
      );
    });

    test('is false when not in the ended phase', () {
      expect(
        isEndedWithNoScreen(
          phase: CallUiPhase.calling,
          endState: null,
          peerIsCallingBack: false,
          isJoinFailure: false,
        ),
        isFalse,
      );
    });

    test('is false when an end-state screen should show', () {
      expect(
        isEndedWithNoScreen(
          phase: CallUiPhase.ended,
          endState: CallEndState.missedCall,
          peerIsCallingBack: false,
          isJoinFailure: false,
        ),
        isFalse,
      );
    });

    test('is false when the peer is calling back', () {
      expect(
        isEndedWithNoScreen(
          phase: CallUiPhase.ended,
          endState: null,
          peerIsCallingBack: true,
          isJoinFailure: false,
        ),
        isFalse,
      );
    });

    test('is false for a join failure', () {
      expect(
        isEndedWithNoScreen(
          phase: CallUiPhase.ended,
          endState: null,
          peerIsCallingBack: false,
          isJoinFailure: true,
        ),
        isFalse,
      );
    });
  });
}
