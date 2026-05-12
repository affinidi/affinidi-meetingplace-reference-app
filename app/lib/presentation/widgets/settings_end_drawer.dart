import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../navigation/routes/dashboard_routes.dart';
import '../../navigation/tabs/tabs.dart';

/// Right-side drawer with a shortcut to the Settings tab.
class SettingsEndDrawer extends StatelessWidget {
  const SettingsEndDrawer({super.key});

  void _openSettings(BuildContext context) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.go(const SettingsRoute().location);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = l10n.tabsTitle(Tabs.settings.name);

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
            ListTile(
              minLeadingWidth: 20,
              horizontalTitleGap: 8,
              leading: const Icon(Icons.settings, color: Colors.white),
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
