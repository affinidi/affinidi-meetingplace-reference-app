part of 'chat_screen.dart';

class _ChatMessageList extends HookConsumerWidget {
  const _ChatMessageList(this._contactId);

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final sortedMessages = ref.watch(
      provider.select((state) => state.messages),
    );
    final indexOfLastMessageFromMe = ref.watch(
      provider.indexOfLastMessageFromMe,
    );
    final selectedReactionIndex = ref.watch(
      provider.select((state) => state.selectedReactionIndex),
    );
    final zkpPolicy = ChatZkpMessageListPolicy.fromMessages(
      enabled:
          ref.read(environmentProvider).zkpEnabled &&
          (ref
                  .read(provider)
                  .capabilities
                  ?.supports(chat.ChatFeature.humanZkp) ??
              false),
      messages: sortedMessages,
    );
    final isGroupChat = ref.watch(
      provider.select((state) => state.group != null),
    );

    var lastUsedChatItemStatus = chat.ChatItemStatus.error;

    final scrollController = useScrollController();

    void hideReactionPicker() {
      if (!context.mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
      controller.clearSelectedReaction();
    }

    useEffect(() {
      if (!context.mounted) return;

      scrollController.addListener(() {
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          FocusManager.instance.primaryFocus?.unfocus();
          hideReactionPicker();
        }
      });

      return null;
    }, []);

    return GestureDetector(
      onTap: hideReactionPicker,
      child: Column(
        children: [
          _AwaitingMembersWarning(contactId: _contactId),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              reverse: true,
              findChildIndexCallback: (key) {
                if (key is! ValueKey<String>) return null;

                final messageId = key.value;
                final index = sortedMessages.indexWhere(
                  (message) => message.messageId == messageId,
                );

                return index == -1 ? null : index;
              },
              itemCount: sortedMessages.length,
              itemBuilder: (context, index) {
                final chatItem = sortedMessages[index];

                if (_isVrcRequestOnlyMessage(chatItem) ||
                    zkpPolicy.shouldHide(chatItem)) {
                  return const SizedBox.shrink();
                }
                var nextItemFromSameDid = false;

                var nextIndex = index + 1;
                while (nextIndex < sortedMessages.length &&
                    (_isVrcRequestOnlyMessage(sortedMessages[nextIndex]) ||
                        zkpPolicy.shouldHide(sortedMessages[nextIndex]))) {
                  nextIndex++;
                }

                if (nextIndex < sortedMessages.length) {
                  final chatItemNext = sortedMessages[nextIndex];
                  nextItemFromSameDid =
                      chatItemNext.senderDid == chatItem.senderDid;
                }

                var thisItemStatus = '';

                if (chatItem.isFromMe && !_isRCardOnlyMessage(chatItem)) {
                  if (index == indexOfLastMessageFromMe) {
                    thisItemStatus = context.l10n.chatItemStatus(
                      chatItem.status.toString(),
                    );
                    lastUsedChatItemStatus = consolidateChatItemStatus(
                      chatItem,
                    );
                  } else {
                    final indexOfNextMessageFromMe = ref
                        .read(provider)
                        .getIndexOfNextMessageFromMe(index);
                    if (indexOfNextMessageFromMe != -1) {
                      final chatItemNextFromMe =
                          sortedMessages[indexOfNextMessageFromMe];
                      if (consolidateChatItemStatus(chatItem) !=
                          lastUsedChatItemStatus) {
                        thisItemStatus = context.l10n.chatItemStatus(
                          chatItemNextFromMe.status.toString(),
                        );
                        lastUsedChatItemStatus = consolidateChatItemStatus(
                          chatItemNextFromMe,
                        );
                      }
                      if (chatItem.status == chat.ChatItemStatus.error) {
                        thisItemStatus = context.l10n.chatItemStatusError;
                      }
                    }
                  }
                }

                return Padding(
                  key: ValueKey(chatItem.messageId),
                  padding: zkpPolicy.horizontalPadding(chatItem),
                  child: Column(
                    children: [
                      Align(
                        alignment:
                            (chatItem is EncryptionNotice ||
                                chatItem is chat.ConciergeMessage ||
                                chatItem.status ==
                                    chat.ChatItemStatus.userInput)
                            ? Alignment.center
                            : (chatItem.isFromMe)
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment:
                              (chatItem is EncryptionNotice ||
                                  chatItem is chat.ConciergeMessage)
                              ? CrossAxisAlignment.center
                              : chatItem.isFromMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!nextItemFromSameDid)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: _ChatItemFromInfo(
                                  chatItem: chatItem,
                                  contactId: _contactId,
                                ),
                              ),
                            _isCallOnlyMessage(chatItem)
                                ? _CallBubble(
                                    chatItem: chatItem,
                                    index: index,
                                    contactId: _contactId,
                                    selectedReactionIndex:
                                        selectedReactionIndex,
                                  )
                                : _isRCardOnlyMessage(chatItem)
                                ? _RCardBubble(
                                    chatItem: chatItem,
                                    index: index,
                                    contactId: _contactId,
                                    selectedReactionIndex:
                                        selectedReactionIndex,
                                    isGroupChat: isGroupChat,
                                  )
                                : _ZkpBubble(
                                    chatItem: chatItem,
                                    index: index,
                                    contactId: _contactId,
                                    selectedReactionIndex:
                                        selectedReactionIndex,
                                    policy: zkpPolicy,
                                  ),
                          ],
                        ),
                      ),
                      if (chatItem is chat.Message) ...[
                        chatItem.reactions.isNotEmpty
                            ? Align(
                                alignment: (chatItem.isFromMe)
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                child: Padding(
                                  padding: (chatItem.isFromMe)
                                      ? const EdgeInsets.fromLTRB(60, 0, 5, 8)
                                      : const EdgeInsets.fromLTRB(5, 0, 60, 8),
                                  child: _Reactions(
                                    contactId: _contactId,
                                    chatItem: chatItem,
                                  ),
                                ),
                              )
                            : const SizedBox(height: 1),
                        if (selectedReactionIndex == index)
                          _ReactionPickerChatItem(
                            chatItem: chatItem,
                            contactId: _contactId,
                          ),
                        thisItemStatus.isNotEmpty
                            ? Align(
                                alignment: (chatItem.isFromMe)
                                    ? Alignment.topRight
                                    : Alignment.topLeft,
                                child: Padding(
                                  padding: (chatItem.isFromMe)
                                      ? const EdgeInsets.fromLTRB(60, 0, 5, 8)
                                      : const EdgeInsets.fromLTRB(5, 0, 60, 8),
                                  child: Text(
                                    thisItemStatus,
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(height: 1),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Allows us to interpret a chat item's status however we want. This is
/// useful when we want to interpret 'sent' and 'sending' as the same
/// status as far as how we group the items on the ux.
chat.ChatItemStatus consolidateChatItemStatus(chat.ChatItem chatItem) {
  if (chatItem.status == chat.ChatItemStatus.sent ||
      chatItem.status == chat.ChatItemStatus.queued) {
    return chat.ChatItemStatus.sent;
  }
  return chatItem.status;
}

Color _callBubbleColor(BuildContext context, chat.ChatItem chatItem) {
  final colorScheme = context.colorScheme;
  if (chatItem.isFromMe) {
    if (chatItem.status == chat.ChatItemStatus.error) {
      return colorScheme.error;
    }
    return colorScheme.primary;
  }

  return context.customColors.callBubbleGrey;
}

Color _rCardBubbleColor(ColorScheme colorScheme, chat.ChatItem chatItem) {
  if (chatItem.isFromMe) {
    if (chatItem.status == chat.ChatItemStatus.error) {
      return Colors.red;
    }
    return colorScheme.primary;
  }

  return const Color.fromARGB(248, 107, 65, 162);
}

bool _isCallOnlyMessage(chat.ChatItem chatItem) {
  if (chatItem is! chat.Message) return false;
  final attachments = chatItem.attachments;
  return attachments.length == 1 && chat.CallMetadata.isCall(attachments.first);
}

bool _isRCardOnlyMessage(chat.ChatItem chatItem) {
  if (chatItem is! chat.Message) return false;
  final attachments = chatItem.attachments;
  return attachments.length == 1 &&
      (attachments.first.isRCard ||
          attachments.first.format == VrcAttachment.pluginFormat ||
          attachments.first.format == VrcRequestAttachment.pluginFormat);
}

/// VRC request messages are protocol signals — never displayed in the chat.
bool _isVrcRequestOnlyMessage(chat.ChatItem chatItem) {
  if (chatItem is! chat.Message) return false;
  final attachments = chatItem.attachments;
  return attachments.length == 1 &&
      attachments.first.format == VrcRequestAttachment.pluginFormat;
}

class _RCardBubble extends StatelessWidget {
  const _RCardBubble({
    required this.chatItem,
    required this.index,
    required this.contactId,
    required this.selectedReactionIndex,
    required this.isGroupChat,
  });

  final chat.ChatItem chatItem;
  final int index;
  final String contactId;
  final int? selectedReactionIndex;
  final bool isGroupChat;

  @override
  Widget build(BuildContext context) {
    final isCredentialOnly = _isRCardOnlyMessage(chatItem);

    if (isCredentialOnly && chatItem.isFromMe) {
      final msg = chatItem as chat.Message;
      if (msg.attachments.first.isRCardUpdate) {
        return ChatRCardUpdatedByMeNotice(
          dateCreated: chatItem.dateCreated,
          isGroupChat: isGroupChat,
        );
      }
    }

    if (isCredentialOnly && !chatItem.isFromMe) {
      final msg = chatItem as chat.Message;
      if (msg.attachments.first.isRCardAutoExchange) {
        return ChatRCardsExchangedNotice(chatItem: chatItem);
      }
    }

    final chatItemColor = _rCardBubbleColor(context.colorScheme, chatItem);

    final margin =
        chatItem is EncryptionNotice ||
            chatItem is chat.ConciergeMessage ||
            chatItem is chat.EventMessage
        ? const EdgeInsets.fromLTRB(20, 8, 20, 8)
        : EdgeInsets.fromLTRB(
            (chatItem.isFromMe) ? 60 : 0,
            8,
            (chatItem.isFromMe) ? 0 : 60,
            (selectedReactionIndex == index ||
                    chatItem is chat.Message &&
                        (chatItem as chat.Message).reactions.isNotEmpty)
                ? 0
                : 8,
          );

    final bubble = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isCredentialOnly && !chatItem.isFromMe
            ? context.customColors.callBubbleGrey
            : chatItemColor,
        borderRadius: BorderRadius.circular(isCredentialOnly ? 20.0 : 16.0),
      ),
      child: isCredentialOnly
          ? Padding(
              padding: const EdgeInsets.all(3),
              child: ChatItem(
                chatItem: chatItem,
                index: index,
                contactId: contactId,
                chatItemColor: chatItemColor,
              ),
            )
          : ChatItem(
              chatItem: chatItem,
              index: index,
              contactId: contactId,
              chatItemColor: chatItemColor,
            ),
    );

    if (!isCredentialOnly) return bubble;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bubbleWidth = constraints.maxWidth * 0.67 + 16;
        return SizedBox(width: bubbleWidth, child: bubble);
      },
    );
  }
}

class _CallBubble extends StatelessWidget {
  const _CallBubble({
    required this.chatItem,
    required this.index,
    required this.contactId,
    required this.selectedReactionIndex,
  });

  final chat.ChatItem chatItem;
  final int index;
  final String contactId;
  final int? selectedReactionIndex;

  @override
  Widget build(BuildContext context) {
    final chatItemColor = _callBubbleColor(context, chatItem);

    final margin = EdgeInsets.fromLTRB(
      chatItem.isFromMe ? 60 : 0,
      8,
      chatItem.isFromMe ? 0 : 60,
      (selectedReactionIndex == index ||
              chatItem is chat.Message &&
                  (chatItem as chat.Message).reactions.isNotEmpty)
          ? 0
          : 8,
    );

    final bubble = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: chatItemColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: ChatItem(
          chatItem: chatItem,
          index: index,
          contactId: contactId,
          chatItemColor: chatItemColor,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bubbleWidth = constraints.maxWidth * 0.67 + 16;
        return SizedBox(width: bubbleWidth, child: bubble);
      },
    );
  }
}

class _ZkpBubble extends StatelessWidget {
  const _ZkpBubble({
    required this.chatItem,
    required this.index,
    required this.contactId,
    required this.selectedReactionIndex,
    required this.policy,
  });

  final chat.ChatItem chatItem;
  final int index;
  final String contactId;
  final int? selectedReactionIndex;
  final ChatZkpMessageListPolicy policy;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = policy.bubbleColor(context.colorScheme, chatItem);
    return Container(
      margin: policy.bubbleMargin(
        item: chatItem,
        index: index,
        selectedReactionIndex: selectedReactionIndex ?? -1,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ChatItem(
        chatItem: chatItem,
        index: index,
        contactId: contactId,
        chatItemColor: bubbleColor,
      ),
    );
  }
}
