import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/configuration/environment.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../navigation/tabs/navigation_tab_destination.dart';
import '../../navigation/tabs/tabs.dart';
import '../widgets/loaders/control_plane_events_progress_indicator.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isZkpEnabled = ref.read(environmentProvider).zkpEnabled;

    final visibleTabs = isZkpEnabled
        ? Tabs.values
        : Tabs.values.where((tab) => tab != Tabs.credentials).toList();
    final visibleBranchIndexes = visibleTabs.map((tab) => tab.index).toList();

    final currentIndex = navigationShell.currentIndex;
    final selectedIndex = visibleBranchIndexes.indexOf(currentIndex);

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
        selectedIndex: selectedIndex == -1 ? 0 : selectedIndex,
        onDestinationSelected: (visibleIndex) {
          final branchIndex = visibleBranchIndexes[visibleIndex];
          navigationShell.goBranch(branchIndex);
        },
        destinations: visibleTabs.map((tab) => tab.destination(l10n)).toList(),
      ),
    );
  }
}
