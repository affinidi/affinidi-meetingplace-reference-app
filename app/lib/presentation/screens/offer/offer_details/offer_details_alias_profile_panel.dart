part of 'offer_details_screen.dart';

class _OfferDetailsAliasProfilePanel extends ConsumerWidget {
  const _OfferDetailsAliasProfilePanel(this.offerLink);

  final String offerLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerProvider = offerDetailsScreenControllerProvider(offerLink);
    final alias = ref.watch(controllerProvider
        .select((state) => state.offer?.contactCard.firstName));
    final isUsingPrimaryIdentity = ref.watch(
        controllerProvider.select((state) => state.isUsingPrimaryIdentity));

    if (alias == null || alias.isEmpty) {
      return const SizedBox.shrink();
    }

    final label = isUsingPrimaryIdentity
        ? context.l10n.offerUsesPrimaryIdentity
        : context.l10n.offerUsesAliasIdentity(alias);

    return FormCard(
      title: context.l10n.myAliasProfile,
      child: FormRowIconText(
        icon: Icons.person,
        iconColor: context.colorScheme.secondary,
        label: label,
        labelStyle: context.textTheme.bodyMedium,
        helperText: context.l10n.aliasProfileDescription,
      ),
    );
  }
}
