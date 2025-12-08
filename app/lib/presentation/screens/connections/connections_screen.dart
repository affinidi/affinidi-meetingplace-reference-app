import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/connection_color_extensions.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../infrastructure/extensions/date_time_extensions.dart';
import '../../../infrastructure/extensions/widget_ref_extensions.dart';
import '../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../dialogs/new_connections_menu/new_connections_menu.dart';
import '../../dialogs/offer/delete_connection_dialog.dart';
import '../../widgets/containers/avatar_gradient_container.dart';
import '../../widgets/section_banner.dart';
import '../../widgets/tab_bar_tab.dart';
import 'connections_screen_controller.dart';
import 'connections_screen_filter.dart';

part 'actions_bar.dart';
part 'connections_list.dart';
part 'connections_list_view.dart';
part 'filters_bar.dart';

class ConnectionsScreen extends ConsumerWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    ref.keepAround(connectionsScreenControllerProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionBanner(
              title: context.l10n.tabsTitle(Tabs.connections.name),
              subtitle: l10n.connectionsPanelSubtitle,
              icon: Icon(
                Icons.compare_arrows,
                color: colorScheme.onSurfaceVariant,
                size: 24,
              ),
              onTap: () => _showNewConnectionsMenu(context, ref),
            ),
            _FiltersBar(),
            Padding(
              padding: const EdgeInsets.all(2),
              child: _ActionsBar(
                onSelectNewConnectionsOption: () =>
                    _showNewConnectionsMenu(context, ref),
              ),
            ),
            _ConnectionsList(),
          ],
        ),
      ),
    );
  }

  Future<void> _showNewConnectionsMenu(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final currentIdentity = ref.read(
        connectionsScreenControllerProvider.select((state) => state.identity));

    await NewConnectionsMenu.onSelectOption(
      context: context,
      currentIdentity: currentIdentity,
    );
  }
}
