part of 'connections_screen.dart';

class _ConnectionsListView extends ConsumerWidget {
  const _ConnectionsListView({
    required this.onConnectionPress,
    required this.onConnectionLongPress,
    required this.connections,
  });

  final List<ConnectionOffer> connections;
  final void Function({
    required ConnectionOffer connection,
    required bool isSelected,
  }) onConnectionPress;
  final void Function({
    required ConnectionOffer connection,
    required BuildContext context,
  }) onConnectionLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: connections.length,
      itemBuilder: (context, index) => _ConnectionListItem(
        connection: connections[index],
        onConnectionPress: onConnectionPress,
        onConnectionLongPress: onConnectionLongPress,
      ),
    );
  }
}

class _ConnectionListItem extends ConsumerWidget {
  const _ConnectionListItem({
    required this.connection,
    required this.onConnectionPress,
    required this.onConnectionLongPress,
  });

  final ConnectionOffer connection;

  final void Function({
    required ConnectionOffer connection,
    required bool isSelected,
  }) onConnectionPress;
  final void Function({
    required ConnectionOffer connection,
    required BuildContext context,
  }) onConnectionLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedConnectionsCount = ref.watch(
        connectionsScreenControllerProvider
            .select((state) => state.selectedConnections.length));

    if (connection.isDeleted) {
      return _ConnectionCard(
        connection: connection,
        onConnectionPress: onConnectionPress,
        onConnectionLongPress: onConnectionLongPress,
      );
    }

    return Dismissible(
      key: ValueKey(connection.offerLink),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: context.colorScheme.error,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5,
          children: [
            Icon(Icons.delete, color: context.colorScheme.onError),
            Text(context.l10n.generalDelete,
                style: context.textTheme.bodySmall
                    ?.copyWith(color: context.colorScheme.onError)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        final shouldDelete = await DeleteConnectionDialog.show(
          context: context,
          count: selectedConnectionsCount,
        );
        if (shouldDelete) {
          await ref
              .read(connectionsScreenControllerProvider.notifier)
              .deleteConnection(connection);
        }
        return false;
      },
      child: _ConnectionCard(
        connection: connection,
        onConnectionPress: onConnectionPress,
        onConnectionLongPress: onConnectionLongPress,
      ),
    );
  }
}

class _ConnectionCard extends ConsumerWidget {
  const _ConnectionCard(
      {required ConnectionOffer connection,
      required void Function(
              {required ConnectionOffer connection, required bool isSelected})
          onConnectionPress,
      required void Function(
              {required ConnectionOffer connection,
              required BuildContext context})
          onConnectionLongPress})
      : _onConnectionLongPress = onConnectionLongPress,
        _onConnectionPress = onConnectionPress,
        _connection = connection;

  final ConnectionOffer _connection;
  final void Function({
    required ConnectionOffer connection,
    required bool isSelected,
  }) _onConnectionPress;
  final void Function({
    required ConnectionOffer connection,
    required BuildContext context,
  }) _onConnectionLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = _connection.offerName;
    final cacheManager = ref.read(cacheManagerProvider);

    final isSelected = ref.watch(
      connectionsScreenControllerProvider.select(
        (state) => state.selectedConnections.contains(_connection),
      ),
    );

    final state = ref.read(connectionsScreenControllerProvider);

    final mediatorName =
        state.connectionMediators[_connection.publishOfferDid]?.mediatorName;

    final identityText = (mediatorName != null && mediatorName.isNotEmpty)
        ? context.l10n.usesIdentityViaMediator(
            _connection.vCard.firstName,
            mediatorName,
          )
        : context.l10n.usesIdentity(
            _connection.vCard.firstName,
          );

    return Card.outlined(
      color: context.customColors.whiteOverlay30,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: _connection.getStatusColor(context),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _onConnectionPress(
          connection: _connection,
          isSelected: isSelected,
        ),
        onLongPress: () => _onConnectionLongPress(
          context: context,
          connection: _connection,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage:
                          _connection.vCard.image(cacheManager: cacheManager)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          name,
                          style: context.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              context.l10n.connectionPhrase(
                                _connection.mnemonic,
                              ),
                              style: context.textTheme.labelSmall,
                            ),
                            Text(
                              identityText,
                              style: context.textTheme.bodySmall,
                            ),
                            Text(
                              _connection.expiresAt == null
                                  ? context.l10n.createdValidWithoutExpiration(
                                      _connection.createdAt
                                          .timeAgo(context.l10n))
                                  : context.l10n.createdValidUntil(
                                      _connection.createdAt
                                          .timeAgo(context.l10n),
                                      DateFormat.yMMMd(
                                              Localizations.localeOf(context)
                                                  .toString())
                                          .format(_connection.expiresAt!),
                                    ),
                              style: context.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Chip(
                label: Text(
                  _connection.localized(context),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _connection.getStatusColor(context),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
            ),
            _ConnectionTrailingWidget(
              connection: _connection,
              onConnectionPress: _onConnectionPress,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionTrailingWidget extends ConsumerWidget {
  const _ConnectionTrailingWidget({
    required this.connection,
    required this.onConnectionPress,
  });

  final ConnectionOffer connection;
  final void Function({
    required ConnectionOffer connection,
    required bool isSelected,
  }) onConnectionPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = ref.watch(
      connectionsScreenControllerProvider.select((state) => state.isEditMode),
    );
    final isSelected = ref.watch(
      connectionsScreenControllerProvider.select(
        (state) => state.selectedConnections.contains(connection),
      ),
    );
    final isOwnedByMe = connection.ownedByMe;

    if (connection.isDeleted) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: -5,
      right: 0,
      child: isEditMode
          ? Checkbox(
              value: isSelected,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              onChanged: (checked) => onConnectionPress(
                connection: connection,
                isSelected: isSelected,
              ),
            )
          : isOwnedByMe
              ? IconButton(
                  onPressed: () => onConnectionPress(
                    connection: connection,
                    isSelected: isSelected,
                  ),
                  icon: Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                )
              : const SizedBox.shrink(),
    );
  }
}
