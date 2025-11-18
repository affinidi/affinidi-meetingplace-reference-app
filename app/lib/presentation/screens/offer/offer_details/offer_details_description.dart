part of 'offer_details_screen.dart';

class _OfferDetailsDescription extends ConsumerWidget {
  const _OfferDetailsDescription(this.offerLink);

  final String offerLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerProvider = offerDetailsScreenControllerProvider(offerLink);
    final offerDescription = ref.watch(
        controllerProvider.select((state) => state.offer?.offerDescription));

    if (offerDescription?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Text(
      offerDescription!,
      textAlign: TextAlign.center,
    );
  }
}
