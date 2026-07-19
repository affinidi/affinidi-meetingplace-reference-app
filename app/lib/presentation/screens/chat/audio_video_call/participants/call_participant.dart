import 'package:flutter/painting.dart';

/// Whether a call participant is currently connected to the call.
enum CallParticipantConnection { connected, notConnected }

/// The ringing state for a not-connected participant.
///
/// [timedOut] is treated identically to [idle] in the UI — the bell icon is
/// shown so the user can re-ring.
enum CallRingState { idle, ringing, timedOut }

/// Presentational view-model for a single participant in a group call.
///
/// UI-only; has no SDK or group-call session dependencies.
class CallParticipant {
  const CallParticipant({
    required this.id,
    required this.firstName,
    this.avatar,
    required this.connection,
    this.ringState = CallRingState.idle,
  });

  final String id;
  final String firstName;

  /// Optional avatar image; when null the sheet shows the person placeholder.
  final ImageProvider? avatar;

  final CallParticipantConnection connection;

  /// Ringing state; only meaningful when [connection] is
  /// [CallParticipantConnection.notConnected].
  final CallRingState ringState;

  CallParticipant copyWith({
    String? id,
    String? firstName,
    ImageProvider? avatar,
    CallParticipantConnection? connection,
    CallRingState? ringState,
  }) {
    return CallParticipant(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      avatar: avatar ?? this.avatar,
      connection: connection ?? this.connection,
      ringState: ringState ?? this.ringState,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CallParticipant &&
        other.id == id &&
        other.firstName == firstName &&
        other.avatar == avatar &&
        other.connection == connection &&
        other.ringState == ringState;
  }

  @override
  int get hashCode => Object.hash(id, firstName, avatar, connection, ringState);
}
