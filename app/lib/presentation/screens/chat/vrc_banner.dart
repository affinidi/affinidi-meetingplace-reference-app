part of 'chat_screen.dart';

class _VrcBanner extends ConsumerWidget {
  _VrcBanner(String contactId) : _contactId = contactId;

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final shouldShowVrcBanner = ref.watch(
      provider.select((state) => state.shouldShowVrcBanner),
    );
    final hasVrcRequestReceived = ref.watch(
      provider.select((state) => state.hasVrcRequestReceived),
    );
    final role = hasVrcRequestReceived
        ? VrcExchangeRole.responder
        : VrcExchangeRole.initiator;
    final otherPartyFirstName = ref.watch(provider.otherPartyName);
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final mc = context.mcColors;
    final textScheme = context.textTheme;

    if (!shouldShowVrcBanner || (otherPartyFirstName?.isEmpty ?? true)) {
      return const SizedBox.shrink();
    }

    Future<void> doLater() async {
      if (!context.mounted) return;
      await controller.doLaterVrcExchangeFromBanner();
    }

    Future<void> startVrcExchange() async {
      final otherPartyCard = role == VrcExchangeRole.responder
          ? ref.read(provider.select((s) => s.otherPartyCard))
          : null;
      final identity = await Navigator.of(context, rootNavigator: true)
          .push<Identity>(
            MaterialPageRoute(
              builder: (_) => SelectVrcIdentityScreen(
                name: otherPartyFirstName,
                role: role,
                otherPartyCard: otherPartyCard,
              ),
            ),
          );
      if (identity == null || !context.mounted) return;
      await ref
          .read(provider.notifier)
          .selectIdentityAndApproveVrcExchange(identity: identity, role: role);
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: mc.hairline)),
      ),
      child: Column(
        spacing: 8,
        children: [
          Text(
            l10n.verifyRelationshipPrompt(otherPartyFirstName!),
            style: textScheme.bodyMedium!.copyWith(
              color: mc.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ElevatedButton(
                  onPressed: startVrcExchange,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    minimumSize: const Size(80, 25),
                  ),
                  child: Text(l10n.generateVrc),
                ),
              ),
              OutlinedButton(
                onPressed: doLater,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(80, 25),
                ),
                child: Text(l10n.doLater),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
