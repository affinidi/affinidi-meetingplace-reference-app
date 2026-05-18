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

bool _isHumanZkpRequestConcierge(chat.ChatItem item) {
  return item is chat.ConciergeMessage &&
      item.conciergeType.value == ZkpConstants.conciergeHumanZkpRequest;
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
                (a) => a.format == ZkpConstants.livenessProofType,
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
                  att.format == ZkpConstants.livenessCheckRequestType ||
                  att.format == ZkpConstants.livenessProofType,
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

                if (_isVrcRequestOnlyMessage(chatItem) ||
                    shouldHideChatItem(chatItem)) {
                  return const SizedBox.shrink();
                }
                var nextItemFromSameDid = false;

                var nextIndex = index + 1;
                while (nextIndex < sortedMessages.length &&
                    (_isVrcRequestOnlyMessage(sortedMessages[nextIndex]) ||
                        shouldHideChatItem(sortedMessages[nextIndex]))) {
                  nextIndex++;
                }

                if (nextIndex < sortedMessages.length) {
                  var chatItemNext = sortedMessages[nextIndex];
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
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        _isHumanZkpConcierge(chatItem) &&
                            !_isHumanZkpRequestConcierge(chatItem)
                        ? 0
                        : 20,
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
                            _isRCardOnlyMessage(chatItem)
                                ? _RCardBubble(
                                    chatItem: chatItem,
                                    index: index,
                                    contactId: _contactId,
                                    selectedReactionIndex:
                                        selectedReactionIndex,
                                  )
                                : _ZkpBubble(
                                    chatItem: chatItem,
                                    index: index,
                                    contactId: _contactId,
                                    selectedReactionIndex:
                                        selectedReactionIndex,
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
        color: isCredentialOnly && !chatItem.isFromMe
            ? const Color(0xFF2E3035)
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

class _ZkpBubble extends StatelessWidget {
  const _ZkpBubble({
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
    final margin =
      _isHumanZkpConcierge(chatItem)
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
                        (chatItem as chat.Message).reactions.isNotEmpty)
                ? 0
                : 8,
          );

    final chatItemColor = getChatItemColor(context.colorScheme, chatItem);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: chatItemColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: ChatItem(
        chatItem: chatItem,
        index: index,
        contactId: contactId,
        chatItemColor: chatItemColor,
      ),
    );
  }
}
