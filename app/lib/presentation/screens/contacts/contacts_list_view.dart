part of 'contacts_screen.dart';

String _resolvePrimaryContactName({
  required Contact contact,
  required String fullName,
  String? displayName,
  String? defaultGroupName,
}) {
  if (contact.isGroup) {
    if (defaultGroupName != null && defaultGroupName.isNotEmpty) {
      return defaultGroupName;
    }
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
  }

  return fullName;
}

String? _resolveSecondaryContactName({
  required Contact contact,
  required String primaryName,
  required String fullName,
  String? displayName,
  String? defaultGroupName,
}) {
  if (contact.isGroup) {
    return fullName != primaryName ? fullName : null;
  }

  return displayName != null &&
          displayName.isNotEmpty &&
          displayName != primaryName
      ? displayName
      : null;
}

class _ContactsListView extends ConsumerWidget {
  const _ContactsListView({
    required this.onContactTap,
    required this.onContactDoubleTap,
    required this.onContactLongPress,
  });

  final void Function({required Contact contact, required bool isSelected})
  onContactTap;
  final void Function({required Contact contact}) onContactDoubleTap;
  final void Function({required Contact contact}) onContactLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(
      contactsScreenControllerProvider.select((state) => state.contacts),
    );

    return ListView.builder(
      //  c
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      itemBuilder: (context, index) => _ContactListItem(
        contacts[index],
        onTap: onContactTap,
        onDoubleTap: onContactDoubleTap,
        onLongPress: onContactLongPress,
      ),
    );
  }
}

class _ContactListItem extends ConsumerWidget {
  const _ContactListItem(
    this.contact, {
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPress,
  });

  final Contact contact;

  final void Function({required Contact contact, required bool isSelected})
  onTap;
  final void Function({required Contact contact}) onDoubleTap;
  final void Function({required Contact contact}) onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(
      contactsScreenControllerProvider.select(
        (state) => state.selectedContacts.contains(contact),
      ),
    );
    final isEditMode = ref.watch(
      contactsScreenControllerProvider.select((state) => state.isEditMode),
    );
    final contactMediator = ref.watch(
      contactsScreenControllerProvider.select(
        (state) => state.contactMediators[contact.mediatorDid],
      ),
    );
    final displayName = contact.displayName?.trim();
    final fullName = contact.card.displayName.trim();
    final defaultGroupName = contact.isGroup
        ? ref.watch(
            connectionsServiceProvider.select(
              (state) =>
                  state.getConnectionByOfferLink(contact.offerLink)?.offerName,
            ),
          )
        : null;
    final trimmedDefaultGroupName = defaultGroupName?.trim();
    final primaryName = _resolvePrimaryContactName(
      contact: contact,
      fullName: fullName,
      displayName: displayName,
      defaultGroupName: trimmedDefaultGroupName,
    );
    final secondaryName = _resolveSecondaryContactName(
      contact: contact,
      primaryName: primaryName,
      fullName: fullName,
      displayName: displayName,
      defaultGroupName: trimmedDefaultGroupName,
    );
    final showCustomDisplayName = secondaryName != null;
    final dateAdded = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(contact.dateAdded);
    final statusColor = contact.getStatusColor(context, asAvatar: true);

    Future<void> onContextSelected(AgentContext next) async {
      await ref
          .read<ContextRoutingService>(contextRoutingServiceProvider.notifier)
          .assignContactContext(contact.id, next);

      if (!context.mounted) return;
      final l10n = context.l10n;
      final label = next == AgentContext.work
          ? l10n.agentContextWorkAiLabel
          : l10n.agentContextPersonalAiLabel;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contactsChannelContextSet(label))),
      );
    }

    final child = _ContactTile(
      contact: contact,
      isEditMode: isEditMode,
      isSelected: isSelected,
      statusColor: statusColor,
      primaryName: primaryName,
      secondaryName: secondaryName,
      showCustomDisplayName: showCustomDisplayName,
      dateAdded: dateAdded,
      contactMediatorName: contactMediator?.mediatorName,
      onTap: () => onTap(contact: contact, isSelected: isSelected),
      onDoubleTap: () => onDoubleTap(contact: contact),
      onLongPress: () => onLongPress(contact: contact),
      onEditModeCheckChanged: (checked) =>
          onTap(contact: contact, isSelected: isSelected),
      onContextSelected: onContextSelected,
    );

    return Dismissible(
      key: ValueKey(contact.channelDidSha256),
      direction: DismissDirection.endToStart,
      background: Container(
        key: const Key('dismissible_delete_background'),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: context.colorScheme.error,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: context.colorScheme.onError),
            Text(
              key: const Key('dismissible_delete_text'),
              context.l10n.generalDelete,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await DeleteContactDialog.show(context);
      },
      onDismissed: (direction) async {
        await ref
            .read(contactsScreenControllerProvider.notifier)
            .deleteContact(contact);
      },
      child: child,
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.isEditMode,
    required this.isSelected,
    required this.statusColor,
    required this.primaryName,
    required this.secondaryName,
    required this.showCustomDisplayName,
    required this.dateAdded,
    required this.contactMediatorName,
    required this.onTap,
    required this.onDoubleTap,
    required this.onLongPress,
    required this.onEditModeCheckChanged,
    required this.onContextSelected,
  });

  final Contact contact;
  final bool isEditMode;
  final bool isSelected;
  final Color statusColor;
  final String primaryName;
  final String? secondaryName;
  final bool showCustomDisplayName;
  final String dateAdded;
  final String? contactMediatorName;

  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool?>? onEditModeCheckChanged;
  final Future<void> Function(AgentContext context) onContextSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Material(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          onLongPress: onLongPress,
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: statusColor, width: 2),
            ),
            leading: SizedBox(
              width: 60,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _ContactAvatar(contact: contact, isList: true),
                  if (contact.badgeCount > 0 || contact.isOobContact)
                    Positioned(
                      bottom: -5,
                      right: -10,
                      child: contact.badgeUpdateInProgress
                          ? const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 3,
                              ),
                            )
                          : _ContactNotificationBadge(
                              origin: contact.origin,
                              badgeCount: contact.badgeCount,
                              isList: true,
                            ),
                    )
                  else if (contact.isNewUnopenedChannel)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: _ContactNewChannelDotBadge(
                        origin: contact.origin,
                        isList: true,
                      ),
                    ),
                ],
              ),
            ),
            title: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 54),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (showCustomDisplayName) ...[
                    Text(
                      secondaryName!,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    primaryName,
                    style: showCustomDisplayName
                        ? context.textTheme.labelMedium
                        : context.textTheme.bodyMedium,
                    maxLines: 1,
                  ),
                  if (contactMediatorName != null &&
                      contactMediatorName!.isNotEmpty)
                    Text(
                      context.l10n.connectedVia(contactMediatorName!),
                      style: context.textTheme.labelSmall,
                      maxLines: 1,
                    ),
                  Text(
                    context.l10n.contactAdded(dateAdded),
                    style: context.textTheme.labelSmall,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            trailing: isEditMode
                ? Checkbox(
                    value: isSelected,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    onChanged: onEditModeCheckChanged,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
