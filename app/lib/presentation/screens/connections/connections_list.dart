part of 'connections_screen.dart';

class _ConnectionsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connections = ref.watch(
      connectionsScreenControllerProvider.filteredConnections,
    );
    final l10n = context.l10n;

    void toggleSelection(ConnectionOffer connection, bool isSelected) {
      final controller = ref.read(connectionsScreenControllerProvider.notifier);
      final selectedConnections = ref
          .read(connectionsScreenControllerProvider)
          .selectedConnections;

      if (isSelected) {
        controller.setSelectedConnections(
          List.of(selectedConnections)..remove(connection),
        );
      } else {
        controller.setSelectedConnections(
          List.of(selectedConnections)..add(connection),
        );
      }
    }

    void onConnectionPress({
      required ConnectionOffer connection,
      required bool isSelected,
    }) {
      final isEditMode = ref.read(
        connectionsScreenControllerProvider.select((state) => state.isEditMode),
      );

      if (isEditMode) {
        toggleSelection(connection, isSelected);
        return;
      }
      if (!context.mounted) return;
      if (connection.status == ConnectionOfferStatus.published) {
        OfferDetailsRoute(connection.offerLink).go(context);
      }
    }

    void onConnectionLongPress({
      required BuildContext context,
      required ConnectionOffer connection,
    }) async {
      if (!context.mounted) return;
      if (connection.status == ConnectionOfferStatus.deleted) return;

      ref
          .read(connectionsScreenControllerProvider.notifier)
          .setSelectedConnections([connection]);

      final shouldDelete = await DeleteConnectionDialog.show(
        context: context,
        count: 1,
      );
      if (shouldDelete) {
        await ref
            .read(connectionsScreenControllerProvider.notifier)
            .deleteSelectedConnections();
      } else {
        ref
            .read(connectionsScreenControllerProvider.notifier)
            .setSelectedConnections([]);
      }
    }

    if (connections.isEmpty) {
      return SizedBox(
        height: context.mediaQuery.size.height * 0.5,
        child: Center(child: Text(l10n.noConnections)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: _ConnectionsListView(
        onConnectionPress: onConnectionPress,
        onConnectionLongPress: onConnectionLongPress,
        connections: connections,
      ),
    );
  }
}
