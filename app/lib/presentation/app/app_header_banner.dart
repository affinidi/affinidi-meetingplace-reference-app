import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../widgets/banners/active_call/active_call_banner.dart';
import '../widgets/banners/active_call/active_call_controller.dart';
import '../widgets/banners/end_call/end_call_banner.dart';
import '../widgets/banners/end_call/end_call_banner_controller.dart';
import '../widgets/banners/incoming_call_banner.dart';
import '../widgets/banners/no_connection_banner.dart';
import '../widgets/call/video_call_pip_overlay.dart';
import '../widgets/call_ended/call_ended_overlay.dart';

class AppHeaderBanner extends ConsumerWidget {
  const AppHeaderBanner({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(activeCallControllerProvider);
    final activeCallBannerActive = callState != null && callState.isMinimized;

    final endCallState = ref.watch(endCallBannerControllerProvider);
    final endCallBannerActive = endCallState != null;

    final bannerActive = activeCallBannerActive || endCallBannerActive;
    final bannerHeight = switch ((
      activeCallBannerActive,
      endCallBannerActive,
    )) {
      (true, _) => ActiveCallBanner.height,
      (_, true) => EndCallBanner.height,
      _ => 0.0,
    };

    final originalMq = context.mediaQuery;
    final inflatedMq = bannerActive
        ? originalMq.copyWith(
            padding: originalMq.padding.copyWith(
              top: originalMq.padding.top + bannerHeight,
            ),
          )
        : originalMq;

    final bannerColor = activeCallBannerActive
        ? context.customColors.success
        : context.colorScheme.error;

    return Stack(
      children: [
        MediaQuery(data: inflatedMq, child: child),
        if (bannerActive)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: originalMq.padding.top,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: bannerColor,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
              child: ColoredBox(color: bannerColor),
            ),
          ),
        if (activeCallBannerActive)
          Positioned(
            top: originalMq.padding.top,
            left: 0,
            right: 0,
            height: ActiveCallBanner.height,
            child: const ActiveCallBanner(),
          ),
        if (endCallBannerActive)
          Positioned(
            top: originalMq.padding.top,
            left: 0,
            right: 0,
            height: EndCallBanner.height,
            child: const EndCallBanner(),
          ),
        Positioned(
          top: originalMq.padding.top + bannerHeight,
          left: 0,
          right: 0,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [NoConnectionBanner(), IncomingCallBanner()],
          ),
        ),
        const VideoCallPiPOverlay(),
        const CallEndedOverlay(),
      ],
    );
  }
}
