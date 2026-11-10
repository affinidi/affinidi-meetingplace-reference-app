import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/configuration/environment.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../navigation/tabs/navigation_tab_destination.dart';
import '../../navigation/tabs/tabs.dart';
import '../screens/communities/role_change_notice.dart';
import '../screens/credentials/membership_credentials_controller.dart';
import '../themes/tokens/mc_colors.dart';
import '../widgets/loaders/control_plane_events_progress_indicator.dart';
import '../widgets/settings_end_drawer.dart';
import 'dashboard_shell_scaffold_key.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isZkpEnabled = ref.read(environmentProvider).zkpEnabled;
    listenForRoleChanges(ref, context);

    final visibleTabs = isZkpEnabled
        ? Tabs.values
        : Tabs.values.where((tab) => tab != Tabs.credentials).toList();
    final visibleBranchIndexes = visibleTabs.map((tab) => tab.index).toList();

    final currentIndex = navigationShell.currentIndex;
    final selectedIndex = visibleBranchIndexes.indexOf(currentIndex);

    return Scaffold(
      key: dashboardShellScaffoldKey,
      endDrawer: const SettingsEndDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const ControlPlaneEventsProgressIndicator(),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.mcColors.hairline)),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex == -1 ? 0 : selectedIndex,
          onDestinationSelected: (visibleIndex) {
            final branchIndex = visibleBranchIndexes[visibleIndex];
            navigationShell.goBranch(branchIndex);
            // The tab stays alive once opened: read the cards again on each
            // return to it. Its first opening reads them already.
            if (branchIndex == Tabs.credentials.index &&
                branchIndex != currentIndex &&
                ref.exists(membershipCredentialsControllerProvider)) {
              unawaited(
                ref
                    .read(membershipCredentialsControllerProvider.notifier)
                    .refresh(),
              );
            }
          },
          destinations: visibleTabs.map((tab) {
            final destination = tab.destination(l10n);
            return NavigationDestination(
              icon: destination.icon,
              selectedIcon: _SelectedMarker(child: destination.icon),
              label: destination.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Marks the selected destination with a small blue dot above its icon,
/// instead of a filled pill.
class _SelectedMarker extends StatelessWidget {
  const _SelectedMarker({required this.child});

  static const double _dotSize = 6;
  static const double _dotOffset = -10;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        child,
        const Positioned(
          top: _dotOffset,
          child: SizedBox.square(
            dimension: _dotSize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: McColors.blue,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
