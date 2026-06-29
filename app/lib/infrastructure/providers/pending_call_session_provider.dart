import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallSession;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_call_session_provider.g.dart';

/// Short-lived holder used to hand a pre-created [AudioVideoCallSession]
/// to the call screen on inbound-call accept.
///
/// The incoming-call banner or chat item calls [set] before navigating to the
/// call screen. The screen's controller reads and immediately calls [clear]
/// in `build()`.
@Riverpod(keepAlive: true)
class PendingCallSession extends _$PendingCallSession {
  @override
  AudioVideoCallSession? build() => null;

  void set(AudioVideoCallSession session) => state = session;

  void clear() => state = null;
}
