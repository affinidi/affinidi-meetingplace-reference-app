part of '../chat_screen.dart';

class _ConciergeVrcChatItem extends ConsumerWidget {
  const _ConciergeVrcChatItem({
    required this._chatItem,
    required this._contactId,
  });

  final chat.ConciergeMessage _chatItem;
  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hide once the user has acted (approved or dismissed permanently).
    if (_chatItem.status != chat.ChatItemStatus.userInput) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    final provider = chatScreenControllerProvider(_contactId);

    // Guard: only show in 1:1 non-AI chats.
    final isGroupChat = ref.watch(provider.isGroupChat);
    if (isGroupChat) return const SizedBox.shrink();

    final otherPartyFirstName = ref.watch(provider.otherPartyName) ?? '';

    Future<void> onStartNow() async {
      final otherPartyCard = ref.read(provider.select((s) => s.otherPartyCard));
      final identity = await Navigator.of(context, rootNavigator: true)
          .push<Identity>(
            MaterialPageRoute(
              builder: (_) => SelectVrcIdentityScreen(
                name: otherPartyFirstName,
                otherPartyCard: otherPartyCard,
                role: VrcExchangeRole.responder,
              ),
            ),
          );
      if (identity == null || !context.mounted) return;
      await ref
          .read(chatScreenControllerProvider(_contactId).notifier)
          .selectIdentityAndApproveVrcExchange(
            identity: identity,
            role: VrcExchangeRole.responder,
          );
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.all(Radius.circular(McRadius.md)),
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
            l10n.vrcVerifyPrompt(otherPartyFirstName),
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
                  onPressed: onStartNow,
                  child: Text(l10n.generateVrc),
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
                    await ref
                        .read(chatScreenControllerProvider(_contactId).notifier)
                        .doLaterVrcExchangeFromConcierge();
                  },
                  child: Text(l10n.vrcDoLaterButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
