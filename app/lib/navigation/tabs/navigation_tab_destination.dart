import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'navigation_tab.dart';
import 'tabs.dart';

extension NavigationTabDestination on Tabs {
  NavigationDestination destination(AppLocalizations localizations) {
    return NavigationDestination(
      icon: NavigationTab(this),
      label: localizations.tabsTitle(name),
    );
  }
}
