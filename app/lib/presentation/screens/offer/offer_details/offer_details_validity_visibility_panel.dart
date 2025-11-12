part of 'offer_details_screen.dart';

class _OfferDetailsValidityVisibilityPanel extends ConsumerWidget {
  const _OfferDetailsValidityVisibilityPanel(this.offerLink);

  final String offerLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerProvider = offerDetailsScreenControllerProvider(offerLink);
    final expiryDate =
        ref.watch(controllerProvider.select((state) => state.offer?.expiresAt));
    final maxUsages = ref
        .watch(controllerProvider.select((state) => state.offer?.maximumUsage));

    final label = expiryDate == null
        ? context.l10n.noExpirySetHelperText
        : context.l10n.offerExpiresAt(
            DateFormat.yMMMMEEEEd(Localizations.localeOf(context).toString())
                .add_Hm()
                .format(expiryDate),
          );
    final helperText =
        expiryDate == null ? null : context.l10n.offerValidityNote;

    return FormCard(
      title: context.l10n.validityVisibilityDetails,
      child: Column(
        children: [
          FormRowIconText(
            icon: Icons.timer_outlined,
            iconColor: context.colorScheme.error,
            label: label,
            helperText: helperText,
            labelStyle: context.textTheme.bodyMedium,
          ),
          Divider(color: context.customColors.whiteOverlay30, height: 10),
          FormRowIconText(
            icon: Icons.replay_5_sharp,
            iconColor: context.customColors.rose,
            labelStyle: context.textTheme.bodyMedium,
            label: maxUsages == null
                ? context.l10n.offerUnlimitedUsages
                : context.l10n.offerMaxUsages(maxUsages),
          ),
        ],
      ),
    );
  }
}
