import 'package:meeting_place_chat/meeting_place_chat.dart'
    show
        AudioVideoCallPlugin,
        AudioVideoCallSession,
        AudioVideoCallStatus,
        CallMediaType;

import '../../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../audio_video_call_screen_state.dart';
import '../call_lifecycle_update.dart';
import '../rules/call_chat_item_rules.dart';
import '../rules/call_ui_rules.dart';

/// Handles outgoing call lifecycle transitions: join, cancel, leave, and hang
/// up.
///
/// Reads current call context from caller-supplied parameters and drives the
/// plugin/session. All resulting state changes are reported through `onUpdate`
/// as a single `CallLifecycleUpdate`, mirroring `CallMediaToggleHandler` and
/// `CallSessionHandler`.
///
/// Plain Dart class with no Riverpod dependency — unit-testable without a
/// ProviderContainer.
class CallLifecycleHandler {
  CallLifecycleHandler({
    required this._logger,
    required this._channelDid,
    required this._getState,
    required this._getPlugin,
    required this._getSession,
    required this._setSession,
    required this._onUpdate,
  });

  static const _logKey = 'CallLifecycleHandler';

  final AppLogger _logger;
  final String? _channelDid;
  final AudioVideoCallScreenState Function() _getState;
  final AudioVideoCallPlugin? Function() _getPlugin;
  final AudioVideoCallSession? Function() _getSession;
  final void Function(AudioVideoCallSession? session) _setSession;
  final void Function(CallLifecycleUpdate update) _onUpdate;

  /// Initiates a new outgoing call to the contact and attaches the session.
  Future<void> joinCall() async {
    if (!_canStartNewCall()) return;

    final plugin = _getPlugin();
    if (plugin == null) {
      _logger.warning('joinCall: Plugin not available', name: _logKey);
      _onUpdate(const CallLifecycleUpdate(status: AudioVideoCallStatus.error));
      return;
    }

    final channelDid = _channelDid;
    if (channelDid == null) {
      _logger.warning('joinCall: Contact has no channelDid', name: _logKey);
      _onUpdate(const CallLifecycleUpdate(status: AudioVideoCallStatus.error));
      return;
    }

    await _startPluginCall(plugin, channelDid);
  }

  /// Cancels an outgoing call that has not yet been answered.
  Future<void> cancelCall() async {
    try {
      await _getPlugin()?.leaveCurrentCall();
      _setSession(null);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to cancel call cleanly',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
    } finally {
      final hasHadPeer = _getState().hasHadPeer;
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
      await _getPlugin()?.leaveCurrentCall();
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

  /// Requests the plugin to start a call and emit either the attached session
  /// or an error status.
  Future<void> _startPluginCall(
    AudioVideoCallPlugin plugin,
    String channelDid,
  ) async {
    const speakerphoneEnabled = true;
    _onUpdate(
      const CallLifecycleUpdate(
        status: AudioVideoCallStatus.connecting,
        isSpeakerEnabled: speakerphoneEnabled,
      ),
    );
    try {
      final session = await plugin.startCall(
        otherPartyChannelDid: channelDid,
        mediaType: _getState().isAudioOnly
            ? CallMediaType.audio
            : CallMediaType.video,
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
      _onUpdate(const CallLifecycleUpdate(status: AudioVideoCallStatus.error));
    }
  }
}
