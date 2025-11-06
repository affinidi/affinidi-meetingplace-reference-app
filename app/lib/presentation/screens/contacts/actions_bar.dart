part of 'contacts_screen.dart';

class _ActionsBar extends ConsumerWidget {
  _ActionsBar({required this.onSelectNewConnectionsOption});

  final VoidCallback onSelectNewConnectionsOption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(contactsScreenControllerProvider.notifier);

    final isEditMode = ref.watch(
        contactsScreenControllerProvider.select((state) => state.isEditMode));
    final hasContacts = ref.watch(contactsScreenControllerProvider.hasContacts);
    final hasAnySelectedContacts =
        ref.watch(contactsScreenControllerProvider.hasAnySelectedContacts);
    final hasIdentity = ref.watch(contactsScreenControllerProvider.hasIdentity);
    final shouldShowGrid = ref.watch(contactsScreenControllerProvider
        .select((state) => state.shouldShowGrid));
    final shouldShowFilter = ref.watch(contactsScreenControllerProvider
        .select((state) => state.shouldShowFilter));
    final selectedContactsCount =
        ref.watch(contactsScreenControllerProvider).selectedContacts.length;

    final colorScheme = context.colorScheme;
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
              icon: Icon(
                Icons.grid_view,
                color: shouldShowGrid
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              onPressed: () {
                controller.toggleGridView(true);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.list,
                color: !shouldShowGrid
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              onPressed: () {
                controller.toggleGridView(false);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.filter_list_alt,
                color: shouldShowFilter
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              onPressed: controller.toggleFilterVisibility,
            ),
          ],
        ),
        const Expanded(
          child: _ContactsSearchField(),
        ),
        Row(
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
              icon: const Icon(Icons.add),
              onPressed: hasIdentity ? onSelectNewConnectionsOption : null,
            ),
          ],
        ),
      ],
    );
  }
}
