import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import 'onboarding_controller.dart';

class _OnboardingPageContent {
  const _OnboardingPageContent({
    required this.title,
    required this.description,
  });
  final String title;
  final String description;
}

class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({super.key});

  List<_OnboardingPageContent> _buildPages(BuildContext context) {
    return [
      _OnboardingPageContent(
        title: context.l10n.onboardingPage1Title,
        description: context.l10n.onboardingPage1Desc,
      ),
      _OnboardingPageContent(
        title: context.l10n.onboardingPage2Title,
        description: context.l10n.onboardingPage2Desc,
      ),
      _OnboardingPageContent(
        title: context.l10n.onboardingPage3Title,
        description: context.l10n.onboardingPage3Desc,
      ),
      _OnboardingPageContent(
        title: context.l10n.onboardingPage4Title,
        description: context.l10n.onboardingPage4Desc,
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    useEffect(() {
      if (!context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.initialize();
      });

      return null;
    }, []);

    if (state.isLoading || state.videoPlayerControllers.isEmpty) {
      return const Scaffold(backgroundColor: Colors.black, body: SizedBox());
    }

    final pages = _buildPages(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: state.videoPlayerControllers.length,
            scrollBehavior: const ScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            itemBuilder: (context, index) {
              final videoPlayerController = state.videoPlayerControllers[index];
              return Stack(
                children: [
                  SizedBox.expand(
                    child: ClipRect(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: videoPlayerController.value.size.width,
                          height: videoPlayerController.value.size.height,
                          child: VideoPlayer(videoPlayerController),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 160,
                          left: 20,
                          right: 20,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              pages[index].title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(3, 3),
                                    blurRadius: 15.0,
                                    color: Colors.black,
                                  ),
                                ],
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              pages[index].description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(3, 3),
                                    blurRadius: 15.0,
                                    color: Colors.black,
                                  ),
                                ],
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: SmoothPageIndicator(
                controller: controller.pageController,
                count: state.videoPlayerControllers.length,
                effect: const WormEffect(
                  dotColor: Colors.white30,
                  activeDotColor: Colors.white,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            ),
          ),
          if (state.currentPage == state.videoPlayerControllers.length - 1)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: controller.onFinishOnboarding,
                  child: SizedBox(
                    width: 200,
                    child: Text(
                      context.l10n.setUpMyIdentity,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
