part of 'offer_details_screen.dart';

class _OfferDetailsActionBar extends ConsumerWidget {
  const _OfferDetailsActionBar(this.offerLink);

  final String offerLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = offerDetailsScreenControllerProvider(offerLink);
    final controller = ref.read(provider.notifier);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 12,
        spacing: 12,
        children: [
          ModalAsyncLoadingStatus(controller.offerLoadingController),
          ModalAsyncLoadingStatus(
            controller.deleteOfferLoadingController,
            loadingMessage: l10n.deleting,
          ),
          ElevatedLoadingButton(
            color: context.colorScheme.error,
            child: Text(l10n.generalDelete),
            onPressed: () async {
              if (!context.mounted) return;

              final confirmed = await DeleteConnectionDialog.show(
                context: context,
                count: 1,
              );
              if (!confirmed) return;

              await controller.deleteConnection();
              if (!context.mounted) return;

              context.pop();
            },
          ),
          ElevatedLoadingButton(
            child: Text(l10n.generalOk),
            onPressed: () async {
              if (!context.mounted) return;

              await controller.refreshConnections();
              if (!context.mounted) return;

              context.pop();
            },
          ),
        ],
      ),
    );
  }
}
