import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../../../domain/models/contact_card/contact_card.dart';
import 'call_participant_identity_rules.dart';

/// A call participant with its resolved contact card and display label.
class CallParticipantTileData {
  const CallParticipantTileData({
    required this.participant,
    required this.contactCard,
    required this.displayName,
  });

  final AudioVideoCallParticipant participant;
  final ContactCard? contactCard;
  final String displayName;
}

/// The derived data for the group audio call content.
class GroupAudioCallData {
  const GroupAudioCallData({
    required this.tiles,
    required this.singlePeerTile,
    required this.peerCount,
  });

  /// Resolved tiles for every participant, used by the grid layout.
  final List<CallParticipantTileData> tiles;

  /// The single peer tile shown when exactly one peer is present.
  final CallParticipantTileData? singlePeerTile;

  /// The number of non-self peers in the call.
  final int peerCount;
}

/// Resolves the group audio call content data from the given call state.
GroupAudioCallData resolveGroupAudioCallView({
  required List<AudioVideoCallParticipant> participants,
  required Map<String, ContactCard> memberContactCards,
  required String youLabel,
  required String peerName,
}) {
  final peerCount = participants.where((p) => !p.isSelf).length;

  CallParticipantTileData tileFor(AudioVideoCallParticipant participant) {
    return CallParticipantTileData(
      participant: participant,
      contactCard: resolveCallParticipantContactCard(
        participant,
        memberContactCards: memberContactCards,
      ),
      displayName: resolveCallParticipantDisplayName(
        participant,
        youLabel: youLabel,
        peerName: peerName,
        peerCount: peerCount,
        memberContactCards: memberContactCards,
      ),
    );
  }

  final tiles = participants.map(tileFor).toList(growable: false);
  final singlePeerTile = peerCount == 1
      ? tileFor(participants.firstWhere((participant) => !participant.isSelf))
      : null;

  return GroupAudioCallData(
    tiles: tiles,
    singlePeerTile: singlePeerTile,
    peerCount: peerCount,
  );
}
