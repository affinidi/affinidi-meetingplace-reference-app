import 'dart:async';

import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:riverpod/misc.dart' show KeepAliveLink;
import 'package:riverpod/riverpod.dart' show ProviderSubscription;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../application/services/chat_service/chat_session_service.dart';
import '../../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../screens/chat/audio_video_call/handlers/call_chat_item_handler.dart';
import '../../../screens/chat/audio_video_call/rules/call_ui_rules.dart';
import '../../call_ended/call_ended_controller.dart';
import '../end_call/end_call_banner_controller.dart';
import 'active_call_state.dart';

part 'active_call_controller.g.dart';

@riverpod
class ActiveCallController extends _$ActiveCallController {
  static const _logKey = 'ActiveCallController';

  late AppLogger _logger;

  AudioVideoCallSession? _session;
  Timer? _durationTimer;
  DateTime? _callStartedAt;
  StreamSubscription<AudioVideoCallState>? _sessionStateSub;
  StreamSubscription<CallParticipantEvent>? _participantEventSub;
  CallRole? _ownRole;
  CallChatItemHandler? _chatItemHandler;
  ChatSessionService? _chatService;
  ProviderSubscription<Object?>? _chatServiceSub;
  bool _isAudioOnly = false;
  bool _isDisposed = false;
  bool _isGroupContact = false;

  // Pins this controller alive for the lifetime of a call so its instance
  // (and the terminated guard below) survive the dismiss window, instead of
  // being torn down the moment the banner widget stops watching it. Closed in
  // clear() so the controller frees itself once the call is fully over.
  KeepAliveLink? _keepAliveLink;

  // Set once the call is fully torn down. Blocks late state syncs from the
  // screen controller (which can remain alive behind the PiP overlay) from
  // resurrecting a dismissed banner. Reset when a fresh call begins.
  bool _isTerminated = false;

  @override
  ActiveCallState? build() {
    _logger = ref.read(appLoggerProvider);
    ref.onDispose(() {
      _isDisposed = true;
      _durationTimer?.cancel();
      _sessionStateSub?.cancel();
      _participantEventSub?.cancel();
      _chatServiceSub?.close();
      _chatServiceSub = null;
    });
    return null;
  }

  /// Updates the banner state with new call information.
  ///
  /// A starting call reopens the banner and clears the terminated guard so a
  /// brand-new call is tracked again. While terminated, late syncs from a
  /// disposing screen controller are ignored so the banner stays dismissed.
  void update(ActiveCallState next) {
    const startupStatuses = {
      AudioVideoCallStatus.connecting,
      AudioVideoCallStatus.outgoingRinging,
      AudioVideoCallStatus.waitingForKeys,
    };
    if (startupStatuses.contains(next.status)) _isTerminated = false;
    if (_isTerminated) return;
    state = next;
  }

  /// Marks the call as minimized, transitioning to banner-only control.
  ///
  /// The screen controller passes its authoritative media state so the banner
  /// (and the PiP overlay) reflect any audio-to-video switch that happened
  /// while the screen was open, without waiting for the next session event.
  void minimize({
    required String contactId,
    required AudioVideoCallStatus status,
    required String peerName,
    required bool isAudioOnly,
    required bool isCameraEnabled,
    required bool isMicEnabled,
    AudioVideoCallParticipant? selfParticipant,
  }) {
    _logger.info('minimize: Updating banner state', name: _logKey);
    final current = state;
    if (current != null) {
      state = current.copyWith(
        isMinimized: true,
        isAudioOnly: isAudioOnly,
        isCameraEnabled: isCameraEnabled,
        selfParticipant: selfParticipant ?? current.selfParticipant,
      );
    } else {
      _keepAliveLink ??= ref.keepAlive();
      state = ActiveCallState(
        contactId: contactId,
        peerName: peerName,
        status: status,
        callDurationSeconds: 0,
        isMicEnabled: isMicEnabled,
        isAudioOnly: isAudioOnly,
        isCameraEnabled: isCameraEnabled,
        isMinimized: true,
        selfParticipant: selfParticipant,
      );
    }
  }

  /// Marks the call as restored, bringing it back to full screen control.
  void restore() {
    _logger.info('restore: Returning call to screen', name: _logKey);
    final current = state;
    if (current != null) state = current.copyWith(isMinimized: false);
  }

  /// Updates banner state when the local user switches from audio-only
  /// to video.
  void switchToVideo() {
    _logger.info('switchToVideo: Updating call media state', name: _logKey);
    final current = state;
    if (current == null) return;
    state = current.copyWith(isAudioOnly: false, isCameraEnabled: true);
  }

  /// Starts timer anchored to [callStartedAt] for synchronized elapsed time
  /// across both parties. Falls back to count-up if null. Persists through
  /// minimize/maximize. No-op if already running.
  void startTimer([DateTime? callStartedAt]) {
    _callStartedAt ??= callStartedAt;
    if (_durationTimer != null) return;
    _logger.info('startTimer: Duration timer started', name: _logKey);

    if (_callStartedAt != null) _tickDuration();
    _durationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tickDuration(),
    );
  }

  /// Stops the duration timer.
  void stopTimer() {
    _logger.info('stopTimer: Duration timer stopped', name: _logKey);
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  /// Clears the banner state and releases any retained session reference.
  void clear() {
    if (_isDisposed) return;
    _logger.info('clear: Releasing session', name: _logKey);
    stopTimer();
    _callStartedAt = null;
    _sessionStateSub?.cancel();
    _sessionStateSub = null;
    _participantEventSub?.cancel();
    _participantEventSub = null;
    _session = null;
    _chatItemHandler?.endCall(assumeRole: _ownRole);
    final pendingEndWrite = _chatItemHandler?.endCallWrite;
    _chatItemHandler?.dispose();
    _ownRole = null;
    _chatItemHandler = null;
    _isTerminated = true;
    state = null;
    _keepAliveLink?.close();
    _keepAliveLink = null;
    _releaseChatServiceAfter(pendingEndWrite);
  }

  /// The live session registered when the screen minimized.
  AudioVideoCallSession? get session => _session;

  /// The message id of the outgoing call chat item emitted by the initiator.
  /// Null until emission completes, and null on the joiner side.
  String? get callChatItemId => _chatItemHandler?.callChatItemId;

  /// Registers the live call session so the banner can control it directly,
  /// independently of the screen controller's lifecycle.
  ///
  /// [channelDid] and [isAudioOnly] are required so the call chat item can
  /// be emitted even if the screen controller disposes before the session's
  /// ownRole arrives (e.g., when the user minimizes immediately after
  /// starting a call).
  void registerSession(
    AudioVideoCallSession session, {
    required String channelDid,
    required bool isAudioOnly,
    required AudioVideoCallStatus initialStatus,
    required String peerName,
    required bool isMicEnabled,
    required bool isMinimized,
    required bool isGroupContact,
  }) {
    _logger.info('registerSession: Banner now owns session', name: _logKey);
    _keepAliveLink ??= ref.keepAlive();
    _isTerminated = false;
    _session = session;
    _callStartedAt = null;

    if (state == null) {
      state = ActiveCallState(
        contactId: channelDid,
        peerName: peerName,
        status: initialStatus,
        callDurationSeconds: 0,
        isMicEnabled: isMicEnabled,
        isAudioOnly: isAudioOnly,
        isMinimized: isMinimized,
      );
    } else {
      state = state!.copyWith(callDurationSeconds: 0, status: initialStatus);
    }

    _chatItemHandler?.dispose();
    _chatService = ref.read(chatSessionServiceProvider(channelDid).notifier);
    _chatServiceSub?.close();
    _chatServiceSub = ref.listen<Object?>(
      chatSessionServiceProvider(channelDid),
      (_, _) {},
    );
    _isAudioOnly = isAudioOnly;
    _isGroupContact = isGroupContact;
    _chatItemHandler = CallChatItemHandler(
      onInitiator: _sendOutgoingCallMessage,
      resolveItemId: _resolveCallChatItemId,
      updateItem: _updateCallChatItem,
      isDisposed: () => _chatService == null,
      logger: _logger,
    )..attach(session);
    _sessionStateSub?.cancel();
    _participantEventSub?.cancel();
    _sessionStateSub = session.state.listen(_onSessionState, onDone: clear);
    _participantEventSub = session.participantEvents.listen(
      _onParticipantEvent,
    );
  }

  /// Removes the registered session when the call is fully torn down.
  void clearSession() {
    if (_isDisposed) return;
    _logger.info('clearSession: Session released', name: _logKey);
    _sessionStateSub?.cancel();
    _sessionStateSub = null;
    _participantEventSub?.cancel();
    _participantEventSub = null;
    _session = null;
  }

  /// Flushes the call chat item to end status before banner teardown.
  /// Called when peer declines off-stream; idempotent if called again.
  Future<void> endCallChatItem({required CallRole role}) async {
    if (_isDisposed) {
      _logger.info(
        'endCallChatItem: Skipped, controller disposed',
        name: _logKey,
      );
      return;
    }
    _logger.info('endCallChatItem: role=$role', name: _logKey);
    _ownRole ??= role;
    _chatItemHandler?.endCall(assumeRole: role);
    await _chatItemHandler?.endCallWrite;
  }

  /// Toggles the microphone on the live session and reflects it in the banner.
  void toggleMic() {
    final current = state;
    final session = _session;
    if (current == null || session == null) {
      _logger.warning('toggleMic: No state or session', name: _logKey);
      return;
    }
    final next = !current.isMicEnabled;
    _logger.info('toggleMic: $next', name: _logKey);
    state = current.copyWith(isMicEnabled: next);
    unawaited(session.setMicrophoneEnabled(next));
  }

  /// Hangs up the live session and dismisses the banner.
  void hangUp() {
    if (_isDisposed) return;
    final session = _session;
    final current = state;
    _logger.info('hangUp: Terminating call', name: _logKey);
    if (current != null) {
      if (current.hasHadPeer) {
        ref
            .read(callEndedControllerProvider.notifier)
            .show(
              contactId: current.contactId,
              peerName: current.peerName,
              callDurationSeconds: current.callDurationSeconds,
              isAudioOnly: current.isAudioOnly,
            );
      }
    }
    if (session != null) unawaited(session.hangUp());
    clear();
  }

  /// Hangs up the live session when the call screen is disposed mid-call
  /// (e.g. the user navigates back before answering).
  ///
  /// [role] sets the call role so the chat item resolves to the
  /// correct end status even when the banner never observed the session's
  /// ownRole (the screen was disposed before it minimized).
  void hangUpFromScreen({required CallRole role}) {
    if (_isDisposed) return;
    _logger.info('hangUpFromScreen: role=$role', name: _logKey);
    _ownRole ??= role;
    hangUp();
  }

  /// True when call is visible (not in ended state).
  bool isCallVisible(ActiveCallState? callState) {
    if (callState == null) return false;
    return !isEndedCallStatus(callState.status) &&
        callState.status != AudioVideoCallStatus.idle;
  }

  // =========================================================================
  // Private helpers
  // =========================================================================

  /// Advances the displayed call duration using the call start time when
  /// available.
  void _tickDuration() {
    final current = state;
    if (current == null) return;
    final anchor = _callStartedAt;
    final seconds = anchor != null
        ? DateTime.now().difference(anchor).inSeconds
        : current.callDurationSeconds + 1;
    state = current.copyWith(callDurationSeconds: seconds < 0 ? 0 : seconds);
  }

  /// Releases the chat session once the final call chat item write completes,
  /// so the session (and its message-routing that advances the unread baseline)
  /// is torn down when the call ends instead of lingering and suppressing the
  /// badge for the next incoming call.
  void _releaseChatServiceAfter(Future<void>? pendingWrite) {
    final subToClose = _chatServiceSub;
    if (subToClose == null) return;
    (pendingWrite ?? Future<void>.value()).whenComplete(() {
      if (!identical(_chatServiceSub, subToClose)) return;

      _chatServiceSub = null;
      _chatService = null;
      subToClose.close();
    });
  }

  /// Ends a minimized 1-on-1 call immediately when the only peer leaves.
  void _onParticipantEvent(CallParticipantEvent event) {
    if (_isDisposed) return;
    if (event.type != CallParticipantEventType.left) return;
    final current = state;
    if (current == null || !current.isMinimized) return;
    if (_isGroupContact) {
      _logger.info(
        '_onParticipantEvent: Peer left group call, call continues',
        name: _logKey,
      );
      return;
    }
    if (!current.hasHadPeer) {
      _logger.warning(
        '_onParticipantEvent: Peer left but hasHadPeer=false, skipping',
        name: _logKey,
      );
      return;
    }
    _logger.info(
      '_onParticipantEvent: Peer left 1-on-1 call, ending call',
      name: _logKey,
    );
    hangUp();
  }

  void _onSessionState(AudioVideoCallState sessionState) {
    // UI-state updates only apply when the screen is not showing.
    // When the screen is open, AudioVideoCallScreenController handles all
    // session events via CallSessionHandler.
    final isMinimized = state?.isMinimized ?? false;
    if (!isMinimized) return;

    if (sessionState.ownRole != null) _ownRole ??= sessionState.ownRole;

    final current = state;
    if (current == null) return;

    final hadPeer = computeHasHadPeer(
      previous: current.hasHadPeer,
      status: sessionState.status,
      participants: sessionState.participants,
    );
    final peerJustJoined = !current.hasHadPeer && hadPeer;

    state = current.copyWith(
      status: sessionState.status,
      hasHadPeer: hadPeer,
      selfParticipant: sessionState.participants
          .where((p) => p.isSelf)
          .firstOrNull,
    );

    if (peerJustJoined) startTimer(sessionState.callStartedAt);

    if (sessionState.callStartedAt != null) {
      startTimer(sessionState.callStartedAt);
    }

    if (isEndedCallStatus(sessionState.status)) {
      final endState = resolveCallEndState(
        sessionState.status,
        hasHadPeer: hadPeer,
      );
      if (endState == CallEndState.callEnded) {
        ref
            .read(callEndedControllerProvider.notifier)
            .show(
              contactId: current.contactId,
              peerName: current.peerName,
              callDurationSeconds: current.callDurationSeconds,
              isAudioOnly: current.isAudioOnly,
            );
      } else if (endState != null) {
        ref
            .read(endCallBannerControllerProvider.notifier)
            .show(
              contactId: current.contactId,
              peerName: current.peerName,
              endState: endState,
              isAudioOnly: current.isAudioOnly,
            );
      }
      clear();
    }
  }

  Future<String?> _sendOutgoingCallMessage(String callId) {
    final mediaType = _isAudioOnly ? CallMediaType.audio : CallMediaType.video;
    return _chatService!.sendOutgoingCallMessage(
      mediaType: mediaType,
      callId: callId,
    );
  }

  Future<String?> _resolveCallChatItemId({required bool isCaller}) {
    return isCaller
        ? _chatService!.resolveOutgoingCallChatItemId()
        : _chatService!.resolveIncomingCallChatItemId();
  }

  Future<void> _updateCallChatItem(
    String messageId, {
    required CallStatus status,
    Duration? duration,
  }) {
    final chatService = _chatService;
    if (chatService == null) {
      _logger.info(
        'updateCallChatItem: Skipped, chat service disposed',
        name: _logKey,
      );
      return Future<void>.value();
    }
    return chatService.updateCallChatItem(
      messageId,
      status: status,
      duration: duration,
    );
  }
}
