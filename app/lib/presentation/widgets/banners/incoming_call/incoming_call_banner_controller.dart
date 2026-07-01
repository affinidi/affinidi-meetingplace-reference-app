import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/incoming_call_service/incoming_call_notifier.dart';
import '../../../../application/services/incoming_call_service/incoming_call_service.dart';
import '../../../../application/services/incoming_call_service/incoming_call_state.dart'
    show IncomingCallRinging;
import '../../../../infrastructure/providers/app_logger_provider.dart';

part 'incoming_call_banner_controller.g.dart';

/// Manages intent and state for the incoming call banner.
@riverpod
class IncomingCallBannerController extends _$IncomingCallBannerController {
  static const _logKey = 'IncomingCallBannerController';

  @override
  bool build() {
    ref.read(incomingCallServiceProvider);
    ref.listen(incomingCallProvider, (previous, next) {
      if (next is IncomingCallRinging && next != previous) state = false;
    });
    return false;
  }

  /// Marks the banner as accepted and forwards the accept to
  /// [IncomingCallService].
  void accept({required String callId}) {
    ref.read(appLoggerProvider).info('accept callId=$callId', name: _logKey);
    ref.read(incomingCallServiceProvider.notifier).accept(callId: callId);
    state = true;
  }

  /// Marks the banner as dismissed and forwards the decline to
  /// [IncomingCallService].
  void dismiss({required String callId}) {
    ref.read(appLoggerProvider).info('dismiss callId=$callId', name: _logKey);
    ref.read(incomingCallServiceProvider.notifier).decline(callId: callId);
    state = true;
  }

  /// Resets the banner so it can show again for a new call.
  void reset() => state = false;
}
