part of 'offer_details_screen.dart';

class _OfferDetailsHeader extends StatelessWidget {
  const _OfferDetailsHeader(this.offerLink);

  final String offerLink;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        const Column(
          children: [
            OfferBanner(),
            SizedBox(
              height: 110,
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          child: _ProfilePicture(offerLink),
        ),
      ],
    );
  }
}

class _ProfilePicture extends ConsumerWidget {
  _ProfilePicture(this.offerLink);

  final String offerLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerProvider = offerDetailsScreenControllerProvider(offerLink);
    final cacheManager = ref.read(cacheManagerProvider);
    final profileImage = ref.watch(
      controllerProvider.select(
        (state) => state.offer?.contactCard.image(cacheManager: cacheManager),
      ),
    );

    if (profileImage == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        ProfilePicture(image: profileImage, size: 145),
        Chip(
          label: Text(context.l10n.offerCreated),
          labelStyle: context.textTheme.bodyMedium,
          padding: const EdgeInsets.all(8),
        ),
      ],
    );
  }
}
