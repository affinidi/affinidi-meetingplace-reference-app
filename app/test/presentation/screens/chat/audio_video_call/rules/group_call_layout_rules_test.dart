import 'package:flutter_test/flutter_test.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:mpx_flutter_reference_app/presentation/screens/chat/audio_video_call/rules/group_call_layout_rules.dart';

AudioVideoCallParticipant _self() => const AudioVideoCallParticipant(
  participantId: 'self',
  isSelf: true,
  hasVideo: true,
  hasAudio: true,
  isSpeaking: false,
);

AudioVideoCallParticipant _peer(String id) => AudioVideoCallParticipant(
  participantId: id,
  isSelf: false,
  hasVideo: true,
  hasAudio: true,
  isSpeaking: false,
);

GroupCallLayoutConfig _resolve(
  List<AudioVideoCallParticipant> participants, {
  int pageCount = 1,
}) {
  final focused = participants.firstWhere(
    (p) => p.isSelf,
    orElse: () => participants.first,
  );
  return resolveGroupCallLayoutConfig(
    participants: participants,
    focusedParticipant: focused,
    pageCount: pageCount,
  );
}

void main() {
  group('resolveGroupCallLayoutConfig layout selection', () {
    test('resolves selfOnly when there are no peers', () {
      final config = _resolve([_self()]);

      expect(config.layout, GroupCallLayout.selfOnly);
    });

    test('resolves singlePeerStage with one peer', () {
      final config = _resolve([_self(), _peer('a')]);

      expect(config.layout, GroupCallLayout.singlePeerStage);
    });

    test('resolves twoPeerRow with two peers', () {
      final config = _resolve([_self(), _peer('a'), _peer('b')]);

      expect(config.layout, GroupCallLayout.twoPeerRow);
    });

    test('resolves pagedGrid with three or more peers', () {
      final config = _resolve([_self(), _peer('a'), _peer('b'), _peer('c')]);

      expect(config.layout, GroupCallLayout.pagedGrid);
    });
  });

  group('resolveGroupCallLayoutConfig tile dimensions', () {
    test('twoPeerRow uses 2 columns and 1 row per page', () {
      final config = _resolve([_self(), _peer('a'), _peer('b')]);

      expect(config.tileColumns, 2);
      expect(config.tileRowsPerPage, 1);
    });

    test('pagedGrid uses 3 columns and 2 rows per page', () {
      final config = _resolve([_self(), _peer('a'), _peer('b'), _peer('c')]);

      expect(config.tileColumns, 3);
      expect(config.tileRowsPerPage, 2);
    });
  });

  group('resolveGroupCallLayoutConfig flags', () {
    test('shows full-screen self stage when self is alone', () {
      final config = _resolve([_self()]);

      expect(config.showFullScreenFocusedSelfStage, isTrue);
      expect(config.showSinglePeerStage, isFalse);
      expect(config.showParticipantTiles, isFalse);
    });

    test('shows single peer stage with exactly one peer', () {
      final config = _resolve([_self(), _peer('a')]);

      expect(config.showSinglePeerStage, isTrue);
      expect(config.showParticipantTiles, isFalse);
    });

    test('shows participant tiles for two or more peers', () {
      final config = _resolve([_self(), _peer('a'), _peer('b')]);

      expect(config.showParticipantTiles, isTrue);
    });

    test('shows switch-camera button only in self-only layout', () {
      final selfOnly = _resolve([_self()]);
      final withPeer = _resolve([_self(), _peer('a')]);

      expect(selfOnly.showHeaderSwitchCamera, isTrue);
      expect(withPeer.showHeaderSwitchCamera, isFalse);
    });

    test('pagination indicator hidden with a single page', () {
      final config = _resolve([
        _self(),
        _peer('a'),
        _peer('b'),
        _peer('c'),
      ], pageCount: 1);

      expect(config.showPaginationIndicator, isFalse);
    });

    test('pagination indicator shown when page count exceeds one', () {
      final config = _resolve([
        _self(),
        _peer('a'),
        _peer('b'),
        _peer('c'),
      ], pageCount: 2);

      expect(config.showPaginationIndicator, isTrue);
    });
  });
}
