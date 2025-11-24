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
                        key: const Key('chat_contact_title'),
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
                    key: const Key('group_member_details_hint'),
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
      key: const Key('individual_chat_name'),
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
    final image = ref.watch(provider.select(
        (state) => state.contact?.vCard.image(cacheManager: cacheManager)));

    return SizedBox(
      height: 55,
      width: 55,
      child: Card(
        key: const Key('chat_contact_avatar'),
        color: const Color.fromARGB(10, 255, 255, 255),
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.0),
        ),
        elevation: 5,
        child: Image(
          fit: BoxFit.cover,
          image: image!,
        ),
      ),
    );
  }
}
