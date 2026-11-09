part of 'connections_screen.dart';

class _FiltersBar extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(connectionsScreenControllerProvider.notifier);
    final tabController = useTabController(
      initialLength: ConnectionsScreenFilter.values.length,
      initialIndex: 0,
    );
    final l10n = context.l10n;

    return FilterTabBar(
      controller: tabController,
      labels: [
        for (final filter in ConnectionsScreenFilter.values)
          l10n.connectionsFilterLabel(filter.name),
      ],
      onSelected: (index) {
        if (!context.mounted) return;
        controller.applyFilter(ConnectionsScreenFilter.values[index]);
      },
    );
  }
}
