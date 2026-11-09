part of '../chat_screen.dart';

class _ConciergeUpdateProfileRequestChatItem extends ConsumerWidget {
  _ConciergeUpdateProfileRequestChatItem({
    required this._chatItem,
    required this._contactId,
  });

  final chat.ConciergeMessage _chatItem;
  final String _contactId;
  static const _logKey = 'CNCRPRFUPDT';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final l10n = context.l10n;
    final logger = ref.read(appLoggerProvider);

    final isGroupChat = ref.watch(provider.isGroupChat);

    final sendLoadingController = controller
        .conciergeSendProfileLoadingController(_chatItem);
    final askMeLaterLoadingController = controller
        .conciergeAskLaterToSendProfileLoadingController(_chatItem);
    final cancelLoadingController = controller
        .conciergeCancelSendProfileLoadingController(_chatItem);

    final chatItem = ref.watch(
      provider.select(
        (state) =>
            state.messages.whereType<chat.ConciergeMessage>().firstWhereOrNull(
              (cm) =>
                  cm.messageId == _chatItem.messageId &&
                  cm.status == chat.ChatItemStatus.userInput,
            ),
      ),
    );

    Future<void> updateContactDetails() async {
      if (!context.mounted) return;
      if (chatItem == null) return;

      logger.info(
        '''Pressed yes button to send updated profile for messageId: ${_chatItem.messageId}''',
        name: _logKey,
      );
      await controller.sendContactDetailsUpdate(chatItem);
    }

    Future<void> askMeLater() async {
      if (!context.mounted) return;
      if (chatItem == null) return;

      logger.info(
        '''Pressed ask me later button for messageId: ${_chatItem.messageId}''',
        name: _logKey,
      );
      await controller.askMeLaterToSendContactDetailsUpdate(chatItem);
    }

    Future<void> cancelUpdatingContactDetails() async {
      if (!context.mounted) return;
      if (chatItem == null) return;

      logger.info(
        '''Pressed cancel button for messageId: ${_chatItem.messageId}''',
        name: _logKey,
      );
      await controller.cancelUpdatingContactDetails(chatItem);
    }

    return Column(
      children: [
        ModalAsyncLoadingStatus(
          key: ValueKey('loading_send_profile_${_chatItem.messageId}'),
          sendLoadingController,
          loadingMessage: l10n.sending,
        ),
        ModalAsyncLoadingStatus(
          key: ValueKey('loading_ask_later_profile_${_chatItem.messageId}'),
          askMeLaterLoadingController,
        ),
        ModalAsyncLoadingStatus(
          key: ValueKey('loading_cancel_send_profile_${_chatItem.messageId}'),
          cancelLoadingController,
        ),
        (_chatItem.status == chat.ChatItemStatus.confirmed || chatItem == null)
            ? const SizedBox.shrink()
            : Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHigh,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(McRadius.md),
                  ),
                  border: Border.all(color: context.mcColors.hairline),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      l10n.genWordConciergeMessage,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.mcColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      isGroupChat
                          ? l10n.chatRequestPermissionToUpdateProfileGroup
                          : l10n.chatRequestPermissionToUpdateProfile,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.mcColors.textPrimary,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              minimumSize: const Size(80, 25),
                            ),
                            onPressed: () async {
                              await updateContactDetails();
                            },
                            child: Text(l10n.genWordYes),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(80, 25),
                            ),
                            onPressed: () async {
                              await askMeLater();
                            },
                            child: Text(l10n.genWordLater),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(80, 25),
                            ),
                            onPressed: () async {
                              await cancelUpdatingContactDetails();
                            },
                            child: Text(l10n.genWordNo),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}
