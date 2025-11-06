import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:video_player/video_player.dart';

part 'onboarding_state.freezed.dart';

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default([]) List<VideoPlayerController> videoPlayerControllers,
    @Default(0) int currentPage,
    @Default(false) bool isLoading,
    Object? error,
  }) = _OnboardingState;
}
