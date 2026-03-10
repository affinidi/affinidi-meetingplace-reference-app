part of 'publish_offer_screen.dart';

class _OfferAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _OfferAppBar(String identityId) : _identityId = identityId;

  final String _identityId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = publishOfferScreenControllerProvider(
      _identityId,
      context.l10n,
    );

    final isGroupOffer = ref.watch(
      provider.select((state) => state.formData.isGroupOffer),
    );

    final title = isGroupOffer
        ? context.l10n.publishGroupOffer
        : context.l10n.publishOffer;

    return AppBar(title: Text(title));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
