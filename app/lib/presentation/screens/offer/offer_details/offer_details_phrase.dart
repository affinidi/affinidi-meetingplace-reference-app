part of 'offer_details_screen.dart';

class _OfferDetailsPhrase extends ConsumerWidget {
  const _OfferDetailsPhrase(this.offerLink);

  final String offerLink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerProvider = offerDetailsScreenControllerProvider(offerLink);
    final mnemonic =
        ref.watch(controllerProvider.select((state) => state.offer?.mnemonic));
    final showQrIcon =
        ref.watch(controllerProvider.select((state) => state.showQrIcon));

    if (mnemonic == null || mnemonic.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        MnemonicPill(
          mnemonic: mnemonic,
          isCopiable: true,
          suffix: showQrIcon
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(2, 2, 14, 4),
                  child: IconButton(
                    onPressed:
                        ref.read(controllerProvider.notifier).toggleShowQrView,
                    icon: CircleAvatar(
                      backgroundColor: context.customColors.darkGrey,
                      radius: 18,
                      child: Icon(
                        Icons.qr_code,
                        color: context.colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        _OfferQrCodeView(
          offerLink: offerLink,
          mnemonic: mnemonic,
        )
      ],
    );
  }
}
