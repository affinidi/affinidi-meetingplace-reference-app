part of 'chat_screen.dart';

class _ChatContactDisplayName extends ConsumerWidget {
  _ChatContactDisplayName({required String contactId}) : _contactId = contactId;

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final hasContact = ref.watch(provider
        .select((state) => state.isInitialized && state.contact != null));

    if (!hasContact) {
      return const SizedBox.shrink();
    }

    final navigationBarTitle = ref.watch(provider.navigationBarTitle);
    final hasDisplayName = ref.read(provider
        .select((state) => state.contact?.displayName?.isNotEmpty ?? false));
    final isGroupChat = ref.read(provider.isGroupChat);

    return GestureDetector(
      onTap: () async {
        FocusManager.instance.primaryFocus?.unfocus();

        if (!context.mounted) return;

        await ConnectionDetailsRoute(contactId: _contactId).push<void>(context);
      },
      child: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ChatContactImage(contactId: _contactId),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        navigationBarTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: hasDisplayName
                            ? context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.theme.colorScheme.onPrimary,
                              )
                            : context.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.theme.colorScheme.onPrimary,
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                      child: ChatContactPresenceStatus(contactId: _contactId),
                    ),
                  ],
                ),
                if (!isGroupChat && hasDisplayName)
                  _IndividualChatName(contactId: _contactId),
                if (isGroupChat)
                  Text(
                    context.l10n.chatScreenTapForMemberDetails,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.theme.colorScheme.onPrimary
                          .withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _IndividualChatName extends ConsumerWidget {
  _IndividualChatName({required String contactId}) : _contactId = contactId;

  final String _contactId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final fullName = ref.watch(provider).contact?.vCard.fullName ?? '';

    return Text(
      fullName,
      style: context.textTheme.labelMedium?.copyWith(
          color: context.theme.colorScheme.onPrimary.withValues(alpha: 0.8)),
    );
  }
}

class _ChatContactImage extends ConsumerWidget {
  _ChatContactImage({required String contactId}) : _contactId = contactId;

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final cacheManager = ref.read(cacheManagerProvider);
    final contact = ref.watch(provider.select((state) => state.contact));

    if (contact == null) return const SizedBox.shrink();

    final displayImage = contact.image(cacheManager: cacheManager);
    final isGroupOrDefaultImage = contact.hasDefaultImage;

    return SizedBox(
      height: 55,
      width: 55,
      child: Card(
        color:
            isGroupOrDefaultImage ? Colors.white : Colors.white.withAlpha(10),
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        elevation: 5,
        child: isGroupOrDefaultImage
            ? Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Image(
                    fit: BoxFit.contain,
                    image: displayImage,
                  ),
                ),
              )
            : Image(
                fit: BoxFit.cover,
                image: displayImage,
              ),
      ),
    );
  }
}
