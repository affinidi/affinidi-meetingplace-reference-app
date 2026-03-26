part of 'chat_screen.dart';

class _AttachmentUploadingIndicator extends ConsumerWidget {
  const _AttachmentUploadingIndicator({required String contactId})
    : _contactId = contactId;

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSendingAttachment = ref.watch(
      chatScreenControllerProvider(_contactId).select(
        (state) => state.isSendingAttachment,
      ),
    );

    if (!isSendingAttachment) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.uploadingImage,
            style: const TextStyle(color: Colors.blueGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
