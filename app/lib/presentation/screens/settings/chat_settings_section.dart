part of 'settings_screen.dart';

class _ChatSettingsSection extends ConsumerWidget {
  const _ChatSettingsSection();

  static const _automaticMediaDownloadSwitchKey = Key(
    'automaticMediaDownloadSwitch',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(settingsScreenControllerProvider.notifier);
    final isAutomaticMediaDownloadEnabled = ref.watch(
      settingsScreenControllerProvider.select(
        (state) => state.isAutomaticMediaDownloadEnabled,
      ),
    );

    return FormCard(
      title: context.l10n.chatSettingsTitle,
      child: Column(
        children: [
          FormRowToggle(
            icon: Icons.download_for_offline_outlined,
            iconColor: context.colorScheme.primary,
            label: context.l10n.automaticMediaDownloadLabel,
            value: isAutomaticMediaDownloadEnabled,
            helperText: context.l10n.automaticMediaDownloadHelperText,
            switchKey: _automaticMediaDownloadSwitchKey,
            onChanged: (value) {
              controller.toggleAutomaticMediaDownload();
            },
          ),
        ],
      ),
    );
  }
}
