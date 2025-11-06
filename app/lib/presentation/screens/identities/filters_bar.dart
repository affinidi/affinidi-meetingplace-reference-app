part of 'identities_screen.dart';

class _FiltersBar extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(identitiesScreenControllerProvider.notifier);
    final tabController = useTabController(
      initialLength: IdentitiesScreenFilter.values.length,
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
        controller.applyFilter(IdentitiesScreenFilter.values[index]);
      },
      tabs: IdentitiesScreenFilter.values
          .map((filter) =>
              TabBarTab(label: l10n.identitiesFilterLabel(filter.name)))
          .toList(),
    );
  }
}
