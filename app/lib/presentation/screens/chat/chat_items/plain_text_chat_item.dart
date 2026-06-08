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
  bool get _isVoiceMessage =>
      _attachment.mediaKind == chat.AttachmentMediaKind.voice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (_isHostedMedia || _isVoiceMessage) {
      return _HostedMediaWidget(
        contactId: _contactId,
        attachment: _attachment,
        isFromMe: _isFromMe,
        chatItemColor: _chatItemColor,
      );
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
    required bool isFromMe,
    required Color chatItemColor,
  }) : _contactId = contactId,
       _attachment = attachment,
       _isFromMe = isFromMe,
       _chatItemColor = chatItemColor;

  final String _contactId;
  final chat.ChatAttachment _attachment;
  final bool _isFromMe;
  final Color _chatItemColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final cacheKey = attachmentCacheKey(_attachment);
    final cachedBytes = ref.watch(
      provider.select((s) => s.attachmentsDataCache[cacheKey]),
    );
    final hasFailed = ref.watch(
      provider.select((s) => s.failedAttachmentDownloads.contains(cacheKey)),
    );
    bool onRetry() =>
        ref.read(provider.notifier).retryAttachmentDownload(_attachment);
    bool onDownload() =>
        ref.read(provider.notifier).loadMediaAttachment(_attachment);

    final category = mediaCategoryFromMimeType(_attachment.mediaType);
    if (_attachment.mediaKind == chat.AttachmentMediaKind.voice) {
      return _HostedAudioWidget(
        attachment: _attachment,
        cachedBytes: cachedBytes,
        hasFailed: hasFailed,
        onRetry: onRetry,
        isFromMe: _isFromMe,
        chatItemColor: _chatItemColor,
      );
    }

    switch (category) {
      case MediaCategory.video:
        return _HostedVideoWidget(
          attachment: _attachment,
          cachedBytes: cachedBytes,
          hasFailed: hasFailed,
          onRetry: onRetry,
          onDownload: onDownload,
        );
      case MediaCategory.audio:
        return _HostedAudioWidget(
          attachment: _attachment,
          cachedBytes: cachedBytes,
          hasFailed: hasFailed,
          onRetry: onRetry,
          isFromMe: _isFromMe,
          chatItemColor: _chatItemColor,
        );
      case MediaCategory.document:
        return _HostedDocumentWidget(
          attachment: _attachment,
          cachedBytes: cachedBytes,
          hasFailed: hasFailed,
          onRetry: onRetry,
          onDownload: onDownload,
        );
      case MediaCategory.image:
        return _HostedImageWidget(
          cachedBytes: cachedBytes,
          hasFailed: hasFailed,
          onRetry: onRetry,
        );
    }
  }
}

class _HostedImageWidget extends StatelessWidget {
  const _HostedImageWidget({
    required Uint8List? cachedBytes,
    required bool hasFailed,
    required VoidCallback onRetry,
  }) : _cachedBytes = cachedBytes,
       _hasFailed = hasFailed,
       _onRetry = onRetry;

  final Uint8List? _cachedBytes;
  final bool _hasFailed;
  final VoidCallback _onRetry;

  @override
  Widget build(BuildContext context) {
    if (_hasFailed) {
      return _MediaDownloadRetryBox(onRetry: _onRetry);
    }

    if (_cachedBytes == null) {
      return const SizedBox(
        height: 200,
        width: 200,
        child: Center(child: CircularProgressIndicator()),
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

final class _HostedVideoWidget extends StatefulWidget {
  const _HostedVideoWidget({
    required chat.ChatAttachment attachment,
    required Uint8List? cachedBytes,
    required bool hasFailed,
    required bool Function() onRetry,
    required bool Function() onDownload,
  }) : _attachment = attachment,
       _cachedBytes = cachedBytes,
       _hasFailed = hasFailed,
       _onRetry = onRetry,
       _onDownload = onDownload;

  final chat.ChatAttachment _attachment;
  final Uint8List? _cachedBytes;
  final bool _hasFailed;
  final bool Function() _onRetry;
  final bool Function() _onDownload;

  @override
  State<_HostedVideoWidget> createState() => _HostedVideoWidgetState();
}

final class _HostedVideoWidgetState extends State<_HostedVideoWidget> {
  bool _isDownloading = false;

  @override
  void didUpdateWidget(covariant _HostedVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._cachedBytes != null || widget._hasFailed) {
      _isDownloading = false;
    }
  }

  void _startDownload(bool Function() action) {
    if (_isDownloading) return;
    if (!action()) return;
    setState(() => _isDownloading = true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget._hasFailed) {
      return _MediaDownloadRetryBox(
        onRetry: () => _startDownload(widget._onRetry),
      );
    }

    final cachedBytes = widget._cachedBytes;
    if (cachedBytes == null) {
      return SizedBox(
        height: 200,
        width: 200,
        child: GestureDetector(
          onTap: _isDownloading
              ? null
              : () => _startDownload(widget._onDownload),
          child: Card(
            color: const Color.fromARGB(0, 10, 10, 10),
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            child: Center(
              child: _isDownloading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.video_file,
                          color: Colors.white70,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        const Icon(
                          Icons.download,
                          color: Colors.white70,
                          size: 24,
                        ),
                        if (widget._attachment.filename != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                              left: 8,
                              right: 8,
                            ),
                            child: Text(
                              widget._attachment.filename!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
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
                videoBytes: cachedBytes,
                filename: widget._attachment.filename,
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

final class _HostedDocumentWidget extends StatefulWidget {
  const _HostedDocumentWidget({
    required chat.ChatAttachment attachment,
    required Uint8List? cachedBytes,
    required bool hasFailed,
    required bool Function() onRetry,
    required bool Function() onDownload,
  }) : _attachment = attachment,
       _cachedBytes = cachedBytes,
       _hasFailed = hasFailed,
       _onRetry = onRetry,
       _onDownload = onDownload;

  final chat.ChatAttachment _attachment;
  final Uint8List? _cachedBytes;
  final bool _hasFailed;
  final bool Function() _onRetry;
  final bool Function() _onDownload;

  @override
  State<_HostedDocumentWidget> createState() => _HostedDocumentWidgetState();
}

final class _HostedDocumentWidgetState extends State<_HostedDocumentWidget> {
  bool _isDownloading = false;

  @override
  void didUpdateWidget(covariant _HostedDocumentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget._cachedBytes != null || widget._hasFailed) {
      _isDownloading = false;
    }
  }

  void _startDownload(bool Function() action) {
    if (_isDownloading) return;
    if (!action()) return;
    setState(() => _isDownloading = true);
  }

  @override
  Widget build(BuildContext context) {
    final filename = widget._attachment.filename ?? 'Document';
    final size = widget._attachment.byteCount;
    final sizeLabel = size != null ? _formatFileSize(size) : '';
    final cachedBytes = widget._cachedBytes;
    final isLoaded = cachedBytes != null && cachedBytes.isNotEmpty;

    return SizedBox(
      width: 220,
      child: GestureDetector(
        onTap: isLoaded
            ? () => _openDocument(context)
            : (widget._hasFailed
                  ? () => _startDownload(widget._onRetry)
                  : () => _startDownload(widget._onDownload)),
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
                  _iconForMimeType(widget._attachment.mediaType),
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
                      if (!isLoaded && !widget._hasFailed)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _isDownloading
                                ? context.l10n.loading
                                : context.l10n.documentTapToDownload,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      if (widget._hasFailed)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            context.l10n.mediaDownloadFailedTapToRetry,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isLoaded && !widget._hasFailed)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: _isDownloading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Icon(
                            Icons.download,
                            color: Colors.white54,
                            size: 16,
                          ),
                  ),
                if (widget._hasFailed)
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
    final cachedBytes = widget._cachedBytes;
    if (cachedBytes == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final safeName = path.basename(widget._attachment.filename ?? 'document');
      final file = File('${tempDir.path}/$safeName');
      await file.writeAsBytes(cachedBytes);
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

class _MediaDownloadRetryBox extends StatelessWidget {
  const _MediaDownloadRetryBox({required VoidCallback onRetry})
    : _onRetry = onRetry;

  final VoidCallback _onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 200,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onRetry,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.broken_image_outlined, size: 32),
              const SizedBox(height: 8),
              const Icon(Icons.refresh, size: 20),
              const SizedBox(height: 4),
              Text(
                context.l10n.mediaTapToRetry,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
