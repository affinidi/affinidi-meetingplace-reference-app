import 'dart:async';

import 'package:mpx_app_core/mpx_app_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/configuration/environment.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/providers/audio_video_call_plugin_provider.dart';
import '../../../infrastructure/providers/incoming_call_state_provider.dart';
import '../chat_service/chat_session_service.dart';

part 'incoming_call_service.g.dart';

@Riverpod(keepAlive: true)
class IncomingCallService extends _$IncomingCallService {
  static const _logKey = 'INCOMINGCALLSVC';

  late final _logger = ref.read(appLoggerProvider);

  Timer? _ringTimer;

  @override
  void build() {
    ref.listen(
      audioVideoCallPluginProvider,
      (_, next) => _bindToPlugin(next.value),
      fireImmediately: true,
    );

    ref.listen(incomingCallStateProvider, (_, next) {
      if (next == null) _cancelRingTimer();
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
    _ensurePlugin((plugin) => unawaited(plugin.acceptCall(callId: callId)));
  }

  /// Declines the incoming call and marks it as missed in the chat history.
  void decline({required String callId}) {
    _logger.info('Declining call: $callId', name: _logKey);
    final channelDid = ref
        .read(incomingCallStateProvider)
        ?.otherPartyChannelDid;
    _clearRingState();
    _ensurePlugin((plugin) => unawaited(plugin.declineCall(callId: callId)));
    if (channelDid != null) _markCallAsMissed(channelDid);
  }

  void _bindToPlugin(AudioVideoCallPlugin? plugin) {
    if (plugin == null) return;
    final incomingSub = plugin.incomingCalls.listen(_onIncomingCall);
    final cancelledSub = plugin.cancelledCalls.listen(_onCallCancelled);
    ref.onDispose(incomingSub.cancel);
    ref.onDispose(cancelledSub.cancel);
  }

  void _onCallCancelled(String callId) {
    _logger.info('Caller cancelled call: $callId', name: _logKey);
    final incomingState = ref.read(incomingCallStateProvider);
    if (incomingState?.callId == callId) _clearRingState();
    _markCallAsMissed(callId);
  }

  void _onIncomingCall(IncomingAudioVideoCallEvent event) {
    _logger.info('Incoming call received: ${event.callId}', name: _logKey);
    ref.read(incomingCallStateProvider.notifier).set(event);
    _startRingTimer(event.callId);
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
            .read(incomingCallStateProvider)
            ?.otherPartyChannelDid;
        _clearRingState();
        _ensurePlugin(
          (plugin) => unawaited(plugin.declineCall(callId: callId)),
        );
        if (channelDid != null) _markCallAsMissed(channelDid);
      },
    );
  }

  void _clearRingState() {
    _cancelRingTimer();
    ref.read(incomingCallStateProvider.notifier).clear();
  }

  void _cancelRingTimer() {
    _ringTimer?.cancel();
    _ringTimer = null;
  }

  AudioVideoCallPlugin? get _plugin =>
      ref.read(audioVideoCallPluginProvider).value;

  /// Runs [action] with the active call plugin, or logs a warning if no
  /// plugin is registered. Never fails silently.
  void _ensurePlugin(void Function(AudioVideoCallPlugin plugin) action) {
    final plugin = _plugin;
    if (plugin == null) {
      _logger.warning('Call plugin not available', name: _logKey);
      return;
    }
    action(plugin);
  }

  /// Updates the incoming call chat item to [CallStatus.missed] for the given
  /// [contactId]. Runs asynchronously so the ring state can be cleared first.
  void _markCallAsMissed(String contactId) {
    unawaited(
      Future(() async {
        try {
          await ref
              .read(chatSessionServiceProvider(contactId).notifier)
              .markCallAsMissed();
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
