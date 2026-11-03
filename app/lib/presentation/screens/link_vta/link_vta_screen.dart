import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/vtc_service/vta_link_service.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';
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

    return OnboardingLayout(
      // Spin while the router leaves, rather than flash the linked state.
      child: isActive
          ? const Center(child: OnboardingSpinner())
          : const VtaLinkContent(),
    );
  }
}
