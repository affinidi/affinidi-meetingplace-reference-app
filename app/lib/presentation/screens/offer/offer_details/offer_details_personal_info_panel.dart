part of 'offer_details_screen.dart';

class _OfferDetailsPersonalInfoPanel extends StatelessWidget {
  const _OfferDetailsPersonalInfoPanel(this.offerLink);

  final String offerLink;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: context.l10n.personalInformationShared,
      child: _VCardView(offerLink),
    );
  }
}

class _VCardView extends ConsumerWidget {
  const _VCardView(this.offerLink);

  final String offerLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerProvider = offerDetailsScreenControllerProvider(offerLink);
    final vCard = ref.watch(controllerProvider
        .select((state) => state.publisherIdentity?.card.toVCard()));

    if (vCard == null) {
      return const SizedBox.shrink();
    }

    return VCardView(vCard: vCard);
  }
}
