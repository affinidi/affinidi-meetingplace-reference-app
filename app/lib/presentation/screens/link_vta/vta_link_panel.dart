import 'package:flutter/material.dart';

import 'vta_link_content.dart';

/// The linking steps on the blue of onboarding, as a card that fits the
/// settings drawer.
class VtaLinkPanel extends StatelessWidget {
  const VtaLinkPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: vtaLinkGradient(
        context,
        radius: 2,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: VtaLinkContent(),
      ),
    );
  }
}
