part of 'offer_details_screen.dart';

class _OfferDetailsDidInfoPanel extends ConsumerWidget {
  const _OfferDetailsDidInfoPanel(this.offerLink);

  final String offerLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerProvider = offerDetailsScreenControllerProvider(offerLink);
    final isDebugMode = ref.watch(
      controllerProvider.select((state) => state.isDebugMode),
    );
    if (!isDebugMode) {
      return const SizedBox.shrink();
    }

    final did = ref.watch(
      controllerProvider.select((state) => state.offer?.publishOfferDid),
    );
    if (did == null || did.isEmpty) {
      return const SizedBox.shrink();
    }
    final didSha256 = did.toDidSha256;

    return FormCard(
      title: context.l10n.didInformation,
      child: Column(
        children: [
          FormRowIconText(
            icon: Icons.open_in_new_off,
            iconColor: context.customColors.warning,
            label: did.topAndTail(),
            isCopiable: true,
          ),
          const Divider(),
          FormRowIconText(
            icon: Icons.drag_indicator_sharp,
            iconColor: context.customColors.success,
            label: context.l10n.didSha256(didSha256.topAndTail()),
            isCopiable: true,
          ),
        ],
      ),
    );
  }
}
