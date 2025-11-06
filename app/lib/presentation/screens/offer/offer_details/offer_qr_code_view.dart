part of 'offer_details_screen.dart';

class _OfferQrCodeView extends ConsumerWidget {
  const _OfferQrCodeView({
    required this.offerLink,
    required this.mnemonic,
  });

  final String offerLink;
  final String mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllerProvider = offerDetailsScreenControllerProvider(offerLink);
    final showQrView =
        ref.watch(controllerProvider.select((state) => state.showQrView));

    if (!showQrView) return const SizedBox.shrink();

    return QrCodeView(
      data: mnemonic,
      size: context.qrScannerTheme.iconSize * 2.5,
    );
  }
}
