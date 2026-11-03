import 'package:flutter/material.dart';

import '../../widgets/onboarding_style/onboarding_style.dart';
import 'vta_link_content.dart';

/// The linking steps on the blue of onboarding, as a card that fits the
/// settings drawer.
class VtaLinkPanel extends StatelessWidget {
  const VtaLinkPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: onboardingGradient(
        context,
        radius: 2,
        borderRadius: BorderRadius.circular(16),
      ),
      // The settings route has no Scaffold: without a Material, text falls
      // back to the underlined debug style and buttons have no ink.
      child: const Material(
        type: MaterialType.transparency,
        child: Padding(padding: EdgeInsets.all(20), child: VtaLinkContent()),
      ),
    );
  }
}
