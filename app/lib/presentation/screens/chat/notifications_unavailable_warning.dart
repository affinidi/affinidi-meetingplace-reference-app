part of 'chat_screen.dart';

/// Informs users if notifications are available
class _NotificationsUnavailableWarning extends ConsumerWidget {
  _NotificationsUnavailableWarning(String contactId) : _contactId = contactId;

  final String _contactId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final notificationToken =
        ref.watch(provider.select((state) => state.notificationToken));
    final isIndividual = ref.watch(
      provider.select((state) => state.contact?.type == ContactType.individual),
    );
    final isDirectInteractive = ref.watch(
      provider.select(
        (state) => state.contact?.origin == ContactOrigin.directInteractive,
      ),
    );

    if (!isIndividual) {
      return const SizedBox.shrink();
    }

    if (notificationToken?.isNotEmpty ?? false) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            color: context.theme.colorScheme.inversePrimary,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              isDirectInteractive
                  ? context.l10n.chatNotificationsUnavailable
                  : context.l10n.chatNotificationsUnavailableNotShared,
              style: context.textTheme.headlineSmall
                  ?.copyWith(color: context.theme.colorScheme.surface),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
