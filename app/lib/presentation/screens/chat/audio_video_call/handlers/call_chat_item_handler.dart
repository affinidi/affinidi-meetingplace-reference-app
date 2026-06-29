import 'dart:async';

import 'package:meeting_place_chat/meeting_place_chat.dart'
    show AudioVideoCallSession, AudioVideoCallState, CallRole, CallStatus;

import '../../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../rules/call_chat_item_rules.dart';

/// Manages the full lifecycle of the call chat item: one-time creation when
/// this device is the caller, and subsequent status updates through
/// to the final terminal write.
///
/// Pass onInitiator to enable the emission phase (banner/initiator path).
/// Omit it when the handler is used purely for updates (screen controller path
/// that seeds the id via seedCallChatItemId).
///
/// Owns the idempotency flag and the cached message-id so both
/// AudioVideoCallScreenController and ActiveCallController share the same
/// resolution logic without duplication.
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

  final Future<String?> Function()? _onInitiator;
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

  /// The message id of the emitted call chat item, or null if not yet resolved.
  String? get callChatItemId => _callChatItemId;

  /// Whether [endCallChatItem] has already been called.
  bool get callChatItemEnded => _callChatItemEnded;

  /// Seeds the message id directly (e.g. when the screen controller reads the
  /// id from the banner controller before the banner clears).
  void seedCallChatItemId(String id) => _callChatItemId ??= id;

  /// Subscribes to session state to detect the caller role and emit the
  /// outgoing call chat item exactly once via onInitiator.
  ///
  /// No-op if onInitiator was not provided at construction.
  void attach(AudioVideoCallSession session) {
    if (_onInitiator == null) return;
    _sub?.cancel();
    _sub = session.state.listen(_onSessionState);
  }

  /// Cancels the session subscription. Safe to call multiple times.
  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  /// Detects the caller role and emits the call chat item exactly once.
  Future<void> _onSessionState(AudioVideoCallState state) async {
    final ownRole = state.ownRole;
    if (ownRole == null) return;

    await _sub?.cancel();
    _sub = null;

    if (ownRole == CallRole.recipient) {
      _logger.info(
        'callChatItemHandler: recipient, not emitting; '
        'caller item arrives over the wire',
        name: _logKey,
      );
      return;
    }

    _logger.info(
      'callChatItemHandler: caller, emitting call chat item',
      name: _logKey,
    );
    _callChatItemId = await _onInitiator?.call();
  }

  /// Updates the call chat item to an in-progress [status].
  ///
  /// No-op if the item has already been ended or if the message id cannot
  /// be resolved. The update runs in a [Future] so callers can fire-and-forget.
  void updateCallChatItemStatus(CallStatus status) {
    if (_callChatItemEnded) {
      _logger.info(
        'updateCallChatItemStatus: Skipping, item already ended',
        name: _logKey,
      );
      return;
    }
    unawaited(
      Future(() async {
        if (_isDisposed()) {
          _logger.info(
            'updateCallChatItemStatus: Skipping, controller disposed',
            name: _logKey,
          );
          return;
        }
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

  /// Writes the final call status to the call chat item exactly once.
  ///
  /// Subsequent calls are no-ops (idempotent). The update runs in a [Future]
  /// so callers can fire-and-forget.
  void endCallChatItem({
    required CallEndOutcome outcome,
    required bool isCaller,
    required bool hasHadPeer,
    required Duration callDuration,
  }) {
    if (_callChatItemEnded) {
      _logger.info(
        'endCallChatItem: Skipping, item already ended',
        name: _logKey,
      );
      return;
    }
    _callChatItemEnded = true;

    unawaited(
      Future(() async {
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
            'endCallChatItem: Skipping update '
            '(messageId=$messageId)',
            name: _logKey,
          );
          return;
        }
        final endStatus = resolveEndStatus(
          outcome: outcome,
          isFromMe: isCaller,
        );
        await _updateItem(
          messageId,
          status: endStatus,
          duration: (endStatus == CallStatus.ended && hasHadPeer)
              ? callDuration
              : null,
        );
      }),
    );
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
