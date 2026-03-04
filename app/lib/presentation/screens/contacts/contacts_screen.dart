import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/contacts/contact.dart';
import '../../../domain/models/contacts/contact_origin.dart';
import '../../../domain/models/contacts/contact_status.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/contact_extensions.dart';
import '../../../infrastructure/extensions/contact_image_extensions.dart';
import '../../../infrastructure/extensions/contact_newness_extensions.dart';
import '../../../infrastructure/extensions/contact_origin_extensions.dart';
import '../../../infrastructure/extensions/widget_ref_extensions.dart';
import '../../../infrastructure/providers/cache_manager_provider.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../dialogs/new_connections_menu/new_connections_menu.dart';
import '../../helpers/screensize_helper.dart';
import '../../widgets/action_button.dart';
import '../../widgets/async_loaders/modal_async_loading_status.dart';
import '../../widgets/profile_circle_avatar.dart';
import '../../widgets/section_banner.dart';
import '../../widgets/tab_bar_tab.dart';
import '../chat/chat_screen_controller.dart';
import 'contacts_screen_controller.dart';
import 'contacts_screen_filter.dart';

part 'actions_bar.dart';
part 'contact_avatar.dart';
part 'contact_notification_badge.dart';
part 'contacts_grid_view.dart';
part 'contacts_layout.dart';
part 'contacts_list_view.dart';
part 'contacts_search_field.dart';
part 'delete_contact_dialog.dart';
part 'filters_bar.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final provider = contactsScreenControllerProvider;
    final controller = ref.read(provider.notifier);
    ref.keepAround(contactsScreenControllerProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionBanner(
              title: l10n.tabsTitle(Tabs.contacts.name),
              subtitle: context.l10n.contactsPanelSubtitle,
              icon: Icon(
                Icons.chat,
                color: colorScheme.onSurfaceVariant,
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
            ModalAsyncLoadingStatus(
              controller.deleteContactLoadingController,
              successMessage: l10n.contactsDeleted(1),
            ),
            _ContactsLayout(),
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
      contactsScreenControllerProvider.select((state) => state.identity),
    );

    await NewConnectionsMenu.onSelectOption(
      context: context,
      currentIdentity: currentIdentity,
    );
  }
}
