import 'dart:async';

import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallSession, AudioVideoCallState;

import '../../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../audio_video_call_screen_state.dart';
import '../audio_video_call_state_update.dart';
import '../rules/call_ui_rules.dart';

/// Manages the lifecycle of a single [AudioVideoCallSession] stream.
///
/// Subscribes to [AudioVideoCallSession.state], converts each emission into an
/// [AudioVideoCallStateUpdate], and passes it to [onUpdate]. Also owns the
/// call-duration timer and tracks remote participant identity to emit
/// join/leave events.
///
/// Plain Dart class with no Riverpod dependency — unit-testable without a
/// ProviderContainer.
class CallSessionHandler {
  CallSessionHandler({
    required this.logger,
    required this.logKey,
    required this.onUpdate,
  });

  final AppLogger logger;
  final String logKey;
  final void Function(AudioVideoCallStateUpdate update) onUpdate;

  StreamSubscription<AudioVideoCallState>? _sub;
  bool _isDisposed = false;

  bool _hasHadPeer = false;
  Set<String> _knownRemoteIdentities = {};
  bool _remotesInitialized = false;
  bool _cameraHasBeenEnabled = false;

  /// Subscribes to [session] state. Cancels any existing subscription first.
  ///
  /// The session's state stream replays its latest value on subscribe, so the
  /// handler receives the current state immediately. This closes the race where
  /// a transient state (e.g. the one carrying ownRole) was published before
  /// this handler attached.
  void attach(AudioVideoCallSession session) {
    _sub?.cancel();
    _sub = session.state.listen(_onSessionState);
  }

  /// Cancels the stream subscription.
  void dispose() {
    _isDisposed = true;
    _sub?.cancel();
    _sub = null;
  }

  /// Converts a raw [AudioVideoCallState] into an [AudioVideoCallStateUpdate]
  /// and forwards it to [onUpdate].
  void _onSessionState(AudioVideoCallState next) {
    if (_isDisposed) {
      logger.info('_onSessionState: skipping, handler disposed', name: logKey);
      return;
    }

    final self = next.participants.where((p) => p.isSelf).firstOrNull;

    // The latch is owned by the rules module: once a real peer has joined
    // during a live status it stays true. peerJustJoined marks the single
    // emission where it flips, used to start the duration timer exactly once.
    final hadPeerBefore = _hasHadPeer;
    _hasHadPeer = computeHasHadPeer(
      previous: _hasHadPeer,
      participants: next.participants,
      status: next.status,
    );
    final justJoined = !hadPeerBefore && _hasHadPeer;
    final participantEvent = _resolveParticipantEvent(next);

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
        participantEvent: participantEvent,
        ownRole: next.ownRole,
        hasHadPeer: _hasHadPeer,
        peerJustJoined: justJoined,
      ),
    );
  }

  /// Diffs the remote participant set and returns a join or leave event, or
  /// null if nothing changed or the call is not yet active.
  CallParticipantChangeEvent? _resolveParticipantEvent(
    AudioVideoCallState next,
  ) {
    final isLive = isLiveCallStatus(next.status);
    if (!isLive) {
      _knownRemoteIdentities = {};
      _remotesInitialized = false;
      return null;
    }

    final nextRemotes = next.participants
        .where((p) => !p.isSelf)
        .map((p) => p.participantId)
        .toSet();

    if (!_remotesInitialized) {
      _remotesInitialized = true;
      _knownRemoteIdentities = nextRemotes;
      return null;
    }

    final joined = nextRemotes.difference(_knownRemoteIdentities);
    final left = _knownRemoteIdentities.difference(nextRemotes);
    _knownRemoteIdentities = nextRemotes;

    if (joined.isNotEmpty) {
      return CallParticipantChangeEvent(
        type: CallParticipantChangeType.joined,
        count: joined.length,
      );
    }
    if (left.isNotEmpty) {
      return CallParticipantChangeEvent(
        type: CallParticipantChangeType.left,
        count: left.length,
      );
    }
    return null;
  }
}
