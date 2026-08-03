import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../navigation/routes/route_paths.dart';
import '../../navigation/tabs/tabs.dart';

/// Right-side drawer with a shortcut to the Settings tab.
class SettingsEndDrawer extends StatelessWidget {
  const SettingsEndDrawer({super.key, required this.isZkpEnabled});

  final bool isZkpEnabled;

  void _openCredentials(BuildContext context) {
    Navigator.of(context).pop();
    GoRouter.of(context).go(RoutePaths.credentials);
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).pop();
    GoRouter.of(context).push(RoutePaths.settings);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = l10n.tabsTitle(TabTitleKey.settings.name);

    return Drawer(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            if (isZkpEnabled)
              ListTile(
                minLeadingWidth: 20,
                horizontalTitleGap: 8,
                leading: const Icon(
                  Icons.verified_user,
                  color: Colors.white,
                  size: 20,
                ),
                title: Text(
                  l10n.tabsTitle(TabTitleKey.credentials.name),
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
                onTap: () => _openCredentials(context),
              ),
            ListTile(
              minLeadingWidth: 20,
              horizontalTitleGap: 8,
              leading: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 20,
              ),
              title: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              onTap: () => _openSettings(context),
            ),
          ],
        ),
      ),
    );
  }
}
