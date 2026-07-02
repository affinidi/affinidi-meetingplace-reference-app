import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_ended_state.freezed.dart';

@freezed
abstract class CallEndedState with _$CallEndedState {
  const factory CallEndedState({
    required String contactId,
    required String peerName,
    required int callDurationSeconds,
    required bool isAudioOnly,
  }) = _CallEndedState;
}
