import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/infrastructure/extensions/did_extensions.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/call_participant_identity_rules.dart';

const _you = 'You';
const _peerName = 'Grace Hopper';
const _serverName = 'example.org';

AudioVideoCallParticipant _participant({
  required String participantId,
  String? did,
  bool isSelf = false,
}) {
  return AudioVideoCallParticipant(
    participantId: participantId,
    did: did,
    isSelf: isSelf,
    hasVideo: false,
    hasAudio: true,
    isSpeaking: false,
  );
}

ContactCard _card({
  required String did,
  required String displayName,
  String? profilePic,
}) {
  return ContactCard(
    id: did,
    did: did,
    type: 'individual',
    firstName: displayName,
    displayName: displayName,
    profilePic: profilePic,
  );
}

String _matrixUserId(String did) {
  return '@${'$did|$_serverName'.toDidSha256}:$_serverName';
}

void main() {
  group('resolveCallParticipantDisplayName', () {
    test('returns the you label for self', () {
      final label = resolveCallParticipantDisplayName(
        _participant(participantId: 'self', isSelf: true),
        youLabel: _you,
        peerName: _peerName,
        peerCount: 1,
        memberContactCards: const {},
      );

      expect(label, _you);
    });

    test('uses the matched member contact card display name', () {
      const did = 'did:key:peer-1';
      final card = _card(did: did, displayName: 'Display Peer');

      final label = resolveCallParticipantDisplayName(
        _participant(participantId: 'peer-1', did: did),
        youLabel: _you,
        peerName: _peerName,
        peerCount: 2,
        memberContactCards: {did: card},
      );

      expect(label, 'Display Peer');
    });

    test('falls back to the peer name for a one-peer call', () {
      final label = resolveCallParticipantDisplayName(
        _participant(participantId: 'peer-1', did: 'did:key:peer-1'),
        youLabel: _you,
        peerName: _peerName,
        peerCount: 1,
        memberContactCards: const {},
      );

      expect(label, _peerName);
    });

    test('returns an empty label for unresolved multi-peer participants', () {
      final label = resolveCallParticipantDisplayName(
        _participant(participantId: 'peer-1', did: 'did:key:peer-1'),
        youLabel: _you,
        peerName: _peerName,
        peerCount: 2,
        memberContactCards: const {},
      );

      expect(label, isEmpty);
    });
  });

  group('resolveCallParticipantContactCard', () {
    test('returns a direct did match when present', () {
      const did = 'did:key:peer-1';
      final card = _card(did: did, displayName: 'Display Peer');

      final resolved = resolveCallParticipantContactCard(
        _participant(participantId: 'peer-1', did: did),
        memberContactCards: {did: card},
      );

      expect(resolved, same(card));
    });

    test('matches a member card by derived matrix user id', () {
      const did = 'did:key:peer-1';
      final card = _card(did: did, displayName: 'Display Peer');

      final resolved = resolveCallParticipantContactCard(
        _participant(participantId: _matrixUserId(did), did: did),
        memberContactCards: {did: card},
      );

      expect(resolved, same(card));
    });

    test('finds the matching member card from another did entry', () {
      const matchedDid = 'did:key:peer-1';
      const otherDid = 'did:key:peer-2';
      final matchedCard = _card(did: matchedDid, displayName: 'Matched Peer');
      final otherCard = _card(did: otherDid, displayName: 'Other Peer');

      final resolved = resolveCallParticipantContactCard(
        _participant(
          participantId: _matrixUserId(matchedDid),
          did: 'did:key:unrelated',
        ),
        memberContactCards: {otherDid: otherCard, matchedDid: matchedCard},
      );

      expect(resolved, same(matchedCard));
    });

    test('returns null when the participant cannot be resolved', () {
      final resolved = resolveCallParticipantContactCard(
        _participant(participantId: 'peer-1', did: 'did:key:peer-1'),
        memberContactCards: const {},
      );

      expect(resolved, isNull);
    });
  });

  group('resolveBestAvatarCard', () {
    test('prefers the first card with a profile picture', () {
      final plainCard = _card(did: 'did:key:plain', displayName: 'Plain');
      final avatarCard = _card(
        did: 'did:key:avatar',
        displayName: 'Avatar',
        profilePic: 'data:image/png;base64,AAAA',
      );

      final resolved = resolveBestAvatarCard([plainCard, avatarCard]);

      expect(resolved, same(avatarCard));
    });

    test('falls back to the first non-null card', () {
      final plainCard = _card(did: 'did:key:plain', displayName: 'Plain');

      final resolved = resolveBestAvatarCard([null, plainCard]);

      expect(resolved, same(plainCard));
    });

    test('returns null when every candidate is null', () {
      final resolved = resolveBestAvatarCard([null, null]);

      expect(resolved, isNull);
    });
  });
}
