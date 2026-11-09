import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../navigation/routes/route_paths.dart';
import '../../navigation/tabs/tabs.dart';
import '../themes/tokens/mc_icons.dart';
import '../themes/tokens/mc_spacing.dart';

/// Right-side drawer with shortcuts to Settings, the call log and the test
/// credentials this phone can issue.
class SettingsEndDrawer extends StatelessWidget {
  const SettingsEndDrawer({super.key});

  void _openSettings(BuildContext context) {
    Navigator.of(context).pop();
    GoRouter.of(context).push(RoutePaths.settings);
  }

  void _openCallLog(BuildContext context) {
    Navigator.of(context).pop();
    GoRouter.of(context).push(RoutePaths.callLog);
  }

  void _openMockCredentials(BuildContext context) {
    Navigator.of(context).pop();
    GoRouter.of(context).push(RoutePaths.mockCredentials);
  }

  static const _closeIconSize = 24.0;
  static const _itemIconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = l10n.tabsTitle(TabTitleKey.settings.name);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(McIcons.close, size: _closeIconSize),
                color: context.mcColors.textSecondary,
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            _DrawerItem(
              icon: McIcons.settings,
              label: title,
              onTap: () => _openSettings(context),
            ),
            _DrawerItem(
              icon: McIcons.callLog,
              label: l10n.callLogScreenTitle,
              onTap: () => _openCallLog(context),
            ),
            _DrawerItem(
              icon: McIcons.mockCredentials,
              label: l10n.mockCredentialsTitle,
              onTap: () => _openMockCredentials(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// One shortcut row; colours and type come from the list tile theme.
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Even leading puts the label's glyphs on the icon's centre line;
    // Affinidi Sans otherwise sets them about 2px low.
    final titleStyle = ListTileTheme.of(context).titleTextStyle?.copyWith(
      leadingDistribution: TextLeadingDistribution.even,
    );

    return ListTile(
      minLeadingWidth: SettingsEndDrawer._itemIconSize,
      horizontalTitleGap: McSpacing.s2,
      titleTextStyle: titleStyle,
      leading: Icon(icon, size: SettingsEndDrawer._itemIconSize),
      title: Text(label),
      onTap: onTap,
    );
  }
}
