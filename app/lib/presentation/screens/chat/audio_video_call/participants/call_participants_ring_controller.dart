import 'dart:async';

import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../application/services/contacts_service/contacts_service.dart';
import '../../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../audio_video_call_screen_controller.dart';
import 'call_participant.dart';

part 'call_participants_ring_controller.g.dart';

/// How long a re-ring stays in the ringing state before timing out back to the
/// idle (bell) state so the user can ring again.
const _ringTimeout = Duration(seconds: 30);

/// Tracks the per-member re-ring state for a group call's participant list,
/// keyed by the member's DID.
///
/// Drives the bell -> ringing -> timeout affordance in the participant sheet
/// and sends the targeted call-invite to that member through the SDK. State is
/// held here (not in the sheet) so it survives the sheet closing and reopening
/// while a ring is still in flight.
@riverpod
class CallParticipantsRingController extends _$CallParticipantsRingController {
  final Map<String, Timer> _timers = {};
  late String _contactId;

  static const _logKey = 'CallParticipantsRingController';

  @override
  Map<String, CallRingState> build(String contactId) {
    _contactId = contactId;
    ref.onDispose(() {
      for (final timer in _timers.values) {
        timer.cancel();
      }
      _timers.clear();
    });
    return const {};
  }

  /// Marks [memberDid] as ringing, sends the targeted call-invite through the
  /// SDK, and starts the timeout timer.
  void ring(String memberDid) {
    _timers.remove(memberDid)?.cancel();
    state = {...state, memberDid: CallRingState.ringing};
    _timers[memberDid] = Timer(_ringTimeout, () {
      _timers.remove(memberDid);
      if (state[memberDid] == CallRingState.ringing) {
        state = {...state, memberDid: CallRingState.timedOut};
      }
    });
    unawaited(_sendRing(memberDid));
  }

  /// Cancels an in-flight ring for [memberDid], returning it to idle.
  void cancelRing(String memberDid) {
    _timers.remove(memberDid)?.cancel();
    if (!state.containsKey(memberDid)) return;
    state = {...state}..remove(memberDid);
  }

  /// Sends the targeted group call-invite for [memberDid] via the SDK.
  ///
  /// Resolves the group channel DID and current media type from call state.
  /// Failures are logged; the ring-state timer still governs the UI.
  Future<void> _sendRing(String memberDid) async {
    try {
      final sdk = await ref.read(meetingPlaceSdkProvider.future);
      final contact = ref
          .read(contactsServiceProvider)
          .getContactById(_contactId);
      final groupChannelDid = contact?.channelDid ?? _contactId;
      final isAudioOnly = ref
          .read(audioVideoCallScreenControllerProvider(_contactId))
          .isAudioOnly;
      await sdk.ringGroupMember(
        groupChannelDid: groupChannelDid,
        memberDid: memberDid,
        mediaType: isAudioOnly ? CallMediaType.audio : CallMediaType.video,
      );
    } catch (e, stackTrace) {
      ref
          .read(appLoggerProvider)
          .error(
            'Failed to ring group member',
            error: e,
            stackTrace: stackTrace,
            name: _logKey,
          );
    }
  }
}
