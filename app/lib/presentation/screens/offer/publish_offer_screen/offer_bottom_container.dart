part of 'publish_offer_screen.dart';

class _OfferBottomContainer extends ConsumerWidget {
  const _OfferBottomContainer(String identityId) : _identityId = identityId;

  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = publishOfferScreenControllerProvider(
      _identityId,
      context.l10n,
    );
    final controller = ref.read(provider.notifier);
    final canPublish = ref.watch(provider.canPublish);

    Future<AgentContext?> selectAgentContext() {
      return showDialog<AgentContext>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Select agent context'),
          content: const Text(
            'Choose which Personal AI context this offer should use.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(AgentContext.work),
              child: Text(context.l10n.agentContextWorkAiLabel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(AgentContext.personal),
              child: Text(context.l10n.agentContextPersonalAiLabel),
            ),
          ],
        ),
      );
    }

    Future<void> publishOffer() async {
      final formData = ref.read(provider).formData;
      AgentContext? agentContext;
      if (ref.read(environmentProvider).personalAiEnabled) {
        agentContext = await selectAgentContext();
        if (agentContext == null) return;
      }
      await controller.publishOffer(
        formData: formData,
        agentContext: agentContext,
      );
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModalAsyncLoadingStatus(
              controller.publishOfferLoadingController,
              loadingMessage: context.l10n.publishing,
            ),
            ElevatedLoadingButton(
              onPressed: canPublish ? publishOffer : null,
              child: Text(
                context.l10n.publishToMeetingPlace,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
