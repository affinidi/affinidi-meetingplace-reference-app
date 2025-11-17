part of 'connection_details_screen.dart';

class _ConnectionMnenomicPanel extends ConsumerWidget {
  _ConnectionMnenomicPanel(String contactId) : _contactId = contactId;

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final canRevealMnemonic = ref.watch(provider.canRevealMnemonic);
    final showMnemonic =
        ref.watch(provider.select((state) => state.showMnemonic));
    final mnemonic =
        ref.watch(provider.select((state) => state.connection?.mnemonic ?? ''));
    final showQrIcon = ref.watch(provider.select((state) => state.showQrIcon));

    if (!canRevealMnemonic) return const SizedBox.shrink();

    return FormCard(
      title: context.l10n.revealConnectionCode,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch.adaptive(
            value: showMnemonic,
            onChanged: controller.showMnemonic,
          ),
        ],
      ),
      child: Column(
        children: [
          if (showMnemonic) ...[
            MnemonicPill(
              mnemonic: mnemonic,
              isCopiable: true,
              suffix: showQrIcon
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(2, 2, 14, 4),
                      child: IconButton(
                        onPressed: controller.toggleShowQrView,
                        icon: CircleAvatar(
                          backgroundColor: Colors.white,
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
            _ConnectionQrCodeView(
              contactId: _contactId,
              mnemonic: mnemonic,
            ),
          ],
        ],
      ),
    );
  }
}
