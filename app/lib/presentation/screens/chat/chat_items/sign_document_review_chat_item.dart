part of '../chat_screen.dart';

/// Renders a downloadable card for the ORIGINAL document attached to a step-up
/// sign request, so the approver can open and review the file before approving.
/// The connector delivers the document as an external attachment with the
/// [attachmentFormat] tag alongside the approval widget.
class _SignDocumentReviewChatItem extends ConsumerStatefulWidget {
  const _SignDocumentReviewChatItem({
    required this.attachment,
    required this.contactId,
  });

  /// Attachment format tag shared with the connector.
  static const attachmentFormat = 'cierge/sign-document-review';

  final ChatAttachment attachment;
  final String contactId;

  static bool matchAttachment(chat.ChatItem item) {
    if (item is! chat.Message) return false;
    return item.attachments.any((a) => a.format == attachmentFormat);
  }

  @override
  ConsumerState<_SignDocumentReviewChatItem> createState() =>
      _SignDocumentReviewChatItemState();
}

class _SignDocumentReviewChatItemState
    extends ConsumerState<_SignDocumentReviewChatItem> {
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final filename = widget.attachment.filename ?? 'Document';
    final mediaType = widget.attachment.mediaType;

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        gradient: RadialGradient(
          center: Alignment.bottomCenter,
          radius: 2,
          colors: [
            Color.fromARGB(255, 56, 56, 76),
            Color.fromARGB(255, 21, 21, 31),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: Colors.white70,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Document to review',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      filename,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (mediaType != null && mediaType.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        mediaType,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 40),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              onPressed: _busy ? null : _downloadAndOpen,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined, size: 18),
              label: Text(_busy ? 'Downloading...' : 'Download to review'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _downloadAndOpen() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final controller = ref.read(
        chatScreenControllerProvider(widget.contactId).notifier,
      );
      final bytes = await controller.downloadAttachmentForPlugin(
        widget.attachment,
      );

      final tempDir = await getTemporaryDirectory();
      final safeName = path.basename(widget.attachment.filename ?? 'document');
      final uniqueName =
          '${path.basenameWithoutExtension(safeName)}_'
          '${DateTime.now().millisecondsSinceEpoch}'
          '${path.extension(safeName)}';
      final tempFile = File('${tempDir.path}/$uniqueName');
      await tempFile.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(tempFile.path)]),
      );
      if (mounted) setState(() => _busy = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Failed to download: $e';
        });
      }
    }
  }
}
