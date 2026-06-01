part of '../chat_screen.dart';

class _PlainTextChatItem extends ConsumerWidget {
  _PlainTextChatItem({
    required chat.Message chatItem,
    required String contactId,
    required int index,
    required Color chatItemColor,
  }) : _chatItem = chatItem,
       _contactId = contactId,
       _index = index,
       _chatItemColor = chatItemColor,
       super(key: ValueKey('chat_message_${chatItem.messageId}'));

  final chat.Message _chatItem;
  final String _contactId;
  final int _index;
  final Color _chatItemColor;
  static const int _maximumEmojisForLargeScale = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final chatItem = ref.watch(
      provider.select(
        (state) =>
            (state.messages.firstWhereOrNull(
                      (m) => m.messageId == _chatItem.messageId,
                    ) ??
                    _chatItem)
                as chat.Message,
      ),
    );

    void selectReaction() {
      if (!context.mounted) return;

      if (chatItem.isFromMe) {
        controller.clearSelectedReaction();
        return;
      }

      controller.selectReactionAtIndex(_index);
    }

    Future<void> copyToClipboard() async {
      if (!context.mounted) return;

      if (chatItem.value.isEmpty) return;

      await Clipboard.setData(ClipboardData(text: chatItem.value));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.messageCopiedClipboard),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    final emojiCount = chatItem.value.countEmojis;
    final isOnlyEmojiMessage = chatItem.value.isOnlyEmojis;
    final shouldScaleEmojis =
        isOnlyEmojiMessage &&
        emojiCount > 0 &&
        emojiCount <= _maximumEmojisForLargeScale;
    final attachments = chatItem.attachments;

    final hasMedia = attachments.isNotEmpty;
    final showText = chatItem.value.isNotEmpty;

    return GestureDetector(
      onLongPress: selectReaction,
      onTap: hasMedia ? null : () async => copyToClipboard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (hasMedia)
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                return _AttachmentWidget(
                  contactId: _contactId,
                  attachment: attachment,
                  isFromMe: chatItem.isFromMe,
                  chatItemColor: _chatItemColor,
                );
              },
            ),
          if (showText)
            Padding(
              padding: EdgeInsets.all(hasMedia ? 8.0 : 0),
              child: _TextMessage(
                text: chatItem.value,
                shouldScaleEmojis: shouldScaleEmojis,
              ),
            ),
        ],
      ),
    );
  }
}

class _TextMessage extends StatelessWidget {
  const _TextMessage({required String text, required bool shouldScaleEmojis})
    : _text = text,
      _shouldScaleEmojis = shouldScaleEmojis;

  final String _text;
  final bool _shouldScaleEmojis;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Container(
        constraints: const BoxConstraints(minWidth: 25),
        child: Text(
          _text,
          textAlign: _text.length < 6 ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: Colors.white,
            fontSize: _shouldScaleEmojis
                ? 42.0
                : 14.0, // 3x size for emoji-only messages
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AttachmentWidget extends HookConsumerWidget {
  _AttachmentWidget({
    required String contactId,
    required chat.ChatAttachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
  }) : _contactId = contactId,
       _attachment = attachment,
       _isFromMe = isFromMe,
       _chatItemColor = chatItemColor,
       super(key: ValueKey(attachmentCacheKey(attachment)));

  final String _contactId;
  final chat.ChatAttachment _attachment;
  final bool _isFromMe;
  final Color _chatItemColor;

  bool get _isHostedMedia =>
      _attachment.format == AttachmentFormat.hostedMedia.value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isHostedMedia) {
      return _HostedMediaWidget(contactId: _contactId, attachment: _attachment);
    }

    final plugins = ref.read(availableAttachmentPluginsProvider);

    for (final plugin in plugins) {
      if (plugin.supportsFormat(_attachment)) {
        return plugin.renderAttachment(
          attachment: _attachment,
          isFromMe: _isFromMe,
          chatItemColor: _chatItemColor,
        );
      }
    }

    return const SizedBox.shrink();
  }
}

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
    final provider = chatScreenControllerProvider(_contactId);
    final cachedBytes = ref.watch(
      provider.select(
        (s) => s.attachmentsDataCache[attachmentCacheKey(_attachment)],
      ),
    );

    final category = mediaCategoryFromMimeType(_attachment.mediaType);

    switch (category) {
      case MediaCategory.video:
        return _HostedVideoWidget(
          attachment: _attachment,
          cachedBytes: cachedBytes,
        );
      case MediaCategory.audio:
      case MediaCategory.document:
        return _HostedDocumentWidget(
          attachment: _attachment,
          cachedBytes: cachedBytes,
        );
      case MediaCategory.image:
        return _HostedImageWidget(cachedBytes: cachedBytes);
    }
  }
}

class _HostedImageWidget extends StatelessWidget {
  const _HostedImageWidget({required Uint8List? cachedBytes})
    : _cachedBytes = cachedBytes;

  final Uint8List? _cachedBytes;

  @override
  Widget build(BuildContext context) {
    if (_cachedBytes == null) {
      return const SizedBox(
        height: 200,
        width: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_cachedBytes!.isEmpty) {
      return const SizedBox(
        height: 200,
        width: 200,
        child: Center(child: Icon(Icons.broken_image_outlined)),
      );
    }

    return SizedBox(
      height: 200,
      width: 200,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute<void>(
              builder: (context) => ImageViewScreen(imageBytes: _cachedBytes),
            ),
          );
        },
        child: Card(
          color: const Color.fromARGB(0, 10, 10, 10),
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child: Image.memory(_cachedBytes, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _HostedVideoWidget extends StatelessWidget {
  const _HostedVideoWidget({
    required chat.ChatAttachment attachment,
    required Uint8List? cachedBytes,
  }) : _attachment = attachment,
       _cachedBytes = cachedBytes;

  final chat.ChatAttachment _attachment;
  final Uint8List? _cachedBytes;

  @override
  Widget build(BuildContext context) {
    if (_cachedBytes == null) {
      return const SizedBox(
        height: 200,
        width: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_cachedBytes!.isEmpty) {
      return const SizedBox(
        height: 200,
        width: 200,
        child: Center(child: Icon(Icons.broken_image_outlined)),
      );
    }

    return SizedBox(
      height: 200,
      width: 200,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push<void>(
            MaterialPageRoute<void>(
              builder: (context) => _VideoPlayerScreen(
                videoBytes: _cachedBytes,
                filename: _attachment.filename,
              ),
            ),
          );
        },
        child: Card(
          color: const Color.fromARGB(0, 10, 10, 10),
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5,
          child: const Center(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 56,
            ),
          ),
        ),
      ),
    );
  }
}

class _HostedDocumentWidget extends StatelessWidget {
  const _HostedDocumentWidget({
    required chat.ChatAttachment attachment,
    required Uint8List? cachedBytes,
  }) : _attachment = attachment,
       _cachedBytes = cachedBytes;

  final chat.ChatAttachment _attachment;
  final Uint8List? _cachedBytes;

  @override
  Widget build(BuildContext context) {
    final filename = _attachment.filename ?? 'Document';
    final size = _attachment.byteCount;
    final sizeLabel = size != null ? _formatFileSize(size) : '';
    final isLoaded = _cachedBytes != null && _cachedBytes!.isNotEmpty;
    final hasFailed = _cachedBytes != null && _cachedBytes!.isEmpty;

    return SizedBox(
      width: 220,
      child: GestureDetector(
        onTap: isLoaded ? () => _openDocument(context) : null,
        child: Card(
          color: Colors.grey.shade900,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  _iconForMimeType(_attachment.mediaType),
                  color: Colors.white70,
                  size: 32,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        filename,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (sizeLabel.isNotEmpty)
                        Text(
                          sizeLabel,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      if (!isLoaded && !hasFailed)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            context.l10n.documentTapToDownload,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      if (hasFailed)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'Download failed',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isLoaded && !hasFailed)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (hasFailed)
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDocument(BuildContext context) async {
    if (_cachedBytes == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final filename = _attachment.filename ?? 'document';
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(_cachedBytes);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (e, stackTrace) {
      AppLogger.instance.error(
        'Failed to open document',
        error: e,
        stackTrace: stackTrace,
        name: '_HostedDocumentWidget',
      );
    }
  }

  IconData _iconForMimeType(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('word') || mimeType.contains('doc')) {
      return Icons.description;
    }
    if (mimeType.contains('sheet') ||
        mimeType.contains('excel') ||
        mimeType.contains('csv')) {
      return Icons.table_chart;
    }
    if (mimeType.contains('presentation') || mimeType.contains('powerpoint')) {
      return Icons.slideshow;
    }
    if (mimeType.contains('zip') ||
        mimeType.contains('tar') ||
        mimeType.contains('gz')) {
      return Icons.folder_zip;
    }
    if (mimeType.contains('text/')) return Icons.article;
    return Icons.insert_drive_file;
  }

  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
