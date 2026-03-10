part of 'offer_details_screen.dart';

class _OfferDetailsName extends ConsumerWidget {
  const _OfferDetailsName(this.offerLink);

  final String offerLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerProvider = offerDetailsScreenControllerProvider(offerLink);
    final offerName = ref.watch(
      controllerProvider.select((state) => state.offer?.offerName),
    );

    if (offerName?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Text(
      offerName!,
      style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }
}
