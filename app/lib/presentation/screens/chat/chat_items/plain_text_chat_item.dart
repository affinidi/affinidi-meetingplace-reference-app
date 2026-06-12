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

    // Watch mutable fields so Riverpod triggers a rebuild when
    // the SDK mutates the Message object in place.
    ref.watch(
      provider.select((state) {
        final m =
            state.messages.firstWhereOrNull(
                  (m) => m.messageId == _chatItem.messageId,
                )
                as chat.Message?;
        return (m?.value, m?.editedAt, m?.isDeleted, m?.isDeletedLocally);
      }),
    );

    void selectReaction() {
      if (!context.mounted) return;

      if (chatItem.isFromMe) {
        controller.clearSelectedReaction();
        return;
      }

      controller.selectReactionAtIndex(_index);
    }

    Future<void> showMessageActions() async {
      if (!context.mounted) return;
      controller.clearSelectedReaction();
      final result = await _ChatMessageActions.show(
        context: context,
        contactId: _contactId,
        message: chatItem,
      );
      if (result == _MessageActionResult.edit && context.mounted) {
        await _showEditDialog(context, controller, chatItem);
      }
    }

    void onLongPress() {
      if (chatItem.isDeleted || chatItem.isDeletedLocally) return;
      if (chatItem.isFromMe) {
        unawaited(showMessageActions());
      } else {
        selectReaction();
      }
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

    final hasMedia = attachments.isNotEmpty;
    final showText = chatItem.value.isNotEmpty;

    return GestureDetector(
      onLongPress: onLongPress,
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
    required String text,
    required bool shouldScaleEmojis,
    required bool isEdited,
  }) : _text = text,
       _shouldScaleEmojis = shouldScaleEmojis,
       _isEdited = isEdited;

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
          crossAxisAlignment: CrossAxisAlignment.end,
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
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  context.l10n.chatMessageEditedLabel,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentWidget extends ConsumerWidget {
  _AttachmentWidget({
    required String contactId,
    required chat.ChatAttachment attachment,
    required bool isFromMe,
    required Color chatItemColor,
  }) : _contactId = contactId,
       _attachment = attachment,
       _isFromMe = isFromMe,
       _chatItemColor = chatItemColor,
       super(key: ValueKey(AttachmentCacheService.cacheKey(attachment)));

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

Future<void> _showEditDialog(
  BuildContext context,
  ChatScreenController controller,
  chat.Message message,
) async {
  final messenger = ScaffoldMessenger.of(context);

  final newText = await showDialog<String>(
    context: context,
    builder: (dialogContext) => _EditMessageDialog(initialText: message.value),
  );

  if (newText != null) {
    try {
      await controller.editTextMessage(message.messageId, newText);
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.l10n.chatMessageEditFailed),
          backgroundColor: context.colorScheme.error,
        ),
      );
    }
  }
}

class _EditMessageDialog extends StatefulWidget {
  const _EditMessageDialog({required this.initialText});

  final String initialText;

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
      title: const Text('Edit message'),
      content: TextField(
        controller: _textController,
        autofocus: true,
        maxLines: null,
        decoration: const InputDecoration(hintText: 'Message text'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}
