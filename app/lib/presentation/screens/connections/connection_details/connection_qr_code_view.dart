part of 'connection_details_screen.dart';

class _ConnectionQrCodeView extends ConsumerWidget {
  const _ConnectionQrCodeView({
    required this.contactId,
    required this.mnemonic,
  });

  final String contactId;
  final String mnemonic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(contactId);
    final showQrView = ref.watch(provider.select((state) => state.showQrView));

    if (!showQrView) return const SizedBox.shrink();

    return QrCodeView(
      data: mnemonic,
      size: context.qrScannerTheme.iconSize * 2.5,
    );
  }
}
