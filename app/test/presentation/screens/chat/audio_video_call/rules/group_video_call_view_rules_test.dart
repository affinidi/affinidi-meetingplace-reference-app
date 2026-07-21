import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/group_video_call_view_rules.dart';

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
      hasVideo: true,
      hasAudio: true,
      isSpeaking: false,
    );

const _you = 'You';

GroupVideoCallData _resolve(
  List<AudioVideoCallParticipant> participants, {
  String? focusedParticipantId,
}) {
  return resolveGroupVideoCallView(
    participants: participants,
    focusedParticipantId: focusedParticipantId,
    memberContactCards: const {},
    youLabel: _you,
  );
}

void main() {
  group('resolveGroupVideoCallView focus resolution', () {
    test('honours the explicitly focused participant when present', () {
      final view = _resolve([
        _self(),
        _peer('a'),
        _peer('b'),
      ], focusedParticipantId: 'b');

      expect(view.focusedParticipant.participantId, 'b');
    });

    test('falls back to the first peer when focus id is absent', () {
      final view = _resolve([
        _self(),
        _peer('a'),
        _peer('b'),
      ], focusedParticipantId: 'missing');

      expect(view.focusedParticipant.participantId, 'a');
    });

    test('falls back to self when there are no peers', () {
      final view = _resolve([_self()]);

      expect(view.focusedParticipant.participantId, 'self');
    });
  });

  group('resolveGroupVideoCallView labels', () {
    test('labels self with the provided you label', () {
      final view = _resolve([_self()]);

      expect(view.focusedParticipantLabel, _you);
    });

    test('labels a peer without a card using the did suffix', () {
      final view = _resolve([
        _self(),
        _peer('a', did: 'did:key:zPeerA'),
      ], focusedParticipantId: 'a');

      expect(view.focusedParticipantLabel, 'zPeerA');
    });
  });

  group('resolveGroupVideoCallView tile entries', () {
    test('excludes the focused participant from the tiles', () {
      final view = _resolve([
        _self(),
        _peer('a'),
        _peer('b'),
      ], focusedParticipantId: 'a');

      final tileIds = view.pages
          .expand((page) => page)
          .map((entry) => entry.participantId)
          .toList();
      expect(tileIds, isNot(contains('a')));
      expect(tileIds, containsAll(['self', 'b']));
    });

    test('chunks tiles into pages of six for the paged grid layout', () {
      final participants = [
        _self(),
        for (var index = 0; index < 8; index++) _peer('peer$index'),
      ];

      final view = _resolve(participants, focusedParticipantId: 'peer0');

      expect(view.pages.first.length, 6);
      expect(view.pages.length, 2);
    });
  });

  group('resolveGroupVideoCallView single peer stage', () {
    test('exposes the single peer when self and one peer are present', () {
      final view = _resolve([_self(), _peer('a')]);

      expect(view.singlePeerParticipant?.participantId, 'a');
    });

    test('has no single peer when there is no self participant', () {
      final view = _resolve([_peer('a')]);

      expect(view.singlePeerParticipant, isNull);
    });
  });

  group('resolveGroupVideoCallView pagination indicator', () {
    test('is hidden with a single page of tiles', () {
      final view = _resolve([
        _self(),
        _peer('a'),
        _peer('b'),
      ], focusedParticipantId: 'a');

      expect(view.showPaginationIndicator, isFalse);
    });

    test('is shown once tiles span more than one page', () {
      final participants = [
        _self(),
        for (var index = 0; index < 8; index++) _peer('peer$index'),
      ];

      final view = _resolve(participants, focusedParticipantId: 'peer0');

      expect(view.showPaginationIndicator, isTrue);
    });
  });
}
