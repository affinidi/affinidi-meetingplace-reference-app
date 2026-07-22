import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import 'call_ended_state.dart';

part 'call_ended_controller.g.dart';

@riverpod
class CallEndedController extends _$CallEndedController {
  static const _logKey = 'CallEndedController';

  late AppLogger _logger;

  @override
  CallEndedState? build() {
    _logger = ref.read(appLoggerProvider);
    return null;
  }

  /// Shows the Call Ended screen with peer name and call duration.
  void show({
    required String contactId,
    required String peerName,
    required int callDurationSeconds,
    required bool isAudioOnly,
    String? errorMessage,
  }) {
    _logger.info(
      'show: Displaying Call Ended screen for $peerName '
      '(duration: ${callDurationSeconds}s)',
      name: _logKey,
    );
    state = CallEndedState(
      contactId: contactId,
      peerName: peerName,
      callDurationSeconds: callDurationSeconds,
      isAudioOnly: isAudioOnly,
      errorMessage: errorMessage,
    );
  }

  /// Dismisses the Call Ended screen.
  void dismiss() {
    _logger.info('dismiss: Clearing Call Ended screen', name: _logKey);
    state = null;
  }
}
