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

    return FilterTabBar(
      controller: tabController,
      labels: [
        for (final filter in IdentitiesScreenFilter.values)
          l10n.identitiesFilterLabel(filter.name),
      ],
      onSelected: (index) {
        if (!context.mounted) return;
        controller.applyFilter(IdentitiesScreenFilter.values[index]);
      },
    );
  }
}
