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
    if (channelDid != null) _markCallAsMissed(channelDid);
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

  void _onCallCancelled(String callId) {
    _logger.info('Caller cancelled call: $callId', name: _logKey);
    final incomingEvent = ref.read(incomingCallProvider).eventOrNull;
    if (incomingEvent?.callerPermanentChannelDid != callId) {
      _logger.info(
        'Ignore cancelled: active callId does not match $callId',
        name: _logKey,
      );
      return;
    }
    final channelDid = incomingEvent?.otherPartyPermanentChannelDid;
    _clearRingState();
    if (channelDid != null) {
      _markCallAsMissed(channelDid);
    } else {
      _logger.warning(
        'Skip markCallAsMissed: otherPartyChannelDid null for $callId',
        name: _logKey,
      );
    }
  }

  void _onIncomingCall(IncomingAudioVideoCallEvent event) {
    final log = 'Incoming call received: ${event.callerPermanentChannelDid}';
    _logger.info(log, name: _logKey);
    ref.read(incomingCallProvider.notifier).set(event);
    _startRingTimer(event.callerPermanentChannelDid);
  }

  void _startRingTimer(String callId) {
    _ringTimer?.cancel();
    _ringTimer = Timer(
      ref.read(environmentProvider).incomingCallRingTimeout,
      () {
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
        if (channelDid != null) _markCallAsMissed(channelDid);
      },
    );
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

  /// Updates the incoming call chat item to [CallStatus.missed] for the given
  /// [contactId] and increments the contact's unread badge. Runs asynchronously
  /// so the ring state can be cleared first.
  void _markCallAsMissed(String contactId) {
    _logger.warning('Marking call as missed for $contactId', name: _logKey);
    unawaited(
      Future(() async {
        try {
          await ref
              .read(chatSessionServiceProvider(contactId).notifier)
              .markCallAsMissed();
          await ref
              .read(contactsServiceProvider.notifier)
              .incrementMissedCallBadge(contactId);
        } catch (e, stackTrace) {
          _logger.error(
            '_markCallAsMissed failed for $contactId',
            error: e,
            stackTrace: stackTrace,
            name: _logKey,
          );
        }
      }),
    );
  }
}
