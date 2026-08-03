import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/mediator/mediator_type.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/routes/route_paths.dart';
import '../../../navigation/tabs/tabs.dart';
import '../../dialogs/qr_code_picker/qr_code_picker.dart';
import '../../dialogs/settings/delete_mediator_dialog.dart';
import '../../dialogs/settings/rename_mediator_dialog.dart';
import '../../widgets/async_loaders/modal_async_loading_status.dart';
import '../../widgets/form_rows/form_card.dart';
import '../../widgets/form_rows/form_row_toggle.dart';
import '../../widgets/section_banner.dart';
import 'debug/debug_panel.dart';
import 'settings_screen_controller.dart';

part 'debug_settings_section.dart';
part 'meeting_place_control_plane_section.dart';
part 'server_settings_section.dart';
part 'version_info.dart';

/// Shared settings sections for the Settings tab.
class SettingsPanelScrollContent extends StatelessWidget {
  const SettingsPanelScrollContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _VersionInfoSection(),
          _MeetingPlaceControlPlaneSection(),
          SizedBox(height: 24),
          _ServerSettingsSection(),
          SizedBox(height: 24),
          _DebugSettingsSection(),
        ],
      ),
    );
  }
}

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = settingsScreenControllerProvider;
    final controller = ref.read(provider.notifier);

    useEffect(() {
      if (!context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await controller.ensureInitialized();
      });

      return null;
    }, []);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionBanner(
              title: l10n.tabsTitle(TabTitleKey.settings.name),
              subtitle: l10n.settingsScreenSubtitle,
              onClose: () => GoRouter.of(context).go(RoutePaths.contacts),
            ),
            const SettingsPanelScrollContent(),
          ],
        ),
      ),
    );
  }
}
