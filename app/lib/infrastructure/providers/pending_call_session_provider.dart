import 'package:flutter_riverpod/legacy.dart';
import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallSession;

/// Short-lived provider used to hand a pre-created [AudioVideoCallSession]
/// to the call screen on inbound-call accept.
///
/// The incoming-call banner sets this before navigating to the call screen.
/// The screen's controller reads and immediately clears it in `build()`.
final pendingCallSessionProvider = StateProvider<AudioVideoCallSession?>(
  (ref) => null,
);
