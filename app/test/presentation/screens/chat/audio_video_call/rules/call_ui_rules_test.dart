import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/call_ui_rules.dart';

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

    test('returns false for terminal statuses', () {
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

    test('returns false for non-terminal statuses', () {
      expect(isEndedCallStatus(AudioVideoCallStatus.idle), isFalse);
      expect(isEndedCallStatus(AudioVideoCallStatus.connecting), isFalse);
      expect(isEndedCallStatus(AudioVideoCallStatus.outgoingRinging), isFalse);
      expect(isEndedCallStatus(AudioVideoCallStatus.waitingForKeys), isFalse);
      expect(isEndedCallStatus(AudioVideoCallStatus.connected), isFalse);
      expect(isEndedCallStatus(AudioVideoCallStatus.active), isFalse);
    });
  });

  group('hasRemoteParticipant', () {
    test('returns false for empty list', () {
      expect(hasRemoteParticipant([]), isFalse);
    });

    test('returns false when only local participant present', () {
      expect(
        hasRemoteParticipant([
          const AudioVideoCallParticipant(
            participantId: 'local',
            isSelf: true,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
        ]),
        isFalse,
      );
    });

    test('returns true when remote participant present', () {
      expect(
        hasRemoteParticipant([
          const AudioVideoCallParticipant(
            participantId: 'local',
            isSelf: true,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          const AudioVideoCallParticipant(
            participantId: 'remote-1',
            isSelf: false,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
        ]),
        isTrue,
      );
    });

    test('returns true with multiple remotes', () {
      expect(
        hasRemoteParticipant([
          const AudioVideoCallParticipant(
            participantId: 'local',
            isSelf: true,
            hasVideo: false,
            hasAudio: true,
            isSpeaking: false,
          ),
          const AudioVideoCallParticipant(
            participantId: 'remote-1',
            isSelf: false,
            hasVideo: true,
            hasAudio: true,
            isSpeaking: false,
          ),
          const AudioVideoCallParticipant(
            participantId: 'remote-2',
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
        ),
        isFalse,
      );
    });

    test('returns true when previous was true', () {
      expect(
        computeHasHadPeer(
          previous: true,
          status: AudioVideoCallStatus.connecting,
        ),
        isTrue,
      );
    });

    test('returns true when status is connected for first time', () {
      expect(
        computeHasHadPeer(
          previous: false,
          status: AudioVideoCallStatus.connected,
        ),
        isTrue,
      );
    });

    test('returns true when status is active for first time', () {
      expect(
        computeHasHadPeer(previous: false, status: AudioVideoCallStatus.active),
        isTrue,
      );
    });

    test(
      'returns false when remote participant present but status not connected',
      () {
        expect(
          computeHasHadPeer(
            previous: false,
            status: AudioVideoCallStatus.outgoingRinging,
          ),
          isFalse,
        );
      },
    );

    test('stays true once true even when status drops back', () {
      var hasHadPeer = computeHasHadPeer(
        previous: false,
        status: AudioVideoCallStatus.active,
      );
      expect(hasHadPeer, isTrue);

      hasHadPeer = computeHasHadPeer(
        previous: hasHadPeer,
        status: AudioVideoCallStatus.connecting,
      );
      expect(hasHadPeer, isTrue);
    });
  });

  group('resolveCallUiPhase', () {
    test('returns ended for terminal statuses regardless of hasHadPeer', () {
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

    test('returns null for non-terminal statuses', () {
      expect(resolveCallEndState(AudioVideoCallStatus.idle), isNull);
      expect(resolveCallEndState(AudioVideoCallStatus.active), isNull);
    });
  });

  group('shouldAutoEndCallForPeer', () {
    final peer = const AudioVideoCallParticipant(participantId: 'peer-1');
    final self = const AudioVideoCallParticipant(
      participantId: 'self-1',
      isSelf: true,
    );

    test('returns true for 1-on-1 when peer leaves during active call', () {
      expect(
        shouldAutoEndCallForPeer(
          isGroupContact: false,
          hasHadPeer: true,
          participants: [self],
          status: AudioVideoCallStatus.active,
        ),
        isTrue,
      );
    });

    test('returns false for group contact when peer leaves', () {
      expect(
        shouldAutoEndCallForPeer(
          isGroupContact: true,
          hasHadPeer: true,
          participants: [self],
          status: AudioVideoCallStatus.active,
        ),
        isFalse,
      );
    });

    test('returns false when hasHadPeer is false', () {
      expect(
        shouldAutoEndCallForPeer(
          isGroupContact: false,
          hasHadPeer: false,
          participants: [self],
          status: AudioVideoCallStatus.active,
        ),
        isFalse,
      );
    });

    test('returns false when peer is still present', () {
      expect(
        shouldAutoEndCallForPeer(
          isGroupContact: false,
          hasHadPeer: true,
          participants: [self, peer],
          status: AudioVideoCallStatus.active,
        ),
        isFalse,
      );
    });

    test('returns false when status is not a live call status', () {
      expect(
        shouldAutoEndCallForPeer(
          isGroupContact: false,
          hasHadPeer: true,
          participants: [self],
          status: AudioVideoCallStatus.ended,
        ),
        isFalse,
      );
    });
  });
}
