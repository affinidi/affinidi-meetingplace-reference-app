import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../../../domain/models/contact_card/contact_card.dart';
import 'call_participant_identity_rules.dart';
import 'group_call_layout_rules.dart';

/// A non-focused participant rendered as a grid tile in the group call.
class ParticipantTileData {
  const ParticipantTileData({
    required this.participantId,
    required this.participant,
    required this.label,
  });

  final String participantId;
  final AudioVideoCallParticipant participant;
  final String label;
}

/// The fully derived data for a group video call screen.
///
/// Built once per frame by [resolveGroupVideoCallView] so the widget layer
/// renders resolved data instead of re-deriving focus, labels, paging and
/// layout inline.
class GroupVideoCallData {
  const GroupVideoCallData({
    required this.participants,
    required this.focusedParticipant,
    required this.focusedParticipantLabel,
    required this.selfParticipant,
    required this.singlePeerParticipant,
    required this.pages,
    required this.layoutConfig,
  });

  /// The participants the layout was resolved from (already including any
  /// local-preview fallback the caller injected).
  final List<AudioVideoCallParticipant> participants;

  /// The participant shown on the focused stage.
  final AudioVideoCallParticipant focusedParticipant;

  /// The display label for [focusedParticipant].
  final String focusedParticipantLabel;

  /// The self participant, if present in the call.
  final AudioVideoCallParticipant? selfParticipant;

  /// The single peer shown full-screen in single-peer-stage layout, if that
  /// layout is active and a self participant exists.
  final AudioVideoCallParticipant? singlePeerParticipant;

  /// Non-focused participants chunked into grid pages.
  final List<List<ParticipantTileData>> pages;

  /// The resolved layout decisions for the current participant set.
  final GroupCallLayoutConfig layoutConfig;

  /// Whether to show the page indicator dots.
  bool get showPaginationIndicator =>
      layoutConfig.showParticipantTiles && pages.length > 1;
}

/// Resolves the complete [GroupVideoCallData] for the given call state.
GroupVideoCallData resolveGroupVideoCallView({
  required List<AudioVideoCallParticipant> participants,
  required String? focusedParticipantId,
  required Map<String, ContactCard> memberContactCards,
  required String youLabel,
}) {
  final focusedParticipant = _resolveFocusedParticipant(
    participants: participants,
    focusedParticipantId: focusedParticipantId,
  );
  final focusedParticipantLabel = _displayNameFor(
    focusedParticipant,
    memberContactCards: memberContactCards,
    youLabel: youLabel,
  );

  final selfParticipant = participants
      .where((participant) => participant.isSelf)
      .firstOrNull;
  final peerParticipants = participants
      .where((participant) => !participant.isSelf)
      .toList(growable: false);

  final tileEntries = _buildTileEntries(
    participants: participants,
    focusedParticipantId: focusedParticipant.participantId,
    memberContactCards: memberContactCards,
    youLabel: youLabel,
  );

  final layoutConfig = resolveGroupCallLayoutConfig(
    participants: participants,
    focusedParticipant: focusedParticipant,
    pageCount: 0,
  );
  final tilesPerPage = layoutConfig.tileColumns * layoutConfig.tileRowsPerPage;
  final pages = tilesPerPage > 0
      ? _chunkEntries(tileEntries, tilesPerPage)
      : const <List<ParticipantTileData>>[];

  final hasSinglePeerStage =
      layoutConfig.showSinglePeerStage && selfParticipant != null;

  return GroupVideoCallData(
    participants: participants,
    focusedParticipant: focusedParticipant,
    focusedParticipantLabel: focusedParticipantLabel,
    selfParticipant: selfParticipant,
    singlePeerParticipant: hasSinglePeerStage ? peerParticipants.first : null,
    pages: pages,
    layoutConfig: layoutConfig,
  );
}

/// Picks the participant to feature on the focused stage: the explicitly
/// focused one when still present, otherwise the first peer, otherwise self.
AudioVideoCallParticipant _resolveFocusedParticipant({
  required List<AudioVideoCallParticipant> participants,
  required String? focusedParticipantId,
}) {
  if (focusedParticipantId != null) {
    final focused = participants
        .where(
          (participant) => participant.participantId == focusedParticipantId,
        )
        .firstOrNull;
    if (focused != null) return focused;
  }

  final firstRemote = participants
      .where((participant) => !participant.isSelf)
      .firstOrNull;
  return firstRemote ?? participants.first;
}

/// Builds the non-focused tile entries, preserving participant order.
List<ParticipantTileData> _buildTileEntries({
  required List<AudioVideoCallParticipant> participants,
  required String focusedParticipantId,
  required Map<String, ContactCard> memberContactCards,
  required String youLabel,
}) {
  return participants
      .where((participant) => participant.participantId != focusedParticipantId)
      .map(
        (participant) => ParticipantTileData(
          participantId: participant.participantId,
          participant: participant,
          label: _displayNameFor(
            participant,
            memberContactCards: memberContactCards,
            youLabel: youLabel,
          ),
        ),
      )
      .toList(growable: false);
}

/// Splits [entries] into fixed-size pages.
List<List<ParticipantTileData>> _chunkEntries(
  List<ParticipantTileData> entries,
  int chunkSize,
) {
  if (entries.isEmpty || chunkSize <= 0) return const [];

  final pages = <List<ParticipantTileData>>[];
  for (var index = 0; index < entries.length; index += chunkSize) {
    final end = (index + chunkSize) > entries.length
        ? entries.length
        : index + chunkSize;
    pages.add(entries.sublist(index, end));
  }
  return pages;
}

/// Resolves the display label for a participant: "You" for self, then the
/// member card name, then the DID suffix, then the raw participant id.
String _displayNameFor(
  AudioVideoCallParticipant participant, {
  required Map<String, ContactCard> memberContactCards,
  required String youLabel,
}) {
  if (participant.isSelf) return youLabel;
  final did = resolveCallParticipantDid(
    participant,
    memberContactCards: memberContactCards,
  );
  final card = did == null ? null : memberContactCards[did];
  final name = card?.displayName;
  if (name != null && name.isNotEmpty) return name;
  if (did != null && did.isNotEmpty) return did.split(':').last;
  return participant.participantId;
}
