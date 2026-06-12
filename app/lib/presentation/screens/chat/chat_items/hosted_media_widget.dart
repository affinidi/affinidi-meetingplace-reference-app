part of '../chat_screen.dart';

class _HostedMediaWidget extends ConsumerWidget {
  const _HostedMediaWidget({
    required String contactId,
    required chat.ChatAttachment attachment,
  }) : _contactId = contactId,
       _attachment = attachment;

  final String _contactId;
  final chat.ChatAttachment _attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cachedBytes = ref.watch(
      attachmentCacheServiceProvider(
        _contactId,
      ).select((cache) => cache[AttachmentCacheService.cacheKey(_attachment)]),
    );

    if (cachedBytes == null) {
      return const SizedBox(
        height: 200,
        width: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (cachedBytes.isEmpty) {
      return const SizedBox(
        height: 200,
        width: 200,
        child: Center(child: Icon(Icons.broken_image_outlined)),
      );
    }

    return ChatImageCard(imageBytes: cachedBytes);
  }
}
