part of 'audio_video_call_screen.dart';

/// Resolves the label shown beneath a participant tile.
///
/// The self participant is always "You". A group member is resolved to their
/// name via [memberContactCards], keyed by the participant's DID. A single
/// peer in a 1:1 call falls back to the contact name.
String _displayNameFor(
  AudioVideoCallParticipant participant, {
  required String youLabel,
  required String peerName,
  required int remoteCount,
  required Map<String, ContactCard> memberContactCards,
}) {
  if (participant.isSelf) return youLabel;
  final name = _contactCardFor(
    participant,
    memberContactCards: memberContactCards,
  )?.displayName;
  if (name != null && name.isNotEmpty) return name;
  if (remoteCount <= 1) return peerName;
  return '';
}

String? _serverNameFromParticipantId(String participantId) {
  final separator = participantId.indexOf(':');
  if (separator < 0 || separator == participantId.length - 1) return null;
  return participantId.substring(separator + 1);
}

String _deriveMatrixUserId(String did, String serverName) {
  final localpart = sha256.convert(utf8.encode('$did|$serverName')).toString();
  return '@$localpart:$serverName';
}

ContactCard? _contactCardFor(
  AudioVideoCallParticipant participant, {
  required Map<String, ContactCard> memberContactCards,
}) {
  final did = participant.did;
  if (did != null) {
    final directMatch = memberContactCards[did];
    if (directMatch != null) return directMatch;
  }

  final serverName = _serverNameFromParticipantId(participant.participantId);
  if (serverName == null) return null;

  for (final entry in memberContactCards.entries) {
    if (_deriveMatrixUserId(entry.key, serverName) ==
        participant.participantId) {
      return entry.value;
    }
  }

  return null;
}

ContactCard? _bestAvatarCard(Iterable<ContactCard?> candidates) {
  for (final card in candidates) {
    if (card?.hasProfilePic == true) return card;
  }

  for (final card in candidates) {
    if (card != null) return card;
  }

  return null;
}
