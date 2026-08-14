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
    final latestSuggestion = ref.watch(
      provider.select((state) => state.latestSuggestion),
    );
    final supportsSuggestionRequests = ref.watch(
      provider.supportsSuggestionRequests,
    );
    final isSuggestionAgentReady = ref.watch(
      provider.select((state) => state.isPersonalAgentReady),
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
    final myDid = ref.watch(provider.select((state) => state.myDid));
    final isAgentContact = ref.watch(
      provider.select(
        (state) => state.contact?.category == ContactCategory.robot,
      ),
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
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
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
                  final visuallyFromMe = _isVisuallyFromMe(
                    chatItem,
                    myDid: myDid,
                    isAgentContact: isAgentContact,
                  );

                  if (_isVrcRequestOnlyMessage(chatItem) ||
                      zkpPolicy.shouldHide(chatItem) ||
                      _isLocalAgentResponseMessage(chatItem) ||
                      _SignDocumentRequestChatItem.matchStatusMessage(
                        chatItem,
                      )) {
                    return const SizedBox.shrink();
                  }
                  var nextItemFromSameDid = false;

                  var nextIndex = index + 1;
                  while (nextIndex < sortedMessages.length &&
                      (_isVrcRequestOnlyMessage(sortedMessages[nextIndex]) ||
                          zkpPolicy.shouldHide(sortedMessages[nextIndex]) ||
                          _isLocalAgentResponseMessage(
                            sortedMessages[nextIndex],
                          ))) {
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

                  final showSuggestionAction =
                      supportsSuggestionRequests &&
                      isSuggestionAgentReady &&
                      chatItem is chat.Message &&
                      !visuallyFromMe &&
                      selectedReactionIndex == index &&
                      chatItem.value.trim().isNotEmpty;
                  final showReactionPicker =
                      selectedReactionIndex == index &&
                      chatItem is chat.Message &&
                      !visuallyFromMe;
                  final matchingSuggestion =
                      chatItem is chat.Message &&
                          latestSuggestion?.relatedMessageId ==
                              chatItem.messageId
                      ? latestSuggestion
                      : null;
                  final showReactionPickerAbove =
                      showReactionPicker && showSuggestionAction;
                  final showReactionPickerBelow =
                      showReactionPicker && !showReactionPickerAbove;

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
                              : visuallyFromMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment:
                                (chatItem is EncryptionNotice ||
                                    chatItem is chat.ConciergeMessage)
                                ? CrossAxisAlignment.center
                                : visuallyFromMe
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
                              if (showReactionPickerAbove)
                                _ReactionPickerChatItem(
                                  chatItem: chatItem,
                                  contactId: _contactId,
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
                                      visuallyFromMe: visuallyFromMe,
                                    ),
                            ],
                          ),
                        ),
                        if (chatItem is chat.Message) ...[
                          chatItem.reactions.isNotEmpty
                              ? Align(
                                  alignment: visuallyFromMe
                                      ? Alignment.topRight
                                      : Alignment.topLeft,
                                  child: Padding(
                                    padding: visuallyFromMe
                                        ? const EdgeInsets.fromLTRB(60, 0, 5, 8)
                                        : const EdgeInsets.fromLTRB(
                                            5,
                                            0,
                                            60,
                                            8,
                                          ),
                                    child: _Reactions(
                                      contactId: _contactId,
                                      chatItem: chatItem,
                                    ),
                                  ),
                                )
                              : const SizedBox(height: 1),
                          if (showReactionPickerBelow)
                            _ReactionPickerChatItem(
                              chatItem: chatItem,
                              contactId: _contactId,
                            ),
                          if (showSuggestionAction)
                            _SuggestionActionChatItem(
                              messageId: chatItem.messageId,
                              contactId: _contactId,
                            ),
                          if (matchingSuggestion != null)
                            _SuggestionNoticeChatItem(
                              contactId: _contactId,
                              suggestion: matchingSuggestion,
                              isFromMe: visuallyFromMe,
                              onSendAsMe: () async {
                                await controller.sendLatestSuggestionAsMe();
                                if (!scrollController.hasClients) return;
                                if (scrollController.offset <= 24) return;

                                await scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                            ),
                          thisItemStatus.isNotEmpty
                              ? Align(
                                  alignment: visuallyFromMe
                                      ? Alignment.topRight
                                      : Alignment.topLeft,
                                  child: Padding(
                                    padding: visuallyFromMe
                                        ? const EdgeInsets.fromLTRB(60, 0, 5, 8)
                                        : const EdgeInsets.fromLTRB(
                                            5,
                                            0,
                                            60,
                                            8,
                                          ),
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

  if (chatItem is chat.Message &&
      chatItem.attachments.any((a) => a.format == 'cierge/trust-task')) {
    return const Color.fromARGB(248, 30, 60, 80);
  }

  return const Color.fromARGB(248, 107, 65, 162);
}

bool _isCallOnlyMessage(chat.ChatItem chatItem) {
  if (chatItem is! chat.Message) return false;
  final attachments = chatItem.attachments;
  return attachments.length == 1 && CallMetadata.isCall(attachments.first);
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

/// Local-only suppression for AI responses generated by this device's agent.
/// Remote peers still see the signed response message as normal.
bool _isLocalAgentResponseMessage(chat.ChatItem chatItem) {
  if (chatItem is! chat.Message || !chatItem.isFromMe) return false;
  return chatItem.attachments.any(
    (attachment) =>
        attachment.format == chat.CiergeSignatureProof.attachmentFormat,
  );
}

bool _isVisuallyFromMe(
  chat.ChatItem chatItem, {
  required String? myDid,
  required bool isAgentContact,
}) {
  if (chatItem.isFromMe) return true;
  if (isAgentContact) return false;
  if (myDid == null || myDid.isEmpty || chatItem is! chat.Message) {
    return false;
  }
  if (!chatItem.attachments.any((a) => a.isCiergeAgentMarker)) return false;
  return chatItem.attachments.any(
    (attachment) => attachment.ciergeOwnerDids.contains(myDid),
  );
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
    required this.visuallyFromMe,
  });

  final chat.ChatItem chatItem;
  final int index;
  final String contactId;
  final int? selectedReactionIndex;
  final ChatZkpMessageListPolicy policy;
  final bool visuallyFromMe;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = visuallyFromMe
        ? _outgoingBubbleColor(context.colorScheme, chatItem)
        : policy.bubbleColor(context.colorScheme, chatItem);
    return Container(
      margin: visuallyFromMe
          ? _outgoingBubbleMargin(
              chatItem,
              index: index,
              selectedReactionIndex: selectedReactionIndex ?? -1,
            )
          : policy.bubbleMargin(
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

EdgeInsets _outgoingBubbleMargin(
  chat.ChatItem chatItem, {
  required int selectedReactionIndex,
  required int index,
}) {
  if (chatItem is EncryptionNotice ||
      chatItem is chat.ConciergeMessage ||
      chatItem is chat.EventMessage) {
    return const EdgeInsets.fromLTRB(20, 8, 20, 8);
  }
  return EdgeInsets.fromLTRB(
    60,
    8,
    0,
    selectedReactionIndex == index ||
            (chatItem is chat.Message && chatItem.reactions.isNotEmpty)
        ? 0
        : 8,
  );
}

Color _outgoingBubbleColor(ColorScheme colorScheme, chat.ChatItem chatItem) {
  if (chatItem.status == chat.ChatItemStatus.error) return Colors.red;
  return colorScheme.primary;
}
