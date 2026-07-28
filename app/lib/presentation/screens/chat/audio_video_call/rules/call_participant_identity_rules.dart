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
  final did = resolveCallParticipantDid(
    participant,
    memberContactCards: memberContactCards,
  );
  if (did == null) return null;
  return memberContactCards[did];
}

/// Resolves the group member DID for a connected call participant.
String? resolveCallParticipantDid(
  AudioVideoCallParticipant participant, {
  required Map<String, ContactCard> memberContactCards,
}) {
  final did = participant.did;
  if (did != null && did.isNotEmpty && memberContactCards.containsKey(did)) {
    return did;
  }

  for (final matrixUserId in _matrixUserIdCandidates(
    participant.participantId,
  )) {
    final serverName = _serverNameFromMatrixUserId(matrixUserId);
    if (serverName == null) continue;
    for (final entry in memberContactCards.entries) {
      if (_deriveMatrixUserId(entry.key, serverName) == matrixUserId) {
        return entry.key;
      }
    }
  }

  return did != null && did.isNotEmpty ? did : null;
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

List<String> _matrixUserIdCandidates(String participantId) {
  final candidates = <String>[participantId];
  final firstSeparator = participantId.indexOf(':');
  final lastSeparator = participantId.lastIndexOf(':');
  if (participantId.startsWith('@') &&
      firstSeparator > 0 &&
      lastSeparator > firstSeparator) {
    final withoutDeviceId = participantId.substring(0, lastSeparator);
    if (withoutDeviceId != participantId) {
      candidates.add(withoutDeviceId);
    }
  }
  return candidates;
}

String? _serverNameFromMatrixUserId(String matrixUserId) {
  final separator = matrixUserId.indexOf(':');
  if (!matrixUserId.startsWith('@') ||
      separator < 0 ||
      separator == matrixUserId.length - 1) {
    return null;
  }
  return matrixUserId.substring(separator + 1);
}

String _deriveMatrixUserId(String did, String serverName) {
  final localpart = '$did|$serverName'.toDidSha256;
  return '@$localpart:$serverName';
}
