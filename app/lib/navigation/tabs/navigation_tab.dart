import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/services/notification_service/notification_service.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../presentation/widgets/badged_icon.dart';
import 'tabs.dart';

class NavigationTab extends ConsumerWidget {
  const NavigationTab(this.tab, {super.key});

  final Tabs tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final count = ref.watch(
      notificationServiceProvider.select(
        (state) => state.counters[tab.serviceKey] ?? 0,
      ),
    );

    return BadgedIcon(
      label: l10n.tabsTitle(tab.name),
      icon: tab.icon,
      count: count,
    );
  }
}
