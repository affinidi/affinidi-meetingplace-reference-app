part of 'contacts_screen.dart';

class _FiltersBar extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(contactsScreenControllerProvider.notifier);
    final tabController = useTabController(
      initialLength: ContactsScreenFilter.values.length,
      initialIndex: 0,
    );
    final l10n = context.l10n;

    return FilterTabBar(
      controller: tabController,
      labels: [
        for (final filter in ContactsScreenFilter.values)
          l10n.contactsFilterLabel(filter.name),
      ],
      onSelected: (index) {
        if (!context.mounted) return;
        controller.applyFilter(ContactsScreenFilter.values[index]);
      },
    );
  }
}
