import 'package:meeting_place_matrix/meeting_place_matrix.dart';

/// A single past-call entry aggregated across all chats for the Call log
/// screen.
///
/// Built from a chat message carrying [CallMetadata] (see
/// `CallMetadata.isCall`). [participantNames] is populated when the call's
/// [CallParticipation.participantDids] resolve to known contacts; a group
/// call with no resolvable DIDs (e.g. a record persisted before DIDs were
/// captured) falls back to a count-based label via [participantCount].
class CallLogEntry {
  const CallLogEntry({
    required this.contactId,
    required this.displayLabel,
    required this.mediaType,
    required this.status,
    required this.timestamp,
    required this.durationMs,
    required this.isFromMe,
    required this.isGroupCall,
    required this.participantCount,
    this.participantNames,
  });

  /// Local contact identifier this call belongs to.
  final String contactId;

  /// Peer name for a 1:1 call, or group label for a group call.
  final String displayLabel;

  /// Whether the call was audio-only or included video.
  final CallMediaType mediaType;

  /// The terminal (or last known) call status.
  final CallStatus status;

  /// When the call started, from the call chat item's creation time.
  final DateTime timestamp;

  /// Call duration in milliseconds, when known.
  final int? durationMs;

  /// Whether the local party initiated the call.
  final bool isFromMe;

  /// Whether this call happened on a group chat, as opposed to a 1:1 chat.
  final bool isGroupCall;

  /// Distinct peers in the call, excluding the local party.
  final int participantCount;

  /// Named participants, when resolved from
  /// [CallParticipation.participantDids]; `null` for 1:1 calls or when no DID
  /// resolved to a known contact.
  final List<String>? participantNames;
}
