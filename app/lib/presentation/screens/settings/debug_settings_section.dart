part of 'settings_screen.dart';

class _DebugSettingsSection extends ConsumerWidget {
  const _DebugSettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDebugMode = ref.watch(
      settingsScreenControllerProvider.select((state) => state.isDebugMode),
    );
    final numberOfTapsToUnlockDebug = ref.read(
      settingsScreenControllerProvider
          .select((state) => state.numberOfTapsToUnlockDebug),
    );

    if (!isDebugMode) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        FormCard(
          title: context.l10n.debugSettingsTitle,
          child: ListTile(
            leading: const Icon(Icons.terminal, color: Colors.white, size: 20),
            title: Text(context.l10n.debugPanelTitle),
            subtitle: Text(context.l10n.debugPanelSubtitle),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) => const Dialog.fullscreen(
                  child: DebugPanel(),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          child: Text(
            context.l10n.debugModeHelperText(numberOfTapsToUnlockDebug),
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
