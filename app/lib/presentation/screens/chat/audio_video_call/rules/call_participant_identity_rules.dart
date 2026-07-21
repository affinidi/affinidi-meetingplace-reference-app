import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../../../domain/models/contact_card/contact_card.dart';
import '../../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../../infrastructure/extensions/did_extensions.dart';

/// Resolves the label shown for a call participant.
String resolveCallParticipantDisplayName(
  AudioVideoCallParticipant participant, {
  required String youLabel,
  required String peerName,
  required int peerCount,
  required Map<String, ContactCard> memberContactCards,
}) {
  if (participant.isSelf) return youLabel;
  final name = resolveCallParticipantContactCard(
    participant,
    memberContactCards: memberContactCards,
  )?.displayName;
  if (name != null && name.isNotEmpty) return name;
  if (peerCount <= 1) return peerName;
  return '';
}

/// Resolves the best contact card match for a call participant.
ContactCard? resolveCallParticipantContactCard(
  AudioVideoCallParticipant participant, {
  required Map<String, ContactCard> memberContactCards,
}) {
  final did = participant.did;
  if (did != null) {
    final directMatch = memberContactCards[did];
    if (directMatch != null) return directMatch;
  }

  final serverName = _serverNameFromParticipantId(participant.participantId);
  if (serverName == null || did == null || did.isEmpty) {
    return null;
  }

  final derivedUserId = _deriveMatrixUserId(did, serverName);
  if (derivedUserId == participant.participantId) {
    return memberContactCards[did];
  }

  for (final entry in memberContactCards.entries) {
    if (_deriveMatrixUserId(entry.key, serverName) ==
        participant.participantId) {
      return entry.value;
    }
  }

  return null;
}

/// Picks the best avatar card, preferring one with a profile picture.
ContactCard? resolveBestAvatarCard(Iterable<ContactCard?> candidates) {
  for (final card in candidates) {
    if (card?.hasProfilePic == true) return card;
  }

  for (final card in candidates) {
    if (card != null) return card;
  }

  return null;
}

String? _serverNameFromParticipantId(String participantId) {
  final separator = participantId.indexOf(':');
  if (separator < 0 || separator == participantId.length - 1) return null;
  return participantId.substring(separator + 1);
}

String _deriveMatrixUserId(String did, String serverName) {
  final localpart = '$did|$serverName'.toDidSha256;
  return '@$localpart:$serverName';
}
