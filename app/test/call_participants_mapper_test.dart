import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/participants/call_participant.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/participants/call_participants_sheet.dart';

const _avatar = AssetImage('assets/test_avatar.png');

ContactCard _card(String did, String firstName) => ContactCard(
  id: did,
  did: did,
  type: 'contact',
  firstName: firstName,
  displayName: firstName,
);

void main() {
  ImageProvider<Object> avatarOf(ContactCard _) => _avatar;

  group('buildCallParticipants', () {
    test('splits roster into connected and not-connected by DID', () {
      final result = buildCallParticipants(
        roster: {
          'did:a': _card('did:a', 'Alice'),
          'did:b': _card('did:b', 'Bob'),
          'did:c': _card('did:c', 'Carol'),
        },
        connected: const [
          AudioVideoCallParticipant(participantId: 'p1', did: 'did:a'),
        ],
        ringStates: const {},
        avatarOf: avatarOf,
      );

      final alice = result.firstWhere((p) => p.id == 'did:a');
      final bob = result.firstWhere((p) => p.id == 'did:b');

      expect(alice.connection, CallParticipantConnection.connected);
      expect(alice.firstName, 'Alice');
      expect(alice.avatar, _avatar);
      expect(bob.connection, CallParticipantConnection.notConnected);
      expect(
        result.where(
          (p) => p.connection == CallParticipantConnection.notConnected,
        ),
        hasLength(2),
      );
    });

    test('applies ring state only to not-connected members', () {
      final result = buildCallParticipants(
        roster: {
          'did:a': _card('did:a', 'Alice'),
          'did:b': _card('did:b', 'Bob'),
        },
        connected: const [
          AudioVideoCallParticipant(participantId: 'p1', did: 'did:a'),
        ],
        // Ring state exists for both; the connected member must ignore it.
        ringStates: const {
          'did:a': CallRingState.ringing,
          'did:b': CallRingState.ringing,
        },
        avatarOf: avatarOf,
      );

      expect(
        result.firstWhere((p) => p.id == 'did:a').ringState,
        CallRingState.idle,
      );
      expect(
        result.firstWhere((p) => p.id == 'did:b').ringState,
        CallRingState.ringing,
      );
    });

    test('not-connected member without a ring entry defaults to idle', () {
      final result = buildCallParticipants(
        roster: {'did:b': _card('did:b', 'Bob')},
        connected: const [],
        ringStates: const {},
        avatarOf: avatarOf,
      );

      expect(result.single.ringState, CallRingState.idle);
      expect(result.single.connection, CallParticipantConnection.notConnected);
    });

    test('ignores connected participants with a null DID', () {
      final result = buildCallParticipants(
        roster: {'did:b': _card('did:b', 'Bob')},
        connected: const [
          AudioVideoCallParticipant(participantId: 'self', isSelf: true),
        ],
        ringStates: const {},
        avatarOf: avatarOf,
      );

      expect(result.single.connection, CallParticipantConnection.notConnected);
    });

    test(
      'excludes the local user by ownDid even when self has a null participant '
      'DID',
      () {
        final result = buildCallParticipants(
          roster: {
            'did:me': _card('did:me', 'Me'),
            'did:b': _card('did:b', 'Bob'),
          },
          connected: const [
            AudioVideoCallParticipant(participantId: 'self', isSelf: true),
            AudioVideoCallParticipant(participantId: 'p1', did: 'did:b'),
          ],
          ringStates: const {},
          avatarOf: avatarOf,
          ownDid: 'did:me',
        );

        expect(result.map((p) => p.id), ['did:b']);
        expect(result.single.connection, CallParticipantConnection.connected);
      },
    );
  });
}
