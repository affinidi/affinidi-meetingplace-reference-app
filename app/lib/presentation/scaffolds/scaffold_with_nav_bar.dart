import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/configuration/environment.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../navigation/tabs/navigation_tab_destination.dart';
import '../../navigation/tabs/tabs.dart';
import '../widgets/loaders/control_plane_events_progress_indicator.dart';
import '../widgets/settings_end_drawer.dart';
import 'dashboard_shell_scaffold_key.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final environment = ref.read(environmentProvider);
    final isZkpEnabled = environment.zkpEnabled;
    final isPersonalAiEnabled = environment.personalAiEnabled;

    final visibleTabs = Tabs.values.where((tab) {
      if (tab == Tabs.credentials) {
        return false;
      }

      if (!isPersonalAiEnabled && tab == Tabs.personalAgent) {
        return false;
      }

      return true;
    }).toList();
    final visibleBranchIndexes = visibleTabs.map((tab) => tab.index).toList();

    final currentIndex = navigationShell.currentIndex;
    final selectedIndex = visibleBranchIndexes.indexOf(currentIndex);
    final showBottomNav = selectedIndex != -1;

    return Scaffold(
      key: dashboardShellScaffoldKey,
      endDrawer: SettingsEndDrawer(isZkpEnabled: isZkpEnabled),
      body: SafeArea(
        child: Column(
          children: [
            const ControlPlaneEventsProgressIndicator(),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (visibleIndex) {
                final branchIndex = visibleBranchIndexes[visibleIndex];
                navigationShell.goBranch(branchIndex);
              },
              destinations: visibleTabs
                  .map((tab) => tab.destination(l10n))
                  .toList(),
            )
          : null,
    );
  }
}
