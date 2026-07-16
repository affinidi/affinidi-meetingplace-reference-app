import 'dart:async';

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
class IncomingCallService extends _$IncomingCallService {
  static const _logKey = 'INCOMINGCALLSVC';

  late final _logger = ref.read(appLoggerProvider);

  Timer? _ringTimer;

  @override
  void build() {
    _logger.info('Incoming call service initialized', name: _logKey);
    ref.listen(
      meetingPlaceSdkProvider,
      (_, next) => _bindToSDK(next.value),
      fireImmediately: true,
    );

    ref.listen(incomingCallProvider, (_, next) {
      if (next is IncomingCallIdle) _cancelRingTimer();
    });

    ref.onDispose(_cancelRingTimer);
  }

  /// Accepts the incoming call and stops ringing.
  ///
  /// The incoming-call state is intentionally left intact so the call screen
  /// can detect callee context on first build and initialize UI accordingly.
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
    if (channelDid != null) unawaited(_markCallAsMissed(channelDid));
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
        unawaited(_markCallAsMissed(channelDid));
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
        _markCallAsMissed(event.callerPermanentChannelDid, bumpBadge: false),
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
    _ringTimer = Timer(ref.read(environmentProvider).callRingTimeout, () {
      _logger.info(
        'Ring timeout reached for $callId, declining',
        name: _logKey,
      );
      final channelDid = ref
          .read(incomingCallProvider)
          .eventOrNull
          ?.otherPartyPermanentChannelDid;
      _clearRingState();
      _ensureSDK((sdk) => unawaited(sdk.declineCall(callId: callId)));
      if (channelDid != null) unawaited(_markCallAsMissed(channelDid));
    });
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

  /// Records the missed incoming call: bumps the unread badge, sets the durable
  /// marker so the chat item can be reconciled to `missed`, and heals it
  /// immediately via the chat session when open. The marker survives restart
  /// for event-driven reconciliation on the next chat open.
  ///
  /// The badge is bumped explicitly because call events are `mpx.call.invite` /
  /// `mpx.call.item`, not `m.room.message`, so they never advance the channel
  /// sequence number and the seqNo-derived unread path does not count them.
  /// [ContactsService.incrementMissedCallBadge] is idempotent per unread
  /// episode and skips the bump while the chat is open, so a call that raises
  /// more than one missed signal on this device is still counted once.
  ///
  /// [bumpBadge] is false for a busy auto-reject of a third party while already
  /// in another call: that call is only recorded in the chat log, without an
  /// unread badge, so an incidental auto-reject does not surface a badge.
  Future<void> _markCallAsMissed(
    String contactId, {
    bool bumpBadge = true,
  }) async {
    _logger.warning('Marking call as missed for $contactId', name: _logKey);
    if (bumpBadge) {
      try {
        await ref
            .read(contactsServiceProvider.notifier)
            .incrementMissedCallBadge(contactId);
      } catch (e, stackTrace) {
        _logger.error(
          '_markCallAsMissed: Badge bump failed for $contactId',
          error: e,
          stackTrace: stackTrace,
          name: _logKey,
        );
      }
    }
    try {
      await ref
          .read(contactsServiceProvider.notifier)
          .setPendingMissedCall(contactId);
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
          .markCallAsMissed();
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
