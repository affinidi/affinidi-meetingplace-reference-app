part of 'chat_screen.dart';

bool _isHumanZkpConcierge(chat.ChatItem item) {
  if (item is! chat.ConciergeMessage) return false;
  const ids = {
    ZkpConstants.conciergeHumanZkpRequest,
    ZkpConstants.conciergeHumanZkpPaused,
    ZkpConstants.conciergeHumanZkpProofShared,
    ZkpConstants.conciergeHumanZkpProofReceived,
  };
  return ids.contains(item.conciergeType.value);
}

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
    final pausedNoticeMessageIds = sortedMessages
        .where(
          (n) =>
              n is chat.ConciergeMessage &&
              n.conciergeType.value == ZkpConstants.conciergeHumanZkpPaused,
        )
        .map((n) => (n as chat.ConciergeMessage).messageId)
        .toSet();

    final hasSharedHumanZkpProof = sortedMessages.any(
      (m) =>
          (m is chat.ConciergeMessage &&
              m.conciergeType.value ==
                  ZkpConstants.conciergeHumanZkpProofShared) ||
          (m is chat.Message &&
              m.isFromMe &&
              m.attachments.any(
                LivenessZkpAttachmentParser.matchesProofFormat,
              )),
    );

    bool shouldHideChatItem(chat.ChatItem item) {
      // Hide messages that are just liveness/proof attachments with no text.
      if (item is chat.Message && item.value.isEmpty) {
        final attachments = item.attachments;
        final hasOnlyLivenessAttachments =
            attachments.isNotEmpty &&
            attachments.every(
              (att) =>
                  LivenessZkpAttachmentParser.matchesRequestFormat(att) ||
                  LivenessZkpAttachmentParser.matchesProofFormat(att),
            );
        if (hasOnlyLivenessAttachments) {
          return true;
        }
      }

      // Hide the proof-request concierge once user shared a proof, or after
      // "Do later" (paired paused notice).
      if (item is chat.ConciergeMessage &&
          item.conciergeType.value == ZkpConstants.conciergeHumanZkpRequest) {
        if (hasSharedHumanZkpProof) {
          return true;
        }
        final expectedPausedNoticeMessageId = 'zkp-paused-${item.messageId}';
        return pausedNoticeMessageIds.contains(expectedPausedNoticeMessageId);
      }

      return false;
    }

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

                if (shouldHideChatItem(chatItem)) {
                  return const SizedBox.shrink();
                }

                var nextItemFromSameDid = false;

                // When hidden items exist, skip over them so sender grouping
                // (from-info / status alignment) stays visually correct.
                var nextIndex = index + 1;
                while (nextIndex < sortedMessages.length &&
                    shouldHideChatItem(sortedMessages[nextIndex])) {
                  nextIndex++;
                }

                if (nextIndex < sortedMessages.length) {
                  var chatItemNext = sortedMessages[nextIndex];
                  nextItemFromSameDid =
                      chatItemNext.senderDid == chatItem.senderDid;
                }

                var thisItemStatus = '';

                if (chatItem.isFromMe) {
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
                  padding: EdgeInsets.symmetric(
                    horizontal: _isHumanZkpConcierge(chatItem) ? 0 : 20,
                  ),
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
                            Container(
                              margin: _isHumanZkpConcierge(chatItem)
                                  ? const EdgeInsets.symmetric(vertical: 8)
                                  : chatItem is EncryptionNotice ||
                                        chatItem is chat.ConciergeMessage ||
                                        chatItem is chat.EventMessage
                                  ? const EdgeInsets.fromLTRB(20, 8, 20, 8)
                                  : EdgeInsets.fromLTRB(
                                      (chatItem.isFromMe) ? 60 : 0,
                                      8,
                                      (chatItem.isFromMe) ? 0 : 60,
                                      (selectedReactionIndex == index ||
                                              chatItem is chat.Message &&
                                                  chatItem.reactions.isNotEmpty)
                                          ? 0
                                          : 8,
                                    ),
                              decoration: BoxDecoration(
                                color: getChatItemColor(
                                  context.colorScheme,
                                  chatItem,
                                ),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: ChatItem(
                                chatItem: chatItem,
                                index: index,
                                contactId: _contactId,
                                chatItemColor: getChatItemColor(
                                  context.colorScheme,
                                  chatItem,
                                ),
                              ),
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
  if (chatItem.type == chat.ChatItemType.conciergeMessage) {
    final cm = chatItem as chat.ConciergeMessage;
    final typeValue = cm.conciergeType.value;
    if (typeValue == ZkpConstants.conciergeHumanZkpRequest ||
        typeValue == ZkpConstants.conciergeHumanZkpPaused ||
        typeValue == ZkpConstants.conciergeHumanZkpProofShared ||
        typeValue == ZkpConstants.conciergeHumanZkpProofReceived) {
      return Colors.transparent;
    }
    return AppCustomColors.conciergeMessageColor;
  } else if (chatItem.type == chat.ChatItemType.eventMessage) {
    return Colors.transparent;
  }

  if (chatItem.isFromMe) {
    if (chatItem.status == chat.ChatItemStatus.error) {
      return Colors.red;
    }
    return colorScheme.primary;
  }

  return const Color.fromARGB(248, 107, 65, 162);
}
