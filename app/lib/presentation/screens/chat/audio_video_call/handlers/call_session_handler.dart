import 'dart:async';

import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../audio_video_call_screen_state.dart';
import '../audio_video_call_state_update.dart';
import '../rules/call_ui_rules.dart';

/// Manages the lifecycle of a single [AudioVideoCallSession] stream.
///
/// Subscribes to [AudioVideoCallSession.state] and
/// [AudioVideoCallSession.participantEvents], converts each emission into an
/// [AudioVideoCallStateUpdate], and passes it to [onUpdate].
///
/// Plain Dart class with no Riverpod dependency — unit-testable without a
/// ProviderContainer.
class CallSessionHandler {
  CallSessionHandler({required this.logger, required this.onUpdate});

  static const _logKey = 'CallSessionHandler';

  final AppLogger logger;
  final void Function(AudioVideoCallStateUpdate update) onUpdate;

  StreamSubscription<AudioVideoCallState>? _stateSub;
  StreamSubscription<CallParticipantEvent>? _participantSub;
  bool _isDisposed = false;

  bool _hasHadPeer = false;
  bool _cameraHasBeenEnabled = false;

  /// Subscribes to [session] state and participant events.
  /// Cancels any existing subscriptions first.
  void attach(AudioVideoCallSession session) {
    _stateSub?.cancel();
    _participantSub?.cancel();
    _stateSub = session.state.listen(_onSessionState);
    _participantSub = session.participantEvents.listen(_onParticipantEvent);
  }

  /// Cancels all subscriptions.
  void dispose() {
    _isDisposed = true;
    _stateSub?.cancel();
    _stateSub = null;
    _participantSub?.cancel();
    _participantSub = null;
  }

  void _onSessionState(AudioVideoCallState next) {
    if (_isDisposed) {
      logger.info('_onSessionState: skipping, handler disposed', name: _logKey);
      return;
    }

    final self = next.participants.where((p) => p.isSelf).firstOrNull;

    final hadPeerBefore = _hasHadPeer;
    _hasHadPeer = computeHasHadPeer(
      previous: _hasHadPeer,
      status: next.status,
      participants: next.participants,
    );
    final justJoined = !hadPeerBefore && _hasHadPeer;

    final selfHasVideo = self?.hasVideo;
    if (selfHasVideo == true) _cameraHasBeenEnabled = true;
    final isCameraEnabled = _cameraHasBeenEnabled ? selfHasVideo : null;

    onUpdate(
      AudioVideoCallStateUpdate(
        status: next.status,
        participants: next.participants,
        errorCode: next.errorCode,
        isMicEnabled: self?.hasAudio,
        isCameraEnabled: isCameraEnabled,
        ownRole: next.ownRole,
        hasHadPeer: _hasHadPeer,
        peerJustJoined: justJoined,
        callStartedAt: next.callStartedAt,
      ),
    );
  }

  void _onParticipantEvent(CallParticipantEvent event) {
    if (_isDisposed) return;
    final changeType = event.type == CallParticipantEventType.joined
        ? CallParticipantChangeType.joined
        : CallParticipantChangeType.left;
    onUpdate(
      AudioVideoCallStateUpdate(
        participantEvent: CallParticipantChangeEvent(
          type: changeType,
          count: 1,
        ),
      ),
    );
  }
}
