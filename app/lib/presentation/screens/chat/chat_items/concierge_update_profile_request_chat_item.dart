part of '../chat_screen.dart';

class _ConciergeUpdateProfileRequestChatItem extends ConsumerWidget {
  _ConciergeUpdateProfileRequestChatItem({
    required chat.ConciergeMessage chatItem,
    required String contactId,
  })  : _chatItem = chatItem,
        _contactId = contactId;

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

    final sendLoadingController =
        controller.conciergeSendProfileLoadingController(_chatItem);
    final askMeLaterLoadingController =
        controller.conciergeAskLaterToSendProfileLoadingController(_chatItem);
    final cancelLoadingController =
        controller.conciergeCancelSendProfileLoadingController(_chatItem);

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
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  gradient: RadialGradient(
                    center: Alignment.bottomCenter,
                    radius: 2,
                    colors: [
                      Color.fromARGB(255, 76, 76, 76),
                      Color.fromARGB(255, 31, 31, 31),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      l10n.genWordConciergeMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isGroupChat
                          ? l10n.chatRequestPermissionToUpdateProfileGroup
                          : l10n.chatRequestPermissionToUpdateProfile,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              minimumSize: const Size(80, 25),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                side: BorderSide(color: Colors.white, width: 1),
                              ),
                            ),
                            onPressed: () async {
                              await updateContactDetails();
                            },
                            child: Text(
                              l10n.genWordYes,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10, right: 10),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(80, 25),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                side: BorderSide(color: Colors.white, width: 1),
                              ),
                            ),
                            onPressed: () async {
                              await askMeLater();
                            },
                            child: Text(
                              l10n.genWordLater,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(80, 25),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                side: BorderSide(color: Colors.white, width: 1),
                              ),
                            ),
                            onPressed: () async {
                              await cancelUpdatingContactDetails();
                            },
                            child: Text(
                              l10n.genWordNo,
                              style: const TextStyle(color: Colors.white),
                            ),
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
