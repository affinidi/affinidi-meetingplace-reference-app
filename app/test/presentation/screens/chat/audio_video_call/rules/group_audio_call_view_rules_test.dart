import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/domain/models/contact_card/contact_card.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/group_audio_call_view_rules.dart';

const _you = 'You';
const _peerName = 'Grace Hopper';

AudioVideoCallParticipant _self() => const AudioVideoCallParticipant(
  participantId: 'self',
  isSelf: true,
  hasVideo: false,
  hasAudio: true,
  isSpeaking: false,
);

AudioVideoCallParticipant _peer(String id, {String? did}) =>
    AudioVideoCallParticipant(
      participantId: id,
      did: did,
      isSelf: false,
      hasVideo: false,
      hasAudio: true,
      isSpeaking: false,
    );

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

GroupAudioCallData _resolve(
  List<AudioVideoCallParticipant> participants, {
  Map<String, ContactCard> memberContactCards = const {},
  String peerName = _peerName,
}) {
  return resolveGroupAudioCallView(
    participants: participants,
    memberContactCards: memberContactCards,
    youLabel: _you,
    peerName: peerName,
  );
}

void main() {
  group('resolveGroupAudioCallView', () {
    test('counts only non-self peers', () {
      final view = _resolve([_self(), _peer('a'), _peer('b')]);

      expect(view.peerCount, 2);
    });

    test('returns a single peer tile when exactly one peer is present', () {
      final view = _resolve([_self(), _peer('peer-1', did: 'did:key:peer-1')]);

      expect(view.singlePeerTile, isNotNull);
      expect(view.singlePeerTile?.participant.participantId, 'peer-1');
      expect(view.singlePeerTile?.displayName, _peerName);
    });

    test('omits the single peer tile when multiple peers are present', () {
      final view = _resolve([_self(), _peer('a'), _peer('b')]);

      expect(view.singlePeerTile, isNull);
    });

    test('resolves tile labels and cards for all participants', () {
      const did = 'did:key:peer-1';
      final card = _card(did: did, displayName: 'Display Peer');

      final view = _resolve(
        [_self(), _peer('peer-1', did: did)],
        memberContactCards: {did: card},
      );

      expect(view.tiles.map((tile) => tile.displayName), [
        _you,
        'Display Peer',
      ]);
      expect(view.tiles.last.contactCard, same(card));
    });

    test('keeps all participants in the grid tiles', () {
      final view = _resolve([_self(), _peer('a'), _peer('b')]);

      expect(view.tiles.map((tile) => tile.participant.participantId), [
        'self',
        'a',
        'b',
      ]);
    });
  });
}
