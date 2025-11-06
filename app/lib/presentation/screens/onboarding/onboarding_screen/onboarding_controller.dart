import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';

import '../../../../application/services/settings_service/settings_service.dart';
import 'onboarding_state.dart';

part 'onboarding_controller.g.dart';

@riverpod
class OnboardingController extends _$OnboardingController {
  final PageController pageController = PageController();

  static const _videoAssets = [
    'assets/videos/welcome1-small.mp4',
    'assets/videos/welcome2-small.mp4',
    'assets/videos/welcome3-small.mp4',
    'assets/videos/welcome4-small.mp4',
  ];

  @override
  OnboardingState build() {
    ref.onDispose(_dispose);

    return const OnboardingState(isLoading: true);
  }

  Future<void> initialize() async {
    try {
      final videoPlayerControllers = <VideoPlayerController>[];
      for (final video in _videoAssets) {
        final videoPlayerController = VideoPlayerController.asset(
          video,
          videoPlayerOptions: VideoPlayerOptions(
            mixWithOthers: true,
            allowBackgroundPlayback: true,
          ),
        );
        await videoPlayerController.initialize();
        await videoPlayerController.setLooping(true);
        videoPlayerControllers.add(videoPlayerController);
      }

      await videoPlayerControllers.first.play();

      state = state.copyWith(
        videoPlayerControllers: videoPlayerControllers,
        currentPage: 0,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  void onPageChanged(int page) {
    final videoPlayerControllers = state.videoPlayerControllers;
    if (videoPlayerControllers.isEmpty) return;

    videoPlayerControllers[state.currentPage].pause();
    videoPlayerControllers[page].play();

    state = state.copyWith(currentPage: page);
  }

  void onFinishOnboarding() async {
    final settingsService = ref.read(settingsServiceProvider.notifier);
    await settingsService.setAlreadyOnboarded(true);
  }

  void _dispose() {
    pageController.dispose();
    for (final videoPlayerController in state.videoPlayerControllers) {
      videoPlayerController.dispose();
    }
  }
}
