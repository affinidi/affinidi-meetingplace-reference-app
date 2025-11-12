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

    return TabBar(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      isScrollable: true,
      enableFeedback: true,
      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
      tabAlignment: TabAlignment.start,
      controller: tabController,
      onTap: (index) {
        if (!context.mounted) return;
        controller.applyFilter(ContactsScreenFilter.values[index]);
      },
      tabs: ContactsScreenFilter.values
          .map((filter) =>
              TabBarTab(label: l10n.contactsFilterLabel(filter.name)))
          .toList(),
    );
  }
}
