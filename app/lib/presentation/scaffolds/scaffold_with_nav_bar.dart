import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../navigation/tabs/navigation_tab_destination.dart';
import '../../navigation/tabs/tabs.dart';
import '../widgets/loaders/control_plane_events_progress_indicator.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ControlPlaneEventsProgressIndicator(),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: Tabs.values.map((tab) => tab.destination(l10n)).toList(),
      ),
    );
  }
}
