import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../navigation/routes/route_paths.dart';
import '../../navigation/tabs/tabs.dart';
import '../themes/tokens/mc_icons.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = l10n.tabsTitle(TabTitleKey.settings.name);
    final mc = context.mcColors;
    final itemStyle = context.textTheme.titleMedium?.copyWith(
      color: mc.textPrimary,
    );

    return Drawer(
      backgroundColor: mc.raised,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(McIcons.close, color: mc.textPrimary, size: 24),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            ListTile(
              minLeadingWidth: 20,
              horizontalTitleGap: 8,
              leading: Icon(McIcons.settings, color: mc.textPrimary, size: 20),
              title: Text(title, style: itemStyle),
              onTap: () => _openSettings(context),
            ),
            ListTile(
              minLeadingWidth: 20,
              horizontalTitleGap: 8,
              leading: Icon(McIcons.callLog, color: mc.textPrimary, size: 20),
              title: Text(l10n.callLogScreenTitle, style: itemStyle),
              onTap: () => _openCallLog(context),
            ),
            ListTile(
              minLeadingWidth: 20,
              horizontalTitleGap: 8,
              leading: Icon(
                McIcons.mockCredentials,
                color: mc.textPrimary,
                size: 20,
              ),
              title: Text(l10n.mockCredentialsTitle, style: itemStyle),
              onTap: () => _openMockCredentials(context),
            ),
          ],
        ),
      ),
    );
  }
}
