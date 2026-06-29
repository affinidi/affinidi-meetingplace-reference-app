import 'dart:async';

import 'package:meeting_place_chat/meeting_place_chat.dart'
    show
        AudioVideoCallSession,
        AudioVideoCallState,
        AudioVideoCallStatus,
        CallMediaType,
        CallRole,
        CallStatus;
import 'package:riverpod/misc.dart' show KeepAliveLink;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../application/services/chat_service/chat_session_service.dart';
import '../../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../screens/chat/audio_video_call/handlers/call_chat_item_handler.dart';
import '../../../screens/chat/audio_video_call/rules/call_chat_item_rules.dart';
import '../../../screens/chat/audio_video_call/rules/call_ui_rules.dart';
import '../end_call/end_call_banner_controller.dart';
import 'active_call_state.dart';

part 'active_call_controller.g.dart';

@riverpod
class ActiveCallController extends _$ActiveCallController {
  static const _logKey = 'ActiveCallController';

  late AppLogger _logger;

  AudioVideoCallSession? _session;
  Timer? _durationTimer;
  StreamSubscription<AudioVideoCallState>? _sessionStateSub;
  CallRole? _ownRole;
  CallChatItemHandler? _chatItemHandler;
  ChatSessionService? _chatService;
  bool _isAudioOnly = false;
  bool _isDisposed = false;

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
  void minimize() {
    final current = state;
    if (current != null) state = current.copyWith(isMinimized: true);
  }

  /// Marks the call as restored, bringing it back to full screen control.
  void restore() {
    final current = state;
    if (current != null) state = current.copyWith(isMinimized: false);
  }

  /// Starts the one-second duration timer. No-op if already running.
  ///
  /// Call this when the first remote participant joins. The timer persists
  /// through minimize/maximize because it lives in the banner controller,
  /// not in the screen controller.
  void startTimer() {
    if (_durationTimer != null) return;
    _logger.info('startTimer: Duration timer started', name: _logKey);
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (current != null) {
        state = current.copyWith(
          callDurationSeconds: current.callDurationSeconds + 1,
        );
      }
    });
  }

  /// Stops the duration timer.
  void stopTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  /// Clears the banner state and releases any retained session reference.
  void clear() {
    if (_isDisposed) return;
    _logger.info('clear: Releasing session', name: _logKey);
    stopTimer();
    _sessionStateSub?.cancel();
    _sessionStateSub = null;
    _session = null;
    _chatItemHandler?.dispose();
    _ownRole = null;
    _chatItemHandler = null;
    _isTerminated = true;
    state = null;
    _keepAliveLink?.close();
    _keepAliveLink = null;
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
  }) {
    _logger.info('registerSession: Banner now owns session', name: _logKey);
    _keepAliveLink ??= ref.keepAlive();
    _isTerminated = false;
    _session = session;

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
    }

    _chatItemHandler?.dispose();
    _chatService = ref.read(chatSessionServiceProvider(channelDid).notifier);
    _isAudioOnly = isAudioOnly;
    _chatItemHandler = CallChatItemHandler(
      onInitiator: _sendOutgoingCallMessage,
      resolveItemId: _resolveCallChatItemId,
      updateItem: _updateCallChatItem,
      isDisposed: () => _isDisposed,
      logger: _logger,
    )..attach(session);
    _sessionStateSub?.cancel();
    _sessionStateSub = session.state.listen(_onSessionState);
  }

  /// Removes the registered session when the call is fully torn down.
  void clearSession() {
    if (_isDisposed) return;
    _logger.info('clearSession: Session released', name: _logKey);
    _sessionStateSub?.cancel();
    _sessionStateSub = null;
    _session = null;
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
      _chatItemHandler?.endCallChatItem(
        outcome: current.hasHadPeer
            ? CallEndOutcome.hungUp
            : CallEndOutcome.declined,
        isCaller: _ownRole == CallRole.caller,
        hasHadPeer: current.hasHadPeer,
        callDuration: Duration(seconds: current.callDurationSeconds),
      );
    }
    if (session != null) unawaited(session.hangUp());
    clear();
  }

  /// Hangs up the live session when the call screen is disposed mid-call
  /// (e.g. the user navigates back before answering).
  ///
  /// [role] seeds the call role so the chat item resolves to the
  /// correct end status even when the banner never observed the session's
  /// ownRole (the screen was disposed before it minimized).
  void hangUpFromScreen({required CallRole role}) {
    if (_isDisposed) return;
    _ownRole ??= role;
    hangUp();
  }

  /// True when call is visible (not in terminal state).
  bool isCallVisible(ActiveCallState? callState) {
    if (callState == null) return false;
    return !isEndedCallStatus(callState.status) &&
        callState.status != AudioVideoCallStatus.idle;
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

    final hadRemote = computeHasHadPeer(
      previous: current.hasHadPeer,
      participants: sessionState.participants,
      status: sessionState.status,
    );
    final peerJustJoined = !current.hasHadPeer && hadRemote;

    state = current.copyWith(
      status: sessionState.status,
      hasHadPeer: hadRemote,
      selfParticipant: sessionState.participants
          .where((p) => p.isSelf)
          .firstOrNull,
    );

    if (peerJustJoined) startTimer();

    if (isEndedCallStatus(sessionState.status)) {
      _chatItemHandler?.endCallChatItem(
        outcome:
            (sessionState.status == AudioVideoCallStatus.declined ||
                sessionState.status == AudioVideoCallStatus.missed ||
                !hadRemote)
            ? CallEndOutcome.declined
            : CallEndOutcome.hungUp,
        isCaller: _ownRole == CallRole.caller,
        hasHadPeer: hadRemote,
        callDuration: Duration(seconds: current.callDurationSeconds),
      );
      final endState = resolveCallEndState(sessionState.status);
      if (endState != null && current.isMinimized) {
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

  Future<String?> _sendOutgoingCallMessage() {
    final mediaType = _isAudioOnly ? CallMediaType.audio : CallMediaType.video;
    return _chatService!.sendOutgoingCallMessage(mediaType: mediaType);
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
    return _chatService!.updateCallChatItem(
      messageId,
      status: status,
      duration: duration,
    );
  }
}
