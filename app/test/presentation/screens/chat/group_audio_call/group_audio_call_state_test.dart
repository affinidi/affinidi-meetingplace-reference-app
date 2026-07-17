import 'package:flutter_test/flutter_test.dart';

import 'package:mpx_flutter_reference_app/presentation/screens/chat/group_audio_call/group_audio_call_state.dart';

void main() {
  group('GroupAudioCallState', () {
    test('initial state has empty participants list', () {
      final state = const GroupAudioCallState(
        participants: <GroupAudioCallParticipant>[],
        isRinging: true,
        firstJoinedAt: null,
        errorMessage: null,
        showControls: false,
      );

      expect(state.participants, isEmpty);
      expect(state.isRinging, isTrue);
    });

    test('participantCount returns correct number', () {
      final state = const GroupAudioCallState(
        participants: <GroupAudioCallParticipant>[
          GroupAudioCallParticipant(
            displayName: 'Alice',
            isMuted: false,
            isSelf: false,
          ),
          GroupAudioCallParticipant(
            displayName: 'Bob',
            isMuted: false,
            isSelf: false,
          ),
          GroupAudioCallParticipant(
            displayName: 'Charlie',
            isMuted: false,
            isSelf: false,
          ),
        ],
        isRinging: false,
        firstJoinedAt: null,
        errorMessage: null,
        showControls: true,
      );

      expect(state.participantCount, equals(3));
    });

    test('isMultiParticipant returns false for single participant', () {
      final state = const GroupAudioCallState(
        participants: <GroupAudioCallParticipant>[
          GroupAudioCallParticipant(
            displayName: 'Alice',
            isMuted: false,
            isSelf: false,
          ),
        ],
        isRinging: false,
        firstJoinedAt: null,
        errorMessage: null,
        showControls: true,
      );

      expect(state.isMultiParticipant, isFalse);
    });

    test('isMultiParticipant returns true for multiple participants', () {
      final state = const GroupAudioCallState(
        participants: <GroupAudioCallParticipant>[
          GroupAudioCallParticipant(
            displayName: 'Alice',
            isMuted: false,
            isSelf: false,
          ),
          GroupAudioCallParticipant(
            displayName: 'Bob',
            isMuted: false,
            isSelf: false,
          ),
        ],
        isRinging: false,
        firstJoinedAt: null,
        errorMessage: null,
        showControls: true,
      );

      expect(state.isMultiParticipant, isTrue);
    });

    test('copyWith creates immutable copy with changed fields', () {
      final originalState = const GroupAudioCallState(
        participants: <GroupAudioCallParticipant>[],
        isRinging: true,
        firstJoinedAt: null,
        errorMessage: null,
        showControls: false,
      );

      final updatedState = originalState.copyWith(
        isRinging: false,
        showControls: true,
      );

      // Original unchanged
      expect(originalState.isRinging, isTrue);
      expect(originalState.showControls, isFalse);

      // Copy changed
      expect(updatedState.isRinging, isFalse);
      expect(updatedState.showControls, isTrue);
    });

    test('equality works with identical values', () {
      final state1 = const GroupAudioCallState(
        participants: <GroupAudioCallParticipant>[],
        isRinging: true,
        firstJoinedAt: null,
        errorMessage: null,
        showControls: false,
      );

      final state2 = const GroupAudioCallState(
        participants: <GroupAudioCallParticipant>[],
        isRinging: true,
        firstJoinedAt: null,
        errorMessage: null,
        showControls: false,
      );

      expect(state1, equals(state2));
    });
  });
}
