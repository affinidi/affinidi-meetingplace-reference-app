part of 'connections_screen.dart';

class _ActionsBar extends ConsumerWidget {
  _ActionsBar({required this.onSelectNewConnectionsOption});

  final void Function() onSelectNewConnectionsOption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(connectionsScreenControllerProvider.notifier);
    final isEditMode = ref.watch(connectionsScreenControllerProvider
        .select((state) => state.isEditMode));
    final hasConnections =
        ref.watch(connectionsScreenControllerProvider.hasConnections);
    final hasIdentity =
        ref.watch(connectionsScreenControllerProvider.hasIdentity);

    final hasAnySelectedConnections = ref
        .watch(connectionsScreenControllerProvider.hasAnySelectedConnections);
    final selectedConnections = ref.watch(connectionsScreenControllerProvider
        .select((state) => state.selectedConnections));

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isEditMode)
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              if (!context.mounted) return;
              controller.cancelEdit();
            },
          ),
        IconButton(
          icon: Icon(
            Icons.delete,
            color: isEditMode ? context.colorScheme.primary : null,
          ),
          onPressed: hasConnections
              ? () async {
                  if (!context.mounted) return;
                  if (isEditMode && hasAnySelectedConnections) {
                    final shouldDelete = await DeleteConnectionDialog.show(
                      context: context,
                      count: selectedConnections.length,
                    );
                    if (shouldDelete) {
                      await controller.deleteSelectedConnections();
                    }
                  } else {
                    controller.toggleEditMode();
                  }
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: hasIdentity ? onSelectNewConnectionsOption : null,
        ),
      ],
    );
  }
}
