import 'dart:async';

import 'package:clock/clock.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';

import '../../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../rules/call_chat_item_rules.dart';
import '../rules/call_ui_rules.dart';

/// Owns the full lifecycle of a call chat item, driven entirely by the
/// session's [AudioVideoCallSession.state] stream.
///
/// A single handler per call:
///   - emits the outgoing item exactly once when this device is the caller,
///   - advances the persisted status (calling → ringing → in-progress) as the
///     call progresses, using [resolveInProgressCallChatItemStatus],
///   - writes the terminal status exactly once when the call ends, using the
///     caller role and peer history it tracked off the stream.
///
/// Consumers only [attach] the session and, on a local teardown that races the
/// stream, call [endCall] before disposing. All status resolution lives here so
/// the foreground screen and the minimized banner can never disagree.
///
/// Plain Dart class — no Riverpod dependency. Fully testable in isolation.
class CallChatItemHandler {
  CallChatItemHandler({
    this._onInitiator,
    required this._resolveItemId,
    required this._updateItem,
    required this._isDisposed,
    required this._logger,
  });

  static const _logKey = 'CallChatItemHandler';

  final Future<String?> Function(String callId)? _onInitiator;
  final Future<String?> Function({required bool isCaller}) _resolveItemId;
  final Future<void> Function(
    String messageId, {
    required CallStatus status,
    Duration? duration,
  })
  _updateItem;
  final bool Function() _isDisposed;
  final AppLogger _logger;

  StreamSubscription<AudioVideoCallState>? _sub;
  String? _callChatItemId;
  bool _callChatItemEnded = false;
  Future<void>? _endCallWrite;

  bool _roleResolved = false;
  bool _isCaller = false;
  bool _hasHadPeer = false;
  DateTime? _callStartedAt;
  String? _sessionCallId;
  CallStatus? _lastWrittenStatus;
  AudioVideoCallStatus _lastStatus = AudioVideoCallStatus.idle;

  /// The message id of the emitted call chat item, or null if not yet resolved.
  String? get callChatItemId => _callChatItemId;

  /// Whether the terminal status has already been written.
  bool get callChatItemEnded => _callChatItemEnded;

  /// The in-flight end-call chat item write, or null if none has started.
  /// Lets callers await the final write before tearing down dependencies it
  /// relies on (e.g. the chat session).
  Future<void>? get endCallWrite => _endCallWrite;

  /// Subscribes to [session] state and drives the chat item through its whole
  /// lifecycle. Cancels any existing subscription first.
  void attach(AudioVideoCallSession session) {
    _sub?.cancel();
    _sub = session.state.listen(
      _onSessionState,
      onDone: () {
        if (_onInitiator != null && !_roleResolved) {
          _logger.warning(
            'attach: Session stream ended before ownRole was determined; '
            'outgoing call chat item will not be emitted',
            name: _logKey,
          );
        }
      },
    );
  }

  /// Cancels the session subscription. Safe to call multiple times.
  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  /// Writes the terminal status now, resolving the outcome from the state
  /// tracked off the stream. Idempotent.
  ///
  /// Used on a local teardown (hang up) that disposes this handler before the
  /// stream delivers its terminal status. [assumeRole] supplies the caller role
  /// for the edge case where the stream never reported `ownRole` (e.g. the user
  /// backs out of an outgoing call before it connects).
  void endCall({CallRole? assumeRole}) {
    if (assumeRole != null && !_roleResolved) {
      _isCaller = assumeRole == CallRole.caller;
    }
    _writeTerminalStatus(_lastStatus);
  }

  void _onSessionState(AudioVideoCallState next) {
    if (_isDisposed()) return;

    _resolveRoleAndEmit(next.ownRole, next.callId);

    _lastStatus = next.status;
    _hasHadPeer = computeHasHadPeer(
      previous: _hasHadPeer,
      status: next.status,
      participants: next.participants,
    );
    _callStartedAt ??= next.callStartedAt;

    if (isEndedCallStatus(next.status)) {
      _writeTerminalStatus(next.status);
      return;
    }

    final status = resolveInProgressCallChatItemStatus(
      status: next.status,
      hasHadPeer: _hasHadPeer,
    );
    if (status != null && status != _lastWrittenStatus) {
      _lastWrittenStatus = status;
      _writeInProgressStatus(status);
    }
  }

  /// Detects the caller role once and emits the outgoing item if this device
  /// initiated the call.
  void _resolveRoleAndEmit(CallRole? ownRole, String? callId) {
    if (_roleResolved || ownRole == null) return;
    _sessionCallId ??= callId;
    if (ownRole == CallRole.caller && _sessionCallId == null) return;
    _roleResolved = true;
    _isCaller = ownRole == CallRole.caller;

    if (!_isCaller) {
      _logger.info(
        'callChatItemHandler: recipient, not emitting; '
        'caller item arrives over the wire',
        name: _logKey,
      );
      return;
    }
    if (_onInitiator == null) return;

    _logger.info(
      'callChatItemHandler: caller, emitting call chat item',
      name: _logKey,
    );
    unawaited(
      _onInitiator(_sessionCallId!).then((id) {
        if (id != null) _callChatItemId ??= id;
      }),
    );
  }

  void _writeInProgressStatus(CallStatus status) {
    unawaited(
      Future(() async {
        if (_isDisposed() || _callChatItemEnded) return;
        final messageId = await _resolveId();
        if (messageId == null || _callChatItemEnded || _isDisposed()) {
          _logger.info(
            'updateCallChatItemStatus: Skipping update '
            '(messageId=$messageId, ended=$_callChatItemEnded)',
            name: _logKey,
          );
          return;
        }
        await _updateItem(messageId, status: status);
      }),
    );
  }

  void _writeTerminalStatus(AudioVideoCallStatus terminalStatus) {
    if (_callChatItemEnded) return;
    _callChatItemEnded = true;

    final outcome = resolveCallEndOutcome(
      lastStatus: terminalStatus,
      hasHadPeer: _hasHadPeer,
    );
    final isCaller = _isCaller;
    final hasHadPeer = _hasHadPeer;
    final callDuration = _elapsedCallDuration();

    _endCallWrite = Future(() async {
      if (_isDisposed()) {
        _logger.info(
          'endCallChatItem: Skipping, controller disposed',
          name: _logKey,
        );
        return;
      }
      final messageId = await _resolveId(isCaller: isCaller);
      if (messageId == null || _isDisposed()) {
        _logger.info(
          'endCallChatItem: Skipping update (messageId=$messageId)',
          name: _logKey,
        );
        return;
      }
      final endStatus = resolveEndStatus(outcome: outcome, isFromMe: isCaller);
      await _updateItem(
        messageId,
        status: endStatus,
        duration: (endStatus == CallStatus.ended && hasHadPeer)
            ? callDuration
            : null,
      );
    });
    unawaited(_endCallWrite);
  }

  Duration _elapsedCallDuration() {
    final start = _callStartedAt;
    if (start == null) return Duration.zero;
    return clock.now().difference(start);
  }

  /// Resolves and caches the call chat item message ID, inferring role
  /// from the caller flag if needed.
  Future<String?> _resolveId({bool isCaller = false}) async {
    if (_callChatItemId != null) return _callChatItemId;
    final resolved = await _resolveItemId(isCaller: isCaller);
    _callChatItemId = resolved;
    return resolved;
  }
}
