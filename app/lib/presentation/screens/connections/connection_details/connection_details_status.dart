part of 'connection_details_screen.dart';

class _Status extends ConsumerWidget {
  const _Status(this.contactId);

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(contactId);
    final contact = ref.watch(provider.select((state) => state.contact));
    final isGroupChat = ref.watch(provider.isGroupChat);

    if (contact?.status == null) {
      return const SizedBox.shrink();
    }

    return Chip(
      label: Text(
        isGroupChat
            ? context.l10n.groupContactStatus(contact?.status.name ?? '')
            : context.l10n.contactStatus(contact?.status.name ?? ''),
        style: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: contact?.getStatusColor(context),
    );
  }
}
