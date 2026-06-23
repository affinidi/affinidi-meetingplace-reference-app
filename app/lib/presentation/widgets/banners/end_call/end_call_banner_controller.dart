import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../infrastructure/loggers/app_logger/app_logger.dart';
import '../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../screens/chat/audio_video_call/rules/call_ui_rules.dart';
import 'end_call_banner_state.dart';

part 'end_call_banner_controller.g.dart';

@riverpod
class EndCallBannerController extends _$EndCallBannerController {
  static const _logKey = 'EndCallBannerController';

  late AppLogger _logger;

  /// Auto-dismiss after 3 seconds.
  static const Duration _autoDismissDuration = Duration(seconds: 3);

  /// Swipe-out animation duration.
  static const Duration _swipeOutDuration = Duration(milliseconds: 200);

  /// Animation frame interval (60 fps).
  static const Duration _frameInterval = Duration(milliseconds: 16);

  Timer? _autoDismissTimer;
  Timer? _swipeOutAnimationTimer;
  DateTime? _swipeOutStartTime;

  @override
  EndCallBannerState? build() {
    _logger = ref.read(appLoggerProvider);
    return null;
  }

  /// Shows the banner with the outcome of a missed or declined call.
  void show({
    required String contactId,
    required String peerName,
    required CallEndState endState,
    required bool isAudioOnly,
  }) {
    _logger.info('show: Displaying end-call banner ($endState)', name: _logKey);
    state = EndCallBannerState(
      contactId: contactId,
      peerName: peerName,
      endState: endState,
      isAudioOnly: isAudioOnly,
    );
    _startAutoDismissTimer();
  }

  /// Called when the user swipes up on the banner. Animates the banner out
  /// and then dismisses it.
  void onSwipeUp() {
    _logger.info('onSwipeUp: Animating banner out', name: _logKey);
    _autoDismissTimer?.cancel();
    _animateOut();
  }

  /// Dismisses the banner.
  void dismiss() {
    _logger.info('dismiss: Clearing end-call banner', name: _logKey);
    _autoDismissTimer?.cancel();
    _swipeOutAnimationTimer?.cancel();
    state = null;
  }

  void _startAutoDismissTimer() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(_autoDismissDuration, dismiss);
  }

  /// Animates the banner sliding out upward over 400ms.
  void _animateOut() {
    _swipeOutAnimationTimer?.cancel();
    _swipeOutStartTime = DateTime.now();

    _swipeOutAnimationTimer = Timer.periodic(_frameInterval, (_) {
      if (state == null) {
        _swipeOutAnimationTimer?.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(_swipeOutStartTime!);
      final progress =
          (elapsed.inMilliseconds / _swipeOutDuration.inMilliseconds).clamp(
            0.0,
            1.0,
          );

      state = state!.copyWith(slideOutOffset: progress);

      if (progress >= 1.0) {
        _swipeOutAnimationTimer?.cancel();
        dismiss();
      }
    });
  }
}
