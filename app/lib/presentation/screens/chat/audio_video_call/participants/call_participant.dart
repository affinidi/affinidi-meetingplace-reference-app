import 'package:flutter/painting.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_participant.freezed.dart';

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
@Freezed(fromJson: false, toJson: false)
abstract class CallParticipant with _$CallParticipant {
  const factory CallParticipant({
    required String id,
    required String firstName,

    /// Optional avatar image; when null the sheet shows the person placeholder.
    ImageProvider? avatar,
    required CallParticipantConnection connection,

    /// Ringing state; only meaningful when [connection] is
    /// [CallParticipantConnection.notConnected].
    @Default(CallRingState.idle) CallRingState ringState,
  }) = _CallParticipant;
}
