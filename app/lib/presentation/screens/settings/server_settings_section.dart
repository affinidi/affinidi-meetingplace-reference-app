part of 'settings_screen.dart';

class _ServerSettingsSection extends ConsumerWidget {
  const _ServerSettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = settingsScreenControllerProvider;

    final controller = ref.read(provider.notifier);
    final scanMediatorQRLoadingController =
        controller.scanMediatorQRLoadingController;

    final selectedMediatorDid =
        ref.watch(provider.select((state) => state.selectedMediatorDid));
    final mediators = ref.watch(provider.select((state) => state.mediators));

    return Column(
      children: [
        ModalAsyncLoadingStatus(scanMediatorQRLoadingController),
        FormCard(
          title: context.l10n.serverSettings,
          child: Column(
            children: [
              RadioGroup<String>(
                groupValue: selectedMediatorDid,
                onChanged: (value) async {
                  if (value != null) {
                    await controller.selectMediator(value);
                  }
                },
                child: Column(
                  children: mediators.map((mediator) {
                    final did = mediator.mediatorDid;
                    final name = mediator.mediatorName;

                    return RadioListTile(
                      radioSide:
                          BorderSide(width: 0.8, color: Colors.grey.shade600),
                      value: did,
                      title: Row(
                        children: [
                          Expanded(child: Text(name)),
                          if (mediator.type == MediatorType.custom) ...[
                            IconButton(
                              onPressed: () =>
                                  _renameMediator(context, ref, did, name),
                              icon: const Icon(Icons.edit, size: 20),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _confirmDelete(context, ref, did, name),
                              icon: const Icon(Icons.delete, size: 20),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              ListTile(
                title: Center(
                  child: Text(
                    context.l10n.scanCustomMediatorQrCode,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                onTap: () async {
                  final url = await QrCodePicker.show(context: context);
                  if (url == null || url.isEmpty) return;
                  await ref
                      .read(scanMediatorQRLoadingController.notifier)
                      .start(() async {
                    await controller.scanMediatorQr(
                      url: url,
                      unnamedPrefix: context.l10n.unnamedMediator,
                    );
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Text(
            context.l10n.chooseMediatorHelper,
            style: context.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }

  Future<void> _renameMediator(
    BuildContext context,
    WidgetRef ref,
    String did,
    String name,
  ) async {
    final newName = await RenameMediatorDialog.show(
      context,
      currentName: name,
    );

    if (newName != null) {
      final controller = ref.read(settingsScreenControllerProvider.notifier);
      try {
        await controller.renameCustomMediator(did: did, newName: newName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.renamedMediatorSuccess(newName)),
              backgroundColor: context.customColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.failedToRenameMediator(e.toString())),
              backgroundColor: context.colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String did,
    String name,
  ) async {
    final confirmed = await DeleteMediatorDialog.show(
      context,
      name: name,
    );

    if (confirmed == true) {
      final controller = ref.read(settingsScreenControllerProvider.notifier);
      try {
        await controller.removeCustomMediator(did);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.deletedMediatorSuccess(name)),
              backgroundColor: context.customColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.failedToDeleteMediator(e.toString())),
              backgroundColor: context.colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
