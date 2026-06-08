part of '../chat_screen.dart';

class ConciergeJoinGroupRequestChatItem extends ConsumerWidget {
  ConciergeJoinGroupRequestChatItem({
    required this._chatItem,
    required this._contactId,
  }) : super(key: ValueKey('chat_concierge_join_${_chatItem.messageId}'));

  final chat.ConciergeMessage _chatItem;
  final String _contactId;
  static const _logKey = 'GRPCNCRGJN';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final l10n = context.l10n;
    final logger = ref.read(appLoggerProvider);

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

    final approveLoadingController = controller
        .conciergeApproveLoadingController(_chatItem);
    final rejectLoadingController = controller.conciergeRejectLoadingController(
      _chatItem,
    );

    final memberName = chatItem?.memeberName ?? '';

    Future<void> approveMembership() async {
      if (!context.mounted) return;

      logger.info(
        '''Pressed approve button for messageId: ${_chatItem.messageId}''',
        name: _logKey,
      );
      await controller.approveMembership(_chatItem);
    }

    Future<void> rejectOffer() async {
      if (!context.mounted) return;

      logger.info(
        '''Pressed reject button for messageId: ${_chatItem.messageId}''',
        name: _logKey,
      );
      await controller.rejectMembership(_chatItem);
    }

    return Column(
      children: [
        ModalAsyncLoadingStatus(
          key: ValueKey('loading_approve_${_chatItem.messageId}'),
          approveLoadingController,
          loadingMessage: l10n.approving,
          successMessage: l10n.connectionRequestInProgress,
          successMessageStyle: LoadingMessageStyle.progress,
        ),
        ModalAsyncLoadingStatus(
          key: ValueKey('loading_reject_${_chatItem.messageId}'),
          rejectLoadingController,
          loadingMessage: l10n.rejecting,
          successMessage: l10n.connectionRequestRejected,
        ),
        (_chatItem.status != chat.ChatItemStatus.userInput || chatItem == null)
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
                      context.l10n.genWordConciergeMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      memberName.isNotEmpty
                          ? context.l10n.chatRequestPermissionToJoinGroup(
                              memberName,
                            )
                          : '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
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
                              await approveMembership();
                            },
                            child: Text(
                              context.l10n.generalApprove,
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
                              await rejectOffer();
                            },
                            child: Text(
                              context.l10n.generalReject,
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
