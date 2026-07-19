import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'call_participant.dart';

part 'call_participants_ring_controller.g.dart';

/// How long a re-ring stays in the ringing state before timing out back to the
/// idle (bell) state so the user can ring again.
const _ringTimeout = Duration(seconds: 30);

/// Tracks the per-member re-ring state for a group call's participant list,
/// keyed by the member's DID.
///
/// Drives the bell -> ringing -> timeout affordance in the participant sheet.
/// State is held here (not in the sheet) so it survives the sheet closing and
/// reopening while a ring is still in flight.
@riverpod
class CallParticipantsRingController extends _$CallParticipantsRingController {
  final Map<String, Timer> _timers = {};

  @override
  Map<String, CallRingState> build(String contactId) {
    ref.onDispose(() {
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();
    });
    return const {};
  }

  /// Marks [memberDid] as ringing and starts the timeout timer.
  ///
  /// Integration seam: the SDK currently exposes no per-member or group
  /// re-invite API to the app layer, so this only drives the UI ring state.
  /// When such an API lands, place the actual network re-ring call here.
  void ring(String memberDid) {
    _timers.remove(memberDid)?.cancel();
    state = {...state, memberDid: CallRingState.ringing};
    _timers[memberDid] = Timer(_ringTimeout, () {
      _timers.remove(memberDid);
      if (state[memberDid] == CallRingState.ringing) {
        state = {...state, memberDid: CallRingState.timedOut};
      }
    });
  }

  /// Cancels an in-flight ring for [memberDid], returning it to idle.
  void cancelRing(String memberDid) {
    _timers.remove(memberDid)?.cancel();
    if (!state.containsKey(memberDid)) return;
    state = {...state}..remove(memberDid);
  }
}
