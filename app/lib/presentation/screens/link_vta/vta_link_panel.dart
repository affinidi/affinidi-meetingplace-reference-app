import 'package:flutter/material.dart';

import '../../widgets/common/app_card.dart';
import 'vta_link_content.dart';

/// The linking steps as a panel that fits the settings drawer.
class VtaLinkPanel extends StatelessWidget {
  const VtaLinkPanel({super.key});

  @override
  Widget build(BuildContext context) {
    // The card is a Material, so the settings route, which has no
    // Scaffold, still gets text styles and ink.
    return const AppCard(padding: EdgeInsets.all(20), child: VtaLinkContent());
  }
}
