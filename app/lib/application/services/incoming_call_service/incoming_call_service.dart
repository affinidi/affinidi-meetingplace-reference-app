import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/meeting_place_sdk_provider.dart';
import '../../../infrastructure/services/call_audio_session_service/call_audio_session_service.dart';
import '../chat_service/chat_session_service.dart';
import '../contacts_service/contacts_service.dart';
import 'incoming_call_notifier.dart';
import 'incoming_call_state.dart';

part 'incoming_call_service.g.dart';

@Riverpod(keepAlive: true)
class IncomingCallService extends _$IncomingCallService
    with WidgetsBindingObserver {
  static const _logKey = 'INCOMINGCALLSVC';

  late final _logger = ref.read(appLoggerProvider);

  Timer? _ringTimer;

  @override
  void build() {
    _logger.info('Incoming call service initialized', name: _logKey);
    WidgetsBinding.instance.addObserver(this);
    ref.listen(
      meetingPlaceSdkProvider,
      (_, next) => _bindToSDK(next.value),
      fireImmediately: true,
    );

    ref.listen(incomingCallProvider, (_, next) {
      if (next is IncomingCallIdle) _cancelRingTimer();
    });

    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _cancelRingTimer();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reconcileRingOnResume();
  }

  /// Accepts the incoming call and stops ringing.
  ///
  /// The incoming-call state is intentionally left intact so the call screen
  /// can detect recipient context on first build and initialize UI accordingly.
  /// The call screen clears it after consuming.
  void accept({required String callId}) {
    _logger.info('Accepting call: $callId', name: _logKey);
    _cancelRingTimer();
    final channelDid = ref
        .read(incomingCallProvider)
        .eventOrNull
        ?.otherPartyPermanentChannelDid;
    if (channelDid != null) {
      unawaited(
        ref
            .read(contactsServiceProvider.notifier)
            .clearPendingMissedCall(channelDid),
      );
    }
    _ensureSDK((sdk) => unawaited(_acceptCall(sdk, callId: callId)));
  }

  /// Declines the incoming call and marks it as missed in the chat history.
  void decline({required String callId}) {
    _logger.info('Declining call: $callId', name: _logKey);
    final channelDid = ref
        .read(incomingCallProvider)
        .eventOrNull
        ?.otherPartyPermanentChannelDid;
    _clearRingState();
    _ensureSDK((sdk) => unawaited(sdk.declineCall(callId: callId)));
    if (channelDid != null) {
      unawaited(_markCallAsMissed(channelDid, callId: callId));
    }
  }

  void _bindToSDK(MeetingPlaceMatrixSDK? sdk) {
    if (sdk == null) {
      _logger.warning('SDK not ready yet', name: _logKey);
      return;
    }
    _logger.info('Binding to SDK, listening for incoming calls', name: _logKey);
    final incomingSub = sdk.incomingCalls.listen(_onIncomingCall);
    final cancelledSub = sdk.cancelledCalls.listen(_onCallCancelled);
    ref.onDispose(incomingSub.cancel);
    ref.onDispose(cancelledSub.cancel);
  }

  void _onCallCancelled(IncomingAudioVideoCallEvent event) {
    _logger.info('Caller cancelled call: ${event.callId}', name: _logKey);
    final incomingEvent = ref.read(incomingCallProvider).eventOrNull;
    final channelDid = incomingEvent?.otherPartyPermanentChannelDid;

    if (incomingEvent != null && incomingEvent.callId == event.callId) {
      // Active ringing call was cancelled.
      _clearRingState();
      if (channelDid != null) {
        unawaited(_markCallAsMissed(channelDid, callId: event.callId));
      } else {
        _logger.warning(
          'Skip markCallAsMissed: otherPartyChannelDid null for '
          '${event.callId}',
          name: _logKey,
        );
      }
    } else {
      // No matching active ring — caller's DID is in callerPermanentChannelDid.
      // Do NOT use channelDid here: that holds the active call's contact DID
      // and would mark the wrong contact for a busy auto-reject from a third
      // party.
      _logger.info(
        'No active ring for ${event.callId} — recording missed-call marker '
        'for ${event.callerPermanentChannelDid}',
        name: _logKey,
      );
      unawaited(
        _markCallAsMissed(
          event.callerPermanentChannelDid,
          callId: event.callId,
        ),
      );
    }
  }

  void _onIncomingCall(IncomingAudioVideoCallEvent event) {
    final log = 'Incoming call received: ${event.callerPermanentChannelDid}';
    _logger.info(log, name: _logKey);
    ref.read(incomingCallProvider.notifier).set(event);
    _startRingTimer(event.callId);
  }

  void _startRingTimer(String callId) {
    _ringTimer?.cancel();
    _ringTimer = Timer(
      ref.read(environmentProvider).callRingTimeout,
      () => _handleRingTimeout(callId),
    );
  }

  void _handleRingTimeout(String callId) {
    _logger.info('Ring timeout reached for $callId, declining', name: _logKey);
    final channelDid = ref
        .read(incomingCallProvider)
        .eventOrNull
        ?.otherPartyPermanentChannelDid;
    _clearRingState();
    _ensureSDK((sdk) => unawaited(sdk.declineCall(callId: callId)));
    if (channelDid != null) {
      unawaited(_markCallAsMissed(channelDid, callId: callId));
    }
  }

  /// Reconciles a ring that may have expired while the app was backgrounded.
  ///
  /// Background suspends the ring timer's countdown, so on resume the banner
  /// can linger for a call that already ended. Elapsed time is measured against
  /// the event's [IncomingAudioVideoCallEvent.invitedAt] arrival instant, which
  /// keeps the check correct across background gaps and clock/timezone changes.
  /// When the ring duration has passed the timeout, this runs the same
  /// missed-call cleanup so the banner clears and the chat item reconciles to
  /// missed; otherwise it re-arms the timer for the remaining time.
  void _reconcileRingOnResume() {
    final event = ref.read(incomingCallProvider).eventOrNull;
    if (event == null) return;

    final timeout = ref.read(environmentProvider).callRingTimeout;
    final rawElapsed = clock.now().difference(event.invitedAt);
    final elapsed = rawElapsed.isNegative ? Duration.zero : rawElapsed;
    if (elapsed >= timeout) {
      _logger.info(
        'Ring for ${event.callId} expired while backgrounded, cleaning up',
        name: _logKey,
      );
      _handleRingTimeout(event.callId);
    } else {
      _ringTimer?.cancel();
      _ringTimer = Timer(
        timeout - elapsed,
        () => _handleRingTimeout(event.callId),
      );
    }
  }

  void _clearRingState() {
    _logger.warning('Clearing incoming call state', name: _logKey);
    _cancelRingTimer();
    ref.read(incomingCallProvider.notifier).clear();
  }

  void _cancelRingTimer() {
    _logger.warning('Cancelling ring timer', name: _logKey);
    _ringTimer?.cancel();
    _ringTimer = null;
  }

  Future<void> _acceptCall(
    MeetingPlaceMatrixSDK sdk, {
    required String callId,
  }) async {
    final mediaType = ref.read(incomingCallProvider).eventOrNull?.mediaType;
    final acquiredAudioSession = await ref
        .read(callAudioSessionServiceProvider.notifier)
        .acquire(isAudioOnly: mediaType == CallMediaType.audio);
    if (!acquiredAudioSession) {
      _logger.warning(
        'accept: Failed to acquire OS audio focus/session',
        name: _logKey,
      );
    }

    try {
      await sdk.acceptCall(callId: callId);
    } catch (e, stackTrace) {
      await ref.read(callAudioSessionServiceProvider.notifier).release();
      _logger.error(
        'accept: Failed to accept call $callId',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
      rethrow;
    }
  }

  MeetingPlaceMatrixSDK? get _sdk => ref.read(meetingPlaceSdkProvider).value;

  /// Runs [action] with the active SDK, or logs a warning if not yet loaded.
  void _ensureSDK(void Function(MeetingPlaceMatrixSDK sdk) action) {
    final sdk = _sdk;
    if (sdk == null) {
      _logger.warning('SDK not available', name: _logKey);
      return;
    }
    _logger.info('Executing action with SDK', name: _logKey);
    action(sdk);
  }

  /// Records the missed incoming call: sets the durable marker so the chat item
  /// can be reconciled to `missed`, and heals it immediately via the chat
  /// session when open. The marker survives restart for event-driven
  /// reconciliation on the next chat open.
  ///
  /// The unread badge is not bumped here: the incoming call arrives as a chat
  /// message that already advances the channel sequence number, so the missed
  /// call is counted by the normal unread path. Bumping it again would
  /// double-count.
  Future<void> _markCallAsMissed(String contactId, {String? callId}) async {
    _logger.warning('Marking call as missed for $contactId', name: _logKey);
    try {
      await ref
          .read(contactsServiceProvider.notifier)
          .setPendingMissedCall(contactId, callId: callId);
    } catch (e, stackTrace) {
      _logger.error(
        '_markCallAsMissed: Recording missed call failed for $contactId',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
    try {
      await ref
          .read(chatSessionServiceProvider(contactId).notifier)
          .markCallAsMissed(callId: callId);
    } catch (e, stackTrace) {
      _logger.error(
        '_markCallAsMissed: Chat item update failed for $contactId',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
  }
}
