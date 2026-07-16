import 'package:meeting_place_matrix/meeting_place_matrix.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/providers/app_logger_provider.dart';
import 'incoming_call_state.dart';

part 'incoming_call_notifier.g.dart';

/// Service that owns the current [IncomingCallState].
@Riverpod(keepAlive: true)
class IncomingCallNotifier extends _$IncomingCallNotifier {
  static const _logKey = 'IncomingCallNotifier';

  late final _logger = ref.read(appLoggerProvider);

  @override
  IncomingCallState build() => const IncomingCallState.idle();

  void set(IncomingAudioVideoCallEvent event) {
    _logger.info(
      'set: Incoming call from ${event.otherPartyPermanentChannelDid}',
      name: _logKey,
    );
    state = IncomingCallState.ringing(event);
  }

  void clear() {
    _logger.info('clear: Clearing incoming call state', name: _logKey);
    state = const IncomingCallState.idle();
  }
}
