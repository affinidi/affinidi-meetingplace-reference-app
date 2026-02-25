part of 'chat_screen.dart';

/// Informs users if notifications are available
class _NotificationsUnavailableWarning extends ConsumerWidget {
  _NotificationsUnavailableWarning(String contactId) : _contactId = contactId;

  final String _contactId;

  void _showNotificationInfoBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colorScheme.inverseSurface,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.chatNotificationsWhyTitle,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.chatNotificationsWhyDescription,
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.chatNotificationsWhyNote,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.l10n.chatNotificationsWhyButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final contactType = ref.watch(
      provider.select((state) => state.contact?.type),
    );
    final isOobContact = ref.watch(
      provider.select((state) => state.contact?.isOobContact ?? false),
    );
    final notificationBannerDismissed = ref.watch(
      provider.select((state) => state.contact?.notificationBannerDismissed),
    );
    final notificationToken =
        ref.watch(provider.select((state) => state.notificationToken));

    if (contactType != ContactType.individual) {
      return const SizedBox.shrink();
    }

    if (notificationToken?.isNotEmpty ?? false) {
      return const SizedBox.shrink();
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: (notificationBannerDismissed == true)
          ? const SizedBox.shrink()
          : InfoBanner(
              key: const Key('notifications_unavailable_banner'),
              icon: Icons.notifications_off_outlined,
              onDismiss: controller.dismissNotificationBanner,
              child: RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: isOobContact
                          ? context.l10n.chatNotificationsUnavailable
                          : context.l10n.chatNotificationsUnavailableNotShared,
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: context.l10n.chatNotificationsWhyLink,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _showNotificationInfoBottomSheet(context);
                        },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
