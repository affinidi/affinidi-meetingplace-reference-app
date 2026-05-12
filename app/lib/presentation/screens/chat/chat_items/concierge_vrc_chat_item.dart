part of '../chat_screen.dart';

class _ConciergeVrcChatItem extends ConsumerWidget {
  const _ConciergeVrcChatItem({
    required chat.ConciergeMessage chatItem,
    required String contactId,
  }) : _chatItem = chatItem,
       _contactId = contactId;

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
            _chatItem,
            identity: identity,
            role: VrcExchangeRole.responder,
          );
    }

    return Container(
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
            l10n.vrcVerifyPrompt(otherPartyFirstName),
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
                    backgroundColor: context.colorScheme.onSurface,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    minimumSize: const Size(80, 25),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  onPressed: onStartNow,
                  child: Text(
                    l10n.generateVrc,
                    style: TextStyle(
                      color: context.colorScheme.surface.withValues(alpha: 0.8),
                    ),
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
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      side: BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  onPressed: () async {
                    await ref
                        .read(chatScreenControllerProvider(_contactId).notifier)
                        .doLaterVrcExchangeFromConcierge(_chatItem);
                  },
                  child: Text(
                    l10n.vrcDoLaterButton,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
