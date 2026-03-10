part of 'contacts_screen.dart';

class _ContactsLayout extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(
      contactsScreenControllerProvider.select((state) => state.contacts),
    );
    final shouldShowGrid = ref.watch(
      contactsScreenControllerProvider.select((state) => state.shouldShowGrid),
    );
    final isEditMode = ref.watch(
      contactsScreenControllerProvider.select((state) => state.isEditMode),
    );
    final controller = ref.read(contactsScreenControllerProvider.notifier);

    Future<void> onContactTap({
      required Contact contact,
      required bool isSelected,
    }) async {
      if (!context.mounted) return;

      if (isEditMode) {
        isSelected
            ? controller.deselectContact(contact)
            : controller.selectContact(contact);
        return;
      }

      final isChatAvailable = ref.read(
        contactsScreenControllerProvider.select(
          (state) => state.isChatAvailable(contact),
        ),
      );
      if (isChatAvailable) {
        final container = ProviderScope.containerOf(context);
        final provider = chatScreenControllerProvider(contact.id);
        final element = container.readProviderElement(provider);

        final link = (element as AutoDisposeNotifierProviderElement)
            .keepAlive();
        await ref.read(provider.notifier).initialize();
        await ChatRoute(contactId: contact.id).push<void>(context);
        link.close();
        return;
      }

      if ([
        ContactStatus.active,
        ContactStatus.approved,
        ContactStatus.pendingApproval,
        ContactStatus.pendingInauguration,
      ].contains(contact.status)) {
        await ConnectionDetailsRoute(contactId: contact.id).push<void>(context);
        return;
      }
    }

    Future<void> onContactDoubleTap({required Contact contact}) async {
      if (!context.mounted) return;
      await ConnectionDetailsRoute(contactId: contact.id).push<void>(context);
    }

    void onContactLongPress({required Contact contact}) async {
      if (!context.mounted) return;

      final shouldDelete = await DeleteContactDialog.show(context);
      if (shouldDelete) {
        await controller.deleteContact(contact);
      }
    }

    if (contacts.isEmpty) {
      final shouldShowFilter = ref.watch(
        contactsScreenControllerProvider.select(
          (state) => state.shouldShowFilter,
        ),
      );

      return SizedBox(
        height: context.mediaQuery.size.height * 0.5,
        child: Center(
          child: Text(
            shouldShowFilter
                ? context.l10n.noContactsMatchFilter
                : context.l10n.noContactsYet,
          ),
        ),
      );
    }

    return shouldShowGrid
        ? _ContactGridView(
            onContactTap: onContactTap,
            onContactDoubleTap: onContactDoubleTap,
            onContactLongPress: onContactLongPress,
          )
        : _ContactsListView(
            onContactTap: onContactTap,
            onContactDoubleTap: onContactDoubleTap,
            onContactLongPress: onContactLongPress,
          );
  }
}
