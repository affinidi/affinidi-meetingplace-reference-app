import 'package:livekit_client/livekit_client.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:meta/meta.dart';

import 'participant_video_extension.dart';

/// Normalizes a MatrixRTC participant identity to its base user ID, stripping
/// device suffix if present.
@visibleForTesting
String matrixUserIdFromParticipantIdentity(String identity) {
  if (!identity.startsWith('@')) return identity;
  final separator = identity.lastIndexOf(':');
  if (separator <= 0) return identity;
  final baseIdentity = identity.substring(0, separator);
  if (!baseIdentity.contains(':')) return identity;
  return baseIdentity;
}

/// Looks up the permanent channel DID for a participant, with fallback
/// normalization of the identity.
String? _participantDidForIdentity(
  String identity,
  Map<String, String> participantIdToDid,
) {
  return participantIdToDid[identity] ??
      participantIdToDid[matrixUserIdFromParticipantIdentity(identity)];
}

/// Converts a LiveKit [Room] into the domain participant list.
extension RoomParticipantsExtension on Room {
  /// Maps the current self participant and peers to
  /// [AudioVideoCallParticipant] domain objects.
  ///
  /// [participantIdToDid] maps each expected participant identity to its
  /// permanent channel DID. MatrixRTC identities can arrive as either bare
  /// Matrix user IDs or `userId:deviceId`, so lookup normalizes both forms.
  List<AudioVideoCallParticipant> toParticipants(
    Map<String, String> participantIdToDid,
  ) {
    final self = localParticipant;
    final peers = remoteParticipants.values;

    return [
      if (self != null)
        AudioVideoCallParticipant(
          participantId: self.identity,
          did: _participantDidForIdentity(self.identity, participantIdToDid),
          hasVideo: self.hasRenderableVideo,
          hasAudio: self.isMicrophoneEnabled(),
          isSpeaking: self.isSpeaking,
          isSelf: true,
        ),
      for (final p in peers)
        AudioVideoCallParticipant(
          participantId: p.identity,
          did: _participantDidForIdentity(p.identity, participantIdToDid),
          hasVideo: p.hasRenderableVideo,
          hasAudio: p.isMicrophoneEnabled(),
          isSpeaking: p.isSpeaking,
        ),
    ];
  }
}
