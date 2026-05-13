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
              itemCount: sortedMessages.length,
              itemBuilder: (context, index) {
                var chatItem = sortedMessages[index];

                var nextItemFromSameDid = false;

                if (index < sortedMessages.length - 1) {
                  var chatItemNext = sortedMessages[index + 1];
                  nextItemFromSameDid =
                      chatItemNext.senderDid == chatItem.senderDid;
                }

                var thisItemStatus = '';

                if (chatItem.isFromMe && !_isRCardOnlyMessage(chatItem)) {
                  if (index == indexOfLastMessageFromMe) {
                    // this is the last one from me, show status regardless
                    thisItemStatus = context.l10n.chatItemStatus(
                      chatItem.status.toString(),
                    );
                    lastUsedChatItemStatus = consolidateChatItemStatus(
                      chatItem,
                    );
                  } else {
                    //
                    // if the previous item in the visual list
                    // (meaning, the NEXT)
                    // item in the list, (remember, it is displayed in reverse)
                    // has the same status as this item, we don't show the
                    // status on this item, we let it show on
                    // the next item - this
                    // will propagate all the way down
                    //
                    var indexOfNextMessageFromMe = ref
                        .read(provider)
                        .getIndexOfNextMessageFromMe(index);
                    if (indexOfNextMessageFromMe != -1) {
                      var chatItemNextFromMe =
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                            _RCardBubble(
                              chatItem: chatItem,
                              index: index,
                              contactId: _contactId,
                              selectedReactionIndex: selectedReactionIndex,
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
                                    index: index,
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

Color getChatItemColor(ColorScheme colorScheme, chat.ChatItem chatItem) {
  if (chatItem.isFromMe) {
    if (chatItem.status == chat.ChatItemStatus.error) {
      return Colors.red;
    }
    return colorScheme.primary;
  }

  if (chatItem.type == chat.ChatItemType.conciergeMessage) {
    return const Color.fromARGB(255, 53, 130, 6);
  } else if (chatItem.type == chat.ChatItemType.eventMessage) {
    return Colors.transparent;
  }

  return const Color.fromARGB(248, 107, 65, 162);
}

bool _isRCardOnlyMessage(chat.ChatItem chatItem) {
  if (chatItem is! chat.Message) return false;
  final attachments = chatItem.attachments;
  return attachments.length == 1 && attachments.first.isRCard;
}

class _RCardBubble extends StatelessWidget {
  const _RCardBubble({
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
    final isCredentialOnly = _isRCardOnlyMessage(chatItem);

    if (isCredentialOnly && chatItem.isFromMe) {
      final msg = chatItem as chat.Message;
      if (msg.attachments.first.isRCardUpdate) {
        return ChatRCardUpdatedByMeNotice(dateCreated: chatItem.dateCreated);
      }
    }

    if (isCredentialOnly && !chatItem.isFromMe) {
      final msg = chatItem as chat.Message;
      if (msg.attachments.first.isRCardAutoExchange) {
        return ChatRCardsExchangedNotice(chatItem: chatItem);
      }
    }

    final chatItemColor = getChatItemColor(context.colorScheme, chatItem);

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
        color: chatItemColor,
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
