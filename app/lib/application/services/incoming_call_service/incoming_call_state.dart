import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

part 'incoming_call_state.freezed.dart';

/// The incoming-call state: either no call is ringing ([IncomingCallIdle]) or
/// one is ([IncomingCallRinging]).
@freezed
sealed class IncomingCallState with _$IncomingCallState {
  const IncomingCallState._();

  const factory IncomingCallState.idle() = IncomingCallIdle;

  const factory IncomingCallState.ringing(IncomingAudioVideoCallEvent event) =
      IncomingCallRinging;

  /// The ringing event, or `null` when idle.
  IncomingAudioVideoCallEvent? get eventOrNull => switch (this) {
    IncomingCallRinging(:final event) => event,
    IncomingCallIdle() => null,
  };
}
