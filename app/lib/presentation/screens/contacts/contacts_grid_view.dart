part of 'contacts_screen.dart';

class _ContactGridView extends ConsumerWidget {
  const _ContactGridView({
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

    final isLandscapeOrTablet =
        ScreensizeHelper().isLandscape(context) ||
        ScreensizeHelper().isBigScreen(context);

    return GridView.builder(
      // TODO(MA): Remove shrink wrap to enable lazy loading
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLandscapeOrTablet ? 5 : 3,
        childAspectRatio: isLandscapeOrTablet ? 1 : 0.95,
      ),
      itemCount: contacts.length,
      itemBuilder: (context, index) => _ContactGridItem(
        contacts[index],
        onTap: onContactTap,
        onDoubleTap: onContactDoubleTap,
        onLongPress: onContactLongPress,
      ),
    );
  }
}

class _ContactGridItem extends ConsumerWidget {
  const _ContactGridItem(
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
    final fullName = contact.card.displayName.trim();
    final displayName = contact.displayName?.trim();
    final hasDisplayName = displayName != null && displayName.isNotEmpty;
    final shouldShowDisplayName = displayName != fullName;
    final showCustomDisplayName = hasDisplayName && shouldShowDisplayName;

    final isEditMode = ref.watch(
      contactsScreenControllerProvider.select((state) => state.isEditMode),
    );
    final isSelected = ref.watch(
      contactsScreenControllerProvider.select(
        (state) => state.selectedContacts.contains(contact),
      ),
    );

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => onTap(contact: contact, isSelected: isSelected),
              onDoubleTap: () => onDoubleTap(contact: contact),
              onLongPress: () => onLongPress(contact: contact),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: contact.getStatusColor(
                              context,
                              asAvatar: true,
                            ),
                            width: 2,
                          ),
                        ),
                        child: _ContactAvatar(contact: contact),
                      ),
                      if (contact.badgeCount > 0 || contact.isOobContact)
                        Positioned(
                          bottom: -5,
                          right: -15,
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
                                ),
                        )
                      else if (contact.isNewUnopenedChannel)
                        Positioned(
                          bottom: -3,
                          right: -3,
                          child: _ContactNewChannelDotBadge(
                            origin: contact.origin,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (showCustomDisplayName)
                    Column(
                      children: [
                        Text(
                          contact.displayName!,
                          style: context.textTheme.bodySmall?.copyWith(
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
                    ),
                  Text(
                    fullName,
                    style: contact.type == ContactType.individual
                        ? (hasDisplayName
                              ? context.textTheme.labelSmall
                              : context.textTheme.titleSmall)
                        : context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colorScheme.onSurface.withAlpha(179),
                          ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: showCustomDisplayName ? 1 : 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isEditMode)
          Positioned(
            top: -10,
            right: 0,
            child: Checkbox(
              value: isSelected,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              onChanged: (_) => onTap(contact: contact, isSelected: isSelected),
            ),
          ),
      ],
    );
  }
}
