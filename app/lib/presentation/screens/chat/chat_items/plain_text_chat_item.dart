part of '../chat_screen.dart';

class _PlainTextChatItem extends ConsumerWidget {
  _PlainTextChatItem({
    required chat.Message chatItem,
    required this._contactId,
    required this._index,
    required this._chatItemColor,
  }) : _chatItem = chatItem,
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

    final supportsMessageActions = ref.watch(
      provider.select((state) {
        final capabilities = state.capabilities;
        return (capabilities?.supports(chat.ChatFeature.messageEdit) ??
                false) ||
            (capabilities?.supports(chat.ChatFeature.messageDelete) ?? false);
      }),
    );

    Future<void> showMessageActions() async {
      if (!context.mounted) return;
      controller.clearSelectedReaction();
      await _ChatMessageActions.show(
        context: context,
        contactId: _contactId,
        message: chatItem,
      );
    }

    void onLongPress() {
      if (chatItem.isDeleted || chatItem.isDeletedLocally) return;
      if (chatItem.isFromMe) {
        if (!supportsMessageActions) return;
        unawaited(showMessageActions());
      } else {
        selectReaction();
      }
    }

    Future<void> copyToClipboard() async {
      if (!context.mounted) return;

      if (chatItem.value.isEmpty) return;
      if (chatItem.isDeleted || chatItem.isDeletedLocally) return;

      await Clipboard.setData(ClipboardData(text: chatItem.value));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.messageCopiedClipboard),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    if (chatItem.isDeleted || chatItem.isDeletedLocally) {
      final label = chatItem.isDeletedLocally
          ? context.l10n.chatMessageDeletedLocallyTombstone
          : context.l10n.chatMessageDeletedTombstone;
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
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

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: () async {
        await copyToClipboard();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (attachments.isNotEmpty)
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                return _AttachmentWidget(
                  contactId: _contactId,
                  chatItem: chatItem,
                  attachment: attachment,
                  isFromMe: chatItem.isFromMe,
                  senderDid: chatItem.senderDid,
                  chatItemColor: _chatItemColor,
                );
              },
            ),
          if (chatItem.value.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(attachments.isEmpty ? 0 : 8),
              child: _TextMessage(
                text: chatItem.value,
                shouldScaleEmojis: shouldScaleEmojis,
                isEdited: chatItem.editedAt != null,
              ),
            ),
        ],
      ),
    );
  }
}

class _TextMessage extends StatelessWidget {
  const _TextMessage({
    required this._text,
    required this._shouldScaleEmojis,
    required this._isEdited,
  });

  final String _text;
  final bool _shouldScaleEmojis;
  final bool _isEdited;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Container(
        constraints: const BoxConstraints(minWidth: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _text,
              textAlign: _text.length < 6 ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                color: Colors.white,
                fontSize: _shouldScaleEmojis ? 42.0 : 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_isEdited)
              Text(
                context.l10n.chatMessageEditedLabel,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentWidget extends HookConsumerWidget {
  _AttachmentWidget({
    required this._contactId,
    required this._chatItem,
    required ChatAttachment attachment,
    required this._isFromMe,
    required this._senderDid,
    required this._chatItemColor,
  }) : _attachment = attachment,
       super(key: ValueKey('chat_attachment_${attachment.id!}'));

  final ChatAttachment _attachment;
  final chat.Message _chatItem;
  final String _contactId;
  final bool _isFromMe;
  final String _senderDid;
  final Color _chatItemColor;

  bool get _isHostedMedia =>
      _attachment.format == AttachmentFormat.hostedMedia.value;
  bool get _isVoiceMessage => chat.VoiceMessageMetadata.isVoice(_attachment);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final chatState = ref.watch(provider);

    final plugins = ref.read(availableAttachmentPluginsProvider);

    for (final plugin in plugins) {
      if (plugin.supportsFormat(_attachment)) {
        final child = plugin is AudioAttachmentsPlugin
            ? plugin.renderAttachmentWithAvatar(
                attachment: _attachment,
                isFromMe: _isFromMe,
                chatItemColor: _chatItemColor,
                avatarImage: _voiceAvatarImage(
                  state: chatState,
                  message: _chatItem,
                  cacheManager: ref.read(cacheManagerProvider),
                ),
                download: downloadCallback,
              )
            : plugin.renderAttachment(
                attachment: _attachment,
                isFromMe: _isFromMe,
                chatItemColor: _chatItemColor,
                download: downloadCallback,
              );
        if (_attachment.isRCard) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(width: constraints.maxWidth, child: child);
            },
          );
        }
        return child;
      }
    }

    return const SizedBox.shrink();
  }

  ImageProvider<Object>? _voiceAvatarImage({
    required ChatScreenState state,
    required chat.Message message,
    required BaseCacheManager cacheManager,
  }) {
    if (message.isFromMe) {
      return state.myCard?.image(cacheManager: cacheManager) ??
          defaultProfileImage;
    }

    final group = state.group;
    if (group != null) {
      final member = group.members.firstWhereOrNull(
        (member) => member.did == message.senderDid,
      );
      if (member == null || !member.contactCard.hasProfilePic) return null;
      return member.contactCard.image(cacheManager: cacheManager);
    }

    return state.contact?.card.image(cacheManager: cacheManager) ??
        state.otherPartyCard?.image(cacheManager: cacheManager) ??
        defaultProfileImage;
  }
}

class _EditMessageDialog extends StatefulWidget {
  const _EditMessageDialog({required this.initialText});

  final String initialText;

  static Future<String?> show(
    BuildContext context, {
    required String initialText,
  }) => showDialog<String>(
    context: context,
    builder: (_) => _EditMessageDialog(initialText: initialText),
  );

  @override
  State<_EditMessageDialog> createState() => _EditMessageDialogState();
}

class _EditMessageDialogState extends State<_EditMessageDialog> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.chatMessageActionEdit),
      content: TextField(
        controller: _textController,
        autofocus: true,
        maxLines: null,
        decoration: InputDecoration(hintText: context.l10n.chatMessageEditHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.generalCancel),
        ),
        TextButton(
          onPressed: () {
            final value = _textController.text.trim();
            if (value.isEmpty || value == widget.initialText) {
              Navigator.of(context).pop();
              return;
            }
            Navigator.of(context).pop(value);
          },
          child: Text(context.l10n.chatMessageEditSave),
        ),
      ],
    );
  }
}

class _HostedMediaWidget extends HookConsumerWidget {
  const _HostedMediaWidget({
    required this._contactId,
    required this._attachment,
    required this._isFromMe,
    required this._senderDid,
    required this._chatItemColor,
  });

  final String _contactId;
  final chat.ChatAttachment _attachment;
  final bool _isFromMe;
  final String _senderDid;
  final Color _chatItemColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheKey = AttachmentCacheService.cacheKey(_attachment);
    final chatController = ref.read(
      chatScreenControllerProvider(_contactId).notifier,
    );
    final voiceClipId = chatController.voiceClipId(cacheKey);
    final cached = ref.watch(
      attachmentCacheServiceProvider(
        _contactId,
      ).select((cache) => cache[cacheKey]),
    );
    // A failed download is recorded as an empty cache entry; treat empty bytes
    // as a failure and surface a retry affordance instead of rendering them.
    final hasFailed = cached != null && cached.isEmpty;
    final cachedBytes = (cached != null && cached.isNotEmpty) ? cached : null;
    bool onRetry() => ref
        .read(attachmentCacheServiceProvider(_contactId).notifier)
        .retry(_attachment);
    bool onDownload() => ref
        .read(attachmentCacheServiceProvider(_contactId).notifier)
        .loadAttachment(_attachment);

    final category = mediaCategoryFromMimeType(_attachment.mediaType);
    // Images have no manual download affordance, so they auto-load. Auto-loads
    // never poison the cache and retry on a backoff, because historical Matrix
    // events decrypt asynchronously after the room syncs.
    final shouldLoadImage = category == MediaCategory.image && cached == null;
    useEffect(() {
      if (shouldLoadImage) {
        ref
            .read(attachmentCacheServiceProvider(_contactId).notifier)
            .autoLoad(_attachment);
      }
      return null;
    }, [cacheKey, shouldLoadImage]);

    if (chat.VoiceMessageMetadata.isVoice(_attachment)) {
      return _HostedAudioWidget(
        clipId: voiceClipId,
        contactId: _contactId,
        attachment: _attachment,
        cachedBytes: cachedBytes,
        hasFailed: hasFailed,
        onRetry: onRetry,
        onDownload: onDownload,
        isFromMe: _isFromMe,
        chatItemColor: _chatItemColor,
        senderAvatar: _senderAvatar(ref),
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
          clipId: voiceClipId,
          contactId: _contactId,
          attachment: _attachment,
          cachedBytes: cachedBytes,
          hasFailed: hasFailed,
          onRetry: onRetry,
          onDownload: onDownload,
          isFromMe: _isFromMe,
          chatItemColor: _chatItemColor,
          senderAvatar: _senderAvatar(ref),
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

  ImageProvider<Object>? _senderAvatar(WidgetRef ref) {
    final cacheManager = ref.read(cacheManagerProvider);
    final provider = chatScreenControllerProvider(_contactId);

    if (_isFromMe) {
      final myCard = ref.watch(provider.select((s) => s.myCard));
      return myCard?.image(cacheManager: cacheManager);
    }

    if (ref.watch(provider.isGroupChat)) {
      final member = ref.watch(
        provider.select(
          (s) =>
              s.group?.members.firstWhereOrNull((gm) => gm.did == _senderDid),
        ),
      );
      final memberCard = member == null
          ? null
          : ContactCardUtils.fromSdkContactCard(member.contactCard);
      return memberCard?.image(cacheManager: cacheManager);
    }

    // 1:1 received: the chat contact is the message sender (the other party),
    // so show their card and fall back to the default image, like the header.
    final contact = ref.watch(provider.select((s) => s.contact));
    return contact?.image(cacheManager: cacheManager);
  }
}

class _HostedImageWidget extends StatelessWidget {
  const _HostedImageWidget({
    required this._cachedBytes,
    required this._hasFailed,
    required this._onRetry,
  });

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

    return ChatImageCard(imageBytes: _cachedBytes);
  }
}

final class _HostedVideoWidget extends StatefulWidget {
  const _HostedVideoWidget({
    required this._attachment,
    required this._cachedBytes,
    required this._hasFailed,
    required this._onRetry,
    required this._onDownload,
  });

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
    required this._attachment,
    required this._cachedBytes,
    required this._hasFailed,
    required this._onRetry,
    required this._onDownload,
  });

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
      // Use a uniquely-named file so concurrent opens don't collide and so the
      // OS can clean it up on its own. The file must not be deleted immediately
      // after share() returns because on Android the receiving app reads
      // through the FileProvider URI after the intent is dispatched.
      final uniqueName =
          '${path.basenameWithoutExtension(safeName)}_'
          '${DateTime.now().millisecondsSinceEpoch}'
          '${path.extension(safeName)}';
      final tempFile = File('${tempDir.path}/$uniqueName');
      await tempFile.writeAsBytes(cachedBytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(tempFile.path)]),
      );
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
  const _MediaDownloadRetryBox({required this._onRetry});

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
