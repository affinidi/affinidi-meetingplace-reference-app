import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

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

  /// Badge dedup id for the in-flight missed call of each contact, generated
  /// once when the incoming call arrives and reused by every terminal signal of
  /// that same call.
  ///
  /// A missed group call terminates on this device twice: once locally (the
  /// ring times out or is declined) and once when the caller broadcasts
  /// `call-decline` to the group channel. The broadcast re-reports the same
  /// call, but its transport call id falls back to the group DID rather than
  /// the room id used locally, so the two signals cannot be matched by their
  /// transport id. A per-call episode id generated at ring time lets both
  /// signals credit the badge under one key so the call counts once. It is
  /// generated fresh per incoming call, so two sequential calls that reuse the
  /// same transport room id still count as two. The trailing broadcast consumes
  /// it; a cancel that beats its own invite has no entry and counts on its own
  /// fresh id.
  final Map<String, String> _missEpisodeIdByContact = {};

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

  /// Declines the incoming call and marks it as declined in the chat history.
  void decline({required String callId}) {
    _logger.info('Declining call: $callId', name: _logKey);
    final channelDid = ref
        .read(incomingCallProvider)
        .eventOrNull
        ?.otherPartyPermanentChannelDid;
    _clearRingState();
    _ensureSDK((sdk) => unawaited(sdk.declineCall(callId: callId)));
    if (channelDid != null) {
      unawaited(
        _markCallAsDeclined(
          channelDid,
          callId: callId,
          missId: _missEpisodeIdByContact[channelDid] ?? const Uuid().v4(),
        ),
      );
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
        unawaited(
          _markCallAsMissed(
            channelDid,
            callId: event.callId,
            missId: _missEpisodeIdByContact[channelDid] ?? const Uuid().v4(),
          ),
        );
      } else {
        _logger.warning(
          'Skip markCallAsMissed: otherPartyChannelDid null for '
          '${event.callId}',
          name: _logKey,
        );
      }
    } else {
      unawaited(
        _markUnmatchedCancelledCallAsMissed(
          event,
          hasDifferentActiveRing: incomingEvent != null,
        ),
      );
    }
  }

  void _onIncomingCall(IncomingAudioVideoCallEvent event) {
    final log = 'Incoming call received: ${event.callerPermanentChannelDid}';
    _logger.info(log, name: _logKey);
    final restartedOwnCallId = event.restartedOwnCallId;
    if (restartedOwnCallId != null) {
      unawaited(
        _redactSupersededOutgoingCall(
          event.otherPartyPermanentChannelDid,
          callId: restartedOwnCallId,
        ),
      );
    }
    // Start a fresh missed-call episode for this ring. Every terminal signal of
    // this call (local timeout/decline and the caller's trailing `call-decline`
    // broadcast) credits the badge under this one id.
    _missEpisodeIdByContact[event.otherPartyPermanentChannelDid] = const Uuid()
        .v4();
    ref.read(incomingCallProvider.notifier).set(event);
    _startRingTimer(event.callId);
  }

  /// Redacts this device's own outgoing call item for [callId] with
  /// [contactId] after a lost call glare, so it doesn't linger once the
  /// winning call proceeds.
  Future<void> _redactSupersededOutgoingCall(
    String contactId, {
    required String callId,
  }) async {
    _logger.info(
      'Glare loss: redacting own outgoing call $callId for $contactId',
      name: _logKey,
    );
    try {
      await ref
          .read(chatSessionServiceProvider(contactId).notifier)
          .redactSupersededOutgoingCall(callId);
    } catch (e, stackTrace) {
      _logger.error(
        '_redactSupersededOutgoingCall: failed for $contactId/$callId',
        error: e,
        stackTrace: stackTrace,
        name: _logKey,
      );
    }
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
      unawaited(
        _markCallAsMissed(
          channelDid,
          callId: callId,
          missId: _missEpisodeIdByContact[channelDid] ?? const Uuid().v4(),
        ),
      );
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

  /// Records the missed incoming call: bumps the recipient's unread badge
  /// (keyed by [missId] so a call counts once and distinct calls each count),
  /// sets the durable marker so the chat item can be reconciled to `missed`,
  /// and heals it immediately via the chat session when open.
  ///
  /// [missId] is the badge dedup key: the per-call episode id, so the two
  /// terminal signals of one missed call — the local ring timeout/decline and
  /// the caller's trailing `call-decline` broadcast — credit the same call once
  /// (see [_missEpisodeIdByContact]). It is null for unmatched cancels that are
  /// recorded only as chat markers, such as a busy auto-reject of a third
  /// party.
  Future<void> _markCallAsMissed(
    String contactId, {
    String? callId,
    String? missId,
  }) {
    _logger.warning('Marking call as missed for $contactId', name: _logKey);
    return _recordTerminalIncomingCall(
      contactId,
      status: CallStatus.missed,
      writeChatItemBeforeMarker: false,
      logLabel: '_markCallAsMissed',
      callId: callId,
      missId: missId,
    );
  }

  /// Records the actively declined incoming call: bumps the recipient's unread
  /// badge and writes the chat item as [CallStatus.declined] so the transcript
  /// distinguishes an active decline from a plain timeout.
  ///
  /// Unlike [_markCallAsMissed], the chat item is written first and the durable
  /// pending-call marker is set after. Setting the marker is a persist that
  /// yields the event loop; a concurrent stale-item heal would otherwise settle
  /// the still-ringing item to `missed` before the declined write lands,
  /// leaving it stuck on "Missed". The write-failure safety net is preserved:
  /// if the declined write fails, the marker still reconciles the item to
  /// `missed`.
  ///
  /// [missId] is the badge dedup key; see [_markCallAsMissed] for details.
  Future<void> _markCallAsDeclined(
    String contactId, {
    String? callId,
    String? missId,
  }) {
    _logger.warning('Marking call as declined for $contactId', name: _logKey);
    return _recordTerminalIncomingCall(
      contactId,
      status: CallStatus.declined,
      writeChatItemBeforeMarker: true,
      logLabel: '_markCallAsDeclined',
      callId: callId,
      missId: missId,
    );
  }

  /// Shared recorder behind [_markCallAsMissed] and [_markCallAsDeclined]:
  /// bumps the missed-call badge, writes the chat item for [status], and sets
  /// the durable pending-call marker.
  ///
  /// [writeChatItemBeforeMarker] controls whether the chat item write or the
  /// marker set runs first; this ordering is load-bearing. [_markCallAsMissed]
  /// passes `false` (marker first). [_markCallAsDeclined] passes `true` (chat
  /// item first) because setting the marker is a persist that yields the
  /// event loop, and a concurrent stale-item heal would otherwise settle the
  /// still-ringing item to `missed` before the declined write lands, leaving
  /// it stuck on "Missed". The write-failure safety net still applies either
  /// way: if the chat item write fails, the marker still reconciles the item.
  Future<void> _recordTerminalIncomingCall(
    String contactId, {
    required CallStatus status,
    required bool writeChatItemBeforeMarker,
    required String logLabel,
    String? callId,
    String? missId,
  }) async {
    // A failed bump leaves the episode's id uncredited on the durable marker
    // (lastCreditedMissId stays behind pendingMissedCallMissId), so the derived
    // "owed" stays true and reconciliation replays the credit; otherwise the
    // unread count would stay permanently short by one. No flag to track: owed
    // is derived from the durable marker, and a successful bump records the
    // credited id in the same write.
    if (missId != null) {
      try {
        await ref
            .read(contactsServiceProvider.notifier)
            .incrementMissedCallBadge(contactId, callId: missId);
      } catch (e, stackTrace) {
        _logger.error(
          '$logLabel: Badge bump failed for $contactId',
          error: e,
          stackTrace: stackTrace,
          name: _logKey,
        );
      }
    }

    Future<void> writeChatItem() async {
      try {
        if (status == CallStatus.declined) {
          await ref
              .read(chatSessionServiceProvider(contactId).notifier)
              .markCallAsDeclined(callId: callId);
        } else {
          await ref
              .read(chatSessionServiceProvider(contactId).notifier)
              .markCallAsMissed(callId: callId);
        }
      } catch (e, stackTrace) {
        _logger.error(
          '$logLabel: Chat item update failed for $contactId',
          error: e,
          stackTrace: stackTrace,
          name: _logKey,
        );
      }
    }

    Future<void> setMarker() async {
      try {
        await ref
            .read(contactsServiceProvider.notifier)
            .setPendingMissedCall(contactId, callId: callId, missId: missId);
      } catch (e, stackTrace) {
        _logger.error(
          status == CallStatus.declined
              ? '$logLabel: CRITICAL — pending marker write failed '
                    'for $contactId; call item cannot reconcile to '
                    'missed on replay'
              : '$logLabel: CRITICAL — missed-call marker write failed '
                    'for $contactId; call item cannot reconcile to '
                    'missed on replay',
          error: e,
          stackTrace: stackTrace,
          name: _logKey,
        );
      }
    }

    if (writeChatItemBeforeMarker) {
      await writeChatItem();
      await setMarker();
    } else {
      await setMarker();
      await writeChatItem();
    }
  }

  Future<void> _markUnmatchedCancelledCallAsMissed(
    IncomingAudioVideoCallEvent event, {
    required bool hasDifferentActiveRing,
  }) async {
    if (hasDifferentActiveRing) {
      // Busy auto-reject: a third party called while the user was already on a
      // call. Record the chat marker for that caller, but do not badge a call
      // the user was too busy to take.
      _logger.info(
        'Busy auto-reject for ${event.callId} — recording missed-call marker '
        'for ${event.callerPermanentChannelDid} without a badge',
        name: _logKey,
      );
      await _markCallAsMissed(
        event.callerPermanentChannelDid,
        callId: event.callId,
      );
      return;
    }

    // No active ring existed: the cancel arrived before the incoming banner was
    // emitted. This is common for the first call in a group, where the
    // control-plane decline can beat the ring. It is a genuine missed call, so
    // badge the caller. `callerPermanentChannelDid` keys the contact for both
    // cases: for a group it is the group channel DID, for a 1:1 the peer DID.
    // (The receiving `otherPartyPermanentChannelDid` is this device's own
    // channel DID, so it never resolves to a contact and must not be used.)
    await ref.read(contactsServiceProvider.notifier).ensureInitialized();
    if (!ref.mounted) return;

    final targetChannelDid = event.callerPermanentChannelDid;
    // When the transport could not resolve a call id it falls back to the
    // caller DID; do not persist that as a real per-call id marker.
    final isDidFallbackCallId = event.callId == event.callerPermanentChannelDid;

    // If a ring for this contact was already handled locally (timeout, decline,
    // or matched cancel), this unmatched cancel is the caller's trailing
    // `call-decline` broadcast for the SAME call, re-reported with a group-DID
    // fallback id. Consume that call's episode id so it credits the badge under
    // the same key and counts once. A cancel that beat its own invite has no
    // episode (its ring never showed), so it counts on a fresh id.
    final episodeId = _resolveMissEpisodeId(
      isGroupFallback: isDidFallbackCallId,
      contactId: targetChannelDid,
      callId: event.callId,
    );

    _logger.info(
      'No active ring for ${event.callId} — badging missed call for '
      '$targetChannelDid',
      name: _logKey,
    );
    await _markCallAsMissed(
      targetChannelDid,
      callId: isDidFallbackCallId ? null : event.callId,
      missId: episodeId,
    );
  }

  String _resolveMissEpisodeId({
    required bool isGroupFallback,
    required String contactId,
    required String callId,
  }) {
    if (isGroupFallback) {
      // Group broadcast: bridge to the ring's episode id (fallback id can't
      // match the local room-id credit); absent means a fresh id.
      return _missEpisodeIdByContact.remove(contactId) ?? const Uuid().v4();
    }
    // Real per-call id: dedup directly; don't consume the episode id, which
    // belongs to a different (ring-shown) call.
    return callId;
  }
}
