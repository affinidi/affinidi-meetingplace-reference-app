part of 'contacts_screen.dart';

class _ActionsBar extends ConsumerWidget {
  _ActionsBar({required this.onSelectNewConnectionsOption});

  final VoidCallback onSelectNewConnectionsOption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(contactsScreenControllerProvider.notifier);

    final isEditMode = ref.watch(
      contactsScreenControllerProvider.select((state) => state.isEditMode),
    );
    final hasContacts = ref.watch(contactsScreenControllerProvider.hasContacts);
    final hasAnySelectedContacts = ref.watch(
      contactsScreenControllerProvider.hasAnySelectedContacts,
    );
    final hasIdentity = ref.watch(contactsScreenControllerProvider.hasIdentity);
    final shouldShowGrid = ref.watch(
      contactsScreenControllerProvider.select((state) => state.shouldShowGrid),
    );
    final shouldShowFilter = ref.watch(
      contactsScreenControllerProvider.select(
        (state) => state.shouldShowFilter,
      ),
    );
    final selectedContactsCount = ref
        .watch(contactsScreenControllerProvider)
        .selectedContacts
        .length;

    final colorScheme = context.colorScheme;
    final mc = context.mcColors;
    final l10n = context.l10n;

    Future<void> deleteSelectedContacts() async {
      if (!context.mounted) return;
      await controller.deleteSelectedContacts();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ModalAsyncLoadingStatus(
          controller.deleteMultipleContactsLoadingController,
          successMessage: l10n.contactsDeleted(selectedContactsCount),
        ),
        Row(
          children: [
            IconButton(
              key: const Key('toggle_grid_view_button'),
              icon: Icon(
                McIcons.grid,
                color: shouldShowGrid
                    ? colorScheme.onSurface
                    : mc.textSecondary,
              ),
              onPressed: () {
                controller.toggleGridView(true);
              },
            ),
            IconButton(
              key: const Key('toggle_list_view_button'),
              icon: Icon(
                McIcons.list,
                color: !shouldShowGrid
                    ? colorScheme.onSurface
                    : mc.textSecondary,
              ),
              onPressed: () {
                controller.toggleGridView(false);
              },
            ),
            IconButton(
              key: const Key('toggle_filter_button'),
              icon: Icon(
                McIcons.filter,
                color: shouldShowFilter
                    ? colorScheme.primary
                    : mc.textSecondary,
              ),
              onPressed: controller.toggleFilterVisibility,
            ),
          ],
        ),
        const Expanded(child: _ContactsSearchField()),
        Row(
          children: [
            if (isEditMode)
              IconButton(
                icon: const Icon(McIcons.cancel),
                onPressed: () {
                  if (!context.mounted) return;
                  controller.cancelEdit();
                },
              ),
            IconButton(
              icon: Icon(
                McIcons.delete,
                color: isEditMode ? colorScheme.primary : null,
              ),
              onPressed: hasContacts
                  ? () async {
                      if (!context.mounted) return;
                      if (isEditMode && hasAnySelectedContacts) {
                        final shouldDelete = await DeleteContactDialog.show(
                          context,
                          itemsCount: selectedContactsCount,
                        );
                        if (shouldDelete) {
                          await deleteSelectedContacts();
                        }
                      } else {
                        controller.toggleEditMode();
                      }
                    }
                  : null,
            ),
            IconButton(
              key: const Key('new_connection_button'),
              icon: const Icon(McIcons.add),
              onPressed: hasIdentity ? onSelectNewConnectionsOption : null,
            ),
          ],
        ),
      ],
    );
  }
}
