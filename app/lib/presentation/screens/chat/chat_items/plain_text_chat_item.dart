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
    // Suppress raw msgtype values (e.g. "m.image") that leak from the
    // protocol layer — they are not meaningful user-facing text.
    final isRawMsgType = chatItem.value.startsWith('m.');
    final showText = chatItem.value.isNotEmpty && !isRawMsgType;

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

    if (cachedBytes == null) {
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
              builder: (context) => ImageViewScreen(imageBytes: cachedBytes),
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
          child: Image.memory(cachedBytes, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
