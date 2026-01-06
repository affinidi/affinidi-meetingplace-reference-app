part of 'offer_details_screen.dart';

class _OfferDetailsPersonalInfoPanel extends StatelessWidget {
  const _OfferDetailsPersonalInfoPanel(this.offerLink);

  final String offerLink;

  @override
  Widget build(BuildContext context) {
    return FormCard(
      title: context.l10n.personalInformationShared,
      child: _ContactCardPanelView(offerLink),
    );
  }
}

class _ContactCardPanelView extends ConsumerWidget {
  const _ContactCardPanelView(this.offerLink);

  final String offerLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerProvider = offerDetailsScreenControllerProvider(offerLink);
    final card = ref.watch(
      controllerProvider.select((state) => state.publisherIdentity?.card),
    );

    if (card == null) {
      return const SizedBox.shrink();
    }

    return ContactCardView(card: card);
  }
}
