import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../../../infrastructure/services/call_audio_session_service/call_audio_session_service.dart';
import '../audio_video_call_screen_state.dart';
import '../call_lifecycle_update.dart';
import '../rules/call_chat_item_rules.dart';
import '../rules/call_ui_rules.dart';

/// Handles outgoing call lifecycle transitions: join, cancel, leave, and hang
/// up.
///
/// Reads current call context from caller-supplied parameters and drives the
/// SDK/session. All resulting state changes are reported through `onUpdate`
/// as a single `CallLifecycleUpdate`, mirroring `CallMediaToggleHandler` and
/// `CallSessionHandler`.
///
/// Plain Dart class with no Riverpod dependency — unit-testable without a
/// ProviderContainer.
class CallLifecycleHandler {
  CallLifecycleHandler({
    required this._logger,
    required this._channelDid,
    required this._audioSessionService,
    required this._getState,
    required this._getSDK,
    required this._getSession,
    required this._setSession,
    required this._onUpdate,
  });

  static const _logKey = 'CallLifecycleHandler';

  final AppLogger _logger;
  final String? _channelDid;
  final CallAudioSessionService _audioSessionService;
  final AudioVideoCallScreenState Function() _getState;
  final MeetingPlaceMatrixSDK? Function() _getSDK;
  final AudioVideoCallSession? Function() _getSession;
  final void Function(AudioVideoCallSession? session) _setSession;
  final void Function(CallLifecycleUpdate update) _onUpdate;

  /// Initiates a new outgoing call to the contact and attaches the session.
  Future<void> joinCall() async {
    if (!_canStartNewCall()) return;

    final sdk = _getSDK();
    if (sdk == null) {
      _logger.warning('joinCall: SDK not available', name: _logKey);
      _onUpdate(const CallLifecycleUpdate(status: AudioVideoCallStatus.error));
      return;
    }

    final channelDid = _channelDid;
    if (channelDid == null) {
      _logger.warning('joinCall: Contact has no channelDid', name: _logKey);
      _onUpdate(const CallLifecycleUpdate(status: AudioVideoCallStatus.error));
      return;
    }

    await _startSDKCall(sdk, channelDid);
  }

  /// Cancels an outgoing call that has not yet been answered.
  Future<void> cancelCall() async {
    final hasHadPeer = _getState().hasHadPeer;
    try {
      await _getSDK()?.leaveCurrentCall();
      _setSession(null);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to cancel call cleanly',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
    } finally {
      await _audioSessionService.release();
      _onUpdate(
        CallLifecycleUpdate(
          status: AudioVideoCallStatus.ended,
          clearIncomingCall: true,
          endOutcome: hasHadPeer
              ? CallEndOutcome.hungUp
              : CallEndOutcome.declined,
        ),
      );
    }
  }

  /// Ends the active call and transitions to ended state.
  Future<void> leaveCall() async {
    try {
      await _getSDK()?.leaveCurrentCall();
      _setSession(null);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to hang up call cleanly',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      _onUpdate(const CallLifecycleUpdate(reportHangUpFailure: true));
    } finally {
      await _audioSessionService.release();
      _onUpdate(
        const CallLifecycleUpdate(
          status: AudioVideoCallStatus.ended,
          clearIncomingCall: true,
        ),
      );
    }
  }

  /// Cancels if still ringing/connecting, otherwise leaves an active call.
  Future<void> hangUp() async {
    final status = _getState().status;
    if (status == AudioVideoCallStatus.outgoingRinging ||
        status == AudioVideoCallStatus.connecting) {
      await cancelCall();
      return;
    }
    await leaveCall();
  }

  /// Tears down an outgoing call that the peer explicitly declined and
  /// transitions to the declined end-state so the UI shows the decline screen.
  Future<void> onPeerDeclined() async {
    _setSession(null);
    await _audioSessionService.release();
    _onUpdate(
      const CallLifecycleUpdate(
        status: AudioVideoCallStatus.declined,
        clearIncomingCall: true,
        endOutcome: CallEndOutcome.declined,
      ),
    );
  }

  /// Returns `true` if the call can start; blocks if already in progress or
  /// a session is pre-accepted.
  bool _canStartNewCall() {
    if (isCallInProgress(_getState().status)) {
      _logger.warning('joinCall: Already in progress', name: _logKey);
      return false;
    }
    if (_getSession() != null) {
      _logger.info('joinCall: Using pre-accepted session', name: _logKey);
      return false;
    }
    return true;
  }

  /// Requests the SDK to start a call and emit either the attached session
  /// or an error status.
  Future<void> _startSDKCall(
    MeetingPlaceMatrixSDK sdk,
    String channelDid,
  ) async {
    final isAudioOnly = _getState().isAudioOnly;
    const speakerphoneEnabled = false;
    final acquiredAudioSession = await _audioSessionService.acquire(
      isAudioOnly: isAudioOnly,
    );
    if (!acquiredAudioSession) {
      _logger.warning(
        'joinCall: Failed to acquire OS audio focus/session',
        name: _logKey,
      );
    }
    _onUpdate(
      const CallLifecycleUpdate(
        status: AudioVideoCallStatus.connecting,
        isSpeakerEnabled: speakerphoneEnabled,
      ),
    );
    try {
      final session = await sdk.startCall(
        otherPartyChannelDid: channelDid,
        mediaType: isAudioOnly ? CallMediaType.audio : CallMediaType.video,
      );
      _setSession(session);
      await session.setSpeakerphoneEnabled(speakerphoneEnabled);
      _onUpdate(CallLifecycleUpdate(attachedSession: session));
    } catch (e, stackTrace) {
      _logger.error(
        'joinCall: StartCall failed',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      await _audioSessionService.release();
      _onUpdate(const CallLifecycleUpdate(status: AudioVideoCallStatus.error));
    }
  }
}
