part of 'offer_details_screen.dart';

class _OfferDetailsInfoPanel extends ConsumerWidget {
  const _OfferDetailsInfoPanel(this.offerLink);

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

    final mnemonic = ref.watch(
      controllerProvider.select((state) => state.offer?.mnemonic),
    );
    final type = ref.watch(
      controllerProvider.select((state) => state.offer?.type),
    );
    final externalRef = ref.watch(
      controllerProvider.select((state) => state.offer?.externalRef),
    );
    final groupDid = ref.watch(
      controllerProvider.select((state) => state.groupDid),
    );

    return FormCard(
      title: context.l10n.generalOfferInformation,
      child: Column(
        children: [
          FormRowIconTitle(
            icon: Icons.connect_without_contact,
            iconColor: context.customColors.violet,
            label: context.l10n.generalOfferLink,
            value: offerLink,
            isCopiable: true,
          ),
          const Divider(),
          FormRowIconTitle(
            icon: Icons.format_list_bulleted_rounded,
            iconColor: Colors.deepOrange,
            label: context.l10n.generalMnemonic,
            value: mnemonic ?? '',
            isCopiable: true,
          ),
          const Divider(),
          FormRowIconTitle(
            icon: Icons.merge_type,
            iconColor: Colors.indigo,
            label: context.l10n.generalConnectionType,
            value: type?.name ?? '',
            isCopiable: true,
          ),
          const Divider(),
          FormRowIconTitle(
            icon: Icons.extension_rounded,
            iconColor: context.customColors.cyan,
            label: context.l10n.generalExternalRef,
            value: externalRef ?? '',
            isCopiable: true,
          ),
          if (groupDid != null && groupDid.isNotEmpty) ...[
            const Divider(),
            FormRowIconTitle(
              icon: Icons.group,
              iconColor: context.customColors.rose,
              label: context.l10n.generalGroupDid,
              value: groupDid.topAndTail(),
              isCopiable: true,
            ),
          ],
        ],
      ),
    );
  }
}
