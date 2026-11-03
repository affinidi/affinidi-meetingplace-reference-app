import 'package:flutter/material.dart';

import '../link_vta/vta_link_panel.dart';

/// Shows the link to the member's VTA in the settings, where it can be
/// removed. The panel brings its own titled cards.
class LinkedVtaSection extends StatelessWidget {
  const LinkedVtaSection({super.key});

  @override
  Widget build(BuildContext context) => const VtaLinkPanel();
}
