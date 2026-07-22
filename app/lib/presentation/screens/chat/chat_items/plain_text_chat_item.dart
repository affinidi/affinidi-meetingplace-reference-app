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
  static const double _maxTextBubbleWidthFactor = 0.67;

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
    final signatureAttachments = attachments
        .where((a) => a.format == chat.CiergeSignatureProof.attachmentFormat)
        .toList(growable: false);
    final nonSignatureAttachments = attachments
        .where((a) => a.format != chat.CiergeSignatureProof.attachmentFormat)
        .toList(growable: false);
    final containsBoundedLayoutAttachment = attachments.any(
      (attachment) => attachment.isVoice || attachment.isRCard,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBubbleWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth * _maxTextBubbleWidthFactor
            : double.infinity;

        Widget bubbleContent = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final attachment in nonSignatureAttachments)
              _AttachmentWidget(
                contactId: _contactId,
                chatItem: chatItem,
                attachment: attachment,
                isFromMe: chatItem.isFromMe,
                chatItemColor: _chatItemColor,
              ),
            if (chatItem.value.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(
                  nonSignatureAttachments.isEmpty ? 0 : 8,
                ),
                child: _TextMessage(
                  text: chatItem.value,
                  shouldScaleEmojis: shouldScaleEmojis,
                  isEdited: chatItem.editedAt != null,
                ),
              ),
            for (final attachment in signatureAttachments)
              _AttachmentWidget(
                contactId: _contactId,
                chatItem: chatItem,
                attachment: attachment,
                isFromMe: chatItem.isFromMe,
                chatItemColor: _chatItemColor,
              ),
          ],
        );

        if (!containsBoundedLayoutAttachment) {
          bubbleContent = IntrinsicWidth(child: bubbleContent);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: onLongPress,
          onTap: () async {
            await copyToClipboard();
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBubbleWidth),
            child: bubbleContent,
          ),
        );
      },
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
    required this._chatItemColor,
  }) : _attachment = attachment,
       super(key: ValueKey('chat_attachment_${attachment.id}'));

  final ChatAttachment _attachment;
  final chat.Message _chatItem;
  final String _contactId;
  final bool _isFromMe;
  final Color _chatItemColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final chatState = ref.watch(provider);

    final plugins = ref.read(availableAttachmentPluginsProvider);

    Future<Uint8List> downloadCallback(ChatAttachment attachment) =>
        controller.downloadAttachmentForPlugin(attachment);
    final renderContext = AttachmentRenderContext(
      avatarImage: _voiceAvatarImage(
        state: chatState,
        message: _chatItem,
        cacheManager: ref.read(cacheManagerProvider),
      ),
      playbackScopeId: _contactId,
      playbackClipId: _playbackClipId(controller),
    );

    for (final plugin in plugins.whereType<AttachmentRenderer>()) {
      if (plugin.supportsFormat(_attachment)) {
        final child = plugin.renderAttachment(
          AttachmentRenderRequest(
            attachment: _attachment,
            isFromMe: _isFromMe,
            chatItemColor: _chatItemColor,
            renderContext: renderContext,
            download: downloadCallback,
          ),
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

  String _playbackClipId(ChatScreenController controller) =>
      controller.voiceClipId(_playbackAttachmentKey(_attachment));

  String _playbackAttachmentKey(ChatAttachment attachment) {
    final id = attachment.id;
    if (id.isNotEmpty) return 'chat_attachment_$id';

    final transportId = attachment.transportId;
    if (transportId != null && transportId.isNotEmpty) {
      return 'chat_attachment_transport_$transportId';
    }

    return attachment.data?.links?.firstOrNull?.toString() ??
        'chat_attachment_${identityHashCode(attachment)}';
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
