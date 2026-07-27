import 'dart:async';

import 'package:meeting_place_matrix/meeting_place_matrix.dart'
    show CallMediaType;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/incoming_call_service/incoming_call_notifier.dart';
import '../../../../application/services/incoming_call_service/incoming_call_service.dart';
import '../../../../application/services/incoming_call_service/incoming_call_state.dart'
    show IncomingCallRinging;
import '../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../../navigation/navigator.dart';
import '../../../../navigation/routes/dashboard_routes.dart';
import '../../../screens/chat/audio_video_call/audio_video_call_screen_controller.dart';
import '../end_call/end_call_banner_controller.dart';

part 'incoming_call_banner_controller.g.dart';

/// Manages intent and state for the incoming call banner.
@riverpod
class IncomingCallBannerController extends _$IncomingCallBannerController {
  static const _logKey = 'IncomingCallBannerController';

  @override
  bool build() {
    ref.read(incomingCallServiceProvider);
    ref.listen(incomingCallProvider, (previous, next) {
      if (next is IncomingCallRinging && next != previous) {
        ref.read(endCallBannerControllerProvider.notifier).dismiss();
        state = false;
      }
    });
    return false;
  }

  /// Hides the banner for the current incoming call without declining it.
  void hide({required String callId}) {
    ref.read(appLoggerProvider).info('hide callId=$callId', name: _logKey);
    state = true;
  }

  /// Declines the incoming call and hides the banner.
  void dismiss({required String callId}) {
    ref
        .read(appLoggerProvider)
        .info('dismiss and decline callId=$callId', name: _logKey);
    ref.read(incomingCallServiceProvider.notifier).decline(callId: callId);
    state = true;
  }

  /// Resets the banner so it can show again for a new call.
  void reset() {
    ref.read(appLoggerProvider).info('reset', name: _logKey);
    state = false;
  }

  /// Accepts a fresh incoming call and navigates to the call screen.
  void accept({
    required String callId,
    required String otherPartyChannelDid,
    required CallMediaType mediaType,
    required String? contactId,
  }) {
    ref.read(appLoggerProvider).info('accept callId=$callId', name: _logKey);
    ref.read(incomingCallServiceProvider.notifier).accept(callId: callId);
    state = true;

    final routeContactId = contactId ?? otherPartyChannelDid;
    final isAudioOnly = mediaType == CallMediaType.audio;
    ref
        .read(navigatorProvider)
        .go(
          AudioVideoCallRoute(
            contactId: routeContactId,
            isAudioOnly: isAudioOnly,
          ).location,
        );
  }

  /// Accepts a re-invite from a peer restarting the call.
  void acceptRecall({
    required String callId,
    required String contactId,
    required bool isAudioOnly,
  }) {
    ref
        .read(appLoggerProvider)
        .info('acceptRecall callId=$callId', name: _logKey);
    ref.read(incomingCallServiceProvider.notifier).accept(callId: callId);
    state = true;
    unawaited(
      ref
          .read(audioVideoCallScreenControllerProvider(contactId).notifier)
          .acceptRecall(isAudioOnly: isAudioOnly),
    );
  }
}
