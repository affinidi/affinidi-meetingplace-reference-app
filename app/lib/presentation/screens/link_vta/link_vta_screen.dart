import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/vtc_service/vta_link_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../helpers/screensize_helper.dart';
import 'vta_link_content.dart';
import 'vta_link_screen_controller.dart';

/// Asks the member to link their VTA before they use the app, in the look
/// of onboarding. The router leaves this screen once the link is active.
class LinkVtaScreen extends ConsumerWidget {
  const LinkVtaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = ref.watch(
      vtaLinkScreenControllerProvider.select(
        (screen) => screen.link.status == VtaLinkStatus.active,
      ),
    );

    return _OnboardingLayout(
      // Spin while the router leaves, rather than flash the linked state.
      child: isActive
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : const VtaLinkContent(),
    );
  }
}

/// The blue gradient, logo header and footer of onboarding, around a
/// scrolling [child].
class _OnboardingLayout extends StatelessWidget {
  const _OnboardingLayout({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isSmallLandscape =
        ScreensizeHelper().isSmallScreen(context) &&
        ScreensizeHelper().isLandscape(context);
    final radius = media.size.width > 1024 ? 6.0 : 2.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: DecoratedBox(
        decoration: vtaLinkGradient(context, radius: radius),
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    media.size.height -
                    media.padding.top -
                    media.padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: isSmallLandscape ? 24 : 48),
                    SizedBox(
                      height: isSmallLandscape ? 64 : 96,
                      child: Image.asset(
                        'assets/images/meeting-place-splash-white-1024.png',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.appName,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: isSmallLandscape ? 24 : 40),
                    child,
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 24,
                        bottom: isSmallLandscape ? 16 : 32,
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 40,
                          child: Image.asset(
                            'assets/images/powered_by_mpx.png',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
