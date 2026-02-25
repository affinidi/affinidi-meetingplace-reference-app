part of 'contacts_screen.dart';

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
      // TODO(MA): Remove shrink wrap to enable lazy loading
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
    final fullName = contact.card.displayName;
    final hasDisplayName = contact.displayName?.isNotEmpty ?? false;
    final dateAdded =
        DateFormat.yMMMd(Localizations.localeOf(context).toString())
            .format(contact.dateAdded);
    final statusColor = contact.getStatusColor(context, asAvatar: true);

    return Dismissible(
      key: ValueKey(contact.channelDidSha256),
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
          children: [
            Icon(Icons.delete, color: context.colorScheme.onError),
            Text(
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
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Material(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => onTap(
              contact: contact,
              isSelected: isSelected,
            ),
            onDoubleTap: () => onDoubleTap(contact: contact),
            onLongPress: () => onLongPress(contact: contact),
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
                    _ContactAvatar(
                      contact: contact,
                      isList: true,
                    ),
                    if (contact.badgeCount > 0 || contact.isOobContact) ...[
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
                      ),
                    ],
                  ],
                ),
              ),
              title: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 54),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (hasDisplayName) ...[
                      Text(
                        contact.displayName!,
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
                      fullName,
                      style: hasDisplayName
                          ? context.textTheme.labelMedium
                          : context.textTheme.bodyMedium,
                      maxLines: 1,
                    ),
                    if (contactMediator?.mediatorName != null &&
                        contactMediator!.mediatorName.isNotEmpty)
                      Text(
                        context.l10n.connectedVia(contactMediator.mediatorName),
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
                      onChanged: (checked) => onTap(
                        contact: contact,
                        isSelected: isSelected,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
