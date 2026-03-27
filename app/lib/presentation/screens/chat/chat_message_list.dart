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

    final agentSentMessageIds = ref.watch(
      provider.select((state) => state.agentSentMessageIds),
    );
    final ownerDid = ref.watch(
      identitiesServiceProvider.select((s) => s.currentIdentity?.did ?? ''),
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

                final isAgentMessage = chatItem is chat.Message &&
                    chatItem.isFromMe &&
                    agentSentMessageIds.contains(chatItem.messageId);

                return Padding(
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
                            Container(
                              margin:
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
                                                  chatItem.reactions.isNotEmpty)
                                          ? 0
                                          : 8,
                                    ),
                              decoration: isAgentMessage
                                  ? BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6A0DAD),
                                          Color(0xFF3B2FBE),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16.0),
                                    )
                                  : BoxDecoration(
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
                                chatItemColor: isAgentMessage
                                    ? const Color(0xFF6A0DAD)
                                    : getChatItemColor(
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
                        if (isAgentMessage && ownerDid.isNotEmpty)
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(60, 0, 5, 8),
                              child: _AgentFeedbackRow(
                                ownerDid: ownerDid,
                                messageId: chatItem.messageId,
                                contactId: _contactId,
                              ),
                            ),
                          ),
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

class _AgentFeedbackRow extends ConsumerStatefulWidget {
  const _AgentFeedbackRow({
    required this.ownerDid,
    required this.messageId,
    required this.contactId,
  });

  final String ownerDid;
  final String messageId;
  final String contactId;

  @override
  ConsumerState<_AgentFeedbackRow> createState() => _AgentFeedbackRowState();
}

class _AgentFeedbackRowState extends ConsumerState<_AgentFeedbackRow> {
  String? _submitted; // 'up' | 'down' | null

  Future<void> _submit(String rating) async {
    if (_submitted != null) return;
    setState(() => _submitted = rating);
    await ref.read(agentRepositoryProvider).submitFeedback(
      ownerDid: widget.ownerDid,
      messageId: widget.messageId,
      rating: rating,
    );
    ref.invalidate(agentReadinessProvider(widget.ownerDid));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _thumb(Icons.thumb_up_outlined, Icons.thumb_up, 'up'),
        const SizedBox(width: 4),
        _thumb(Icons.thumb_down_outlined, Icons.thumb_down, 'down'),
      ],
    );
  }

  Widget _thumb(IconData outline, IconData filled, String rating) {
    final isThis = _submitted == rating;
    final isOther = _submitted != null && _submitted != rating;
    return GestureDetector(
      onTap: isOther ? null : () => _submit(rating),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isOther ? 0.3 : 1.0,
        child: Icon(
          isThis ? filled : outline,
          size: 16,
          color: isThis
              ? (rating == 'up' ? Colors.greenAccent : Colors.redAccent)
              : Colors.white54,
        ),
      ),
    );
  }
}
