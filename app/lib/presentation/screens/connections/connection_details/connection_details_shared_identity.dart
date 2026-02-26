part of 'connection_details_screen.dart';

class _SharedIdentityPanel extends ConsumerWidget {
  _SharedIdentityPanel(this.contactId);

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(contactId);
    final myDid = ref.watch(
      provider.select((state) => state.channel?.publishOfferDid.toDidSha256),
    );
    final myDidSha256 = myDid?.toDidSha256;
    final isDebugMode =
        ref.watch(provider.select((state) => state.isDebugMode));
    final identity = ref.watch(provider.select((state) => state.identity));
    final cacheManager = ref.read(cacheManagerProvider);

    return Column(
      children: [
        FormCard(
          title: context.l10n.mySharedIdentityDetails,
          child: Column(
            children: [
              if (isDebugMode && myDid != null && myDid.isNotEmpty) ...[
                const Divider(),
                FormRowIconTitle(
                  icon: Icons.fingerprint,
                  iconColor: context.customColors.orange,
                  label: context.l10n.generalDid,
                  value: myDid.topAndTail(),
                  isCopiable: true,
                ),
              ],
              if (isDebugMode &&
                  myDidSha256 != null &&
                  myDidSha256.isNotEmpty) ...[
                const Divider(),
                FormRowIconTitle(
                  icon: Icons.drag_indicator_sharp,
                  iconColor: context.customColors.success,
                  label: context.l10n.generalDidSha256,
                  value: myDidSha256.topAndTail(),
                  isCopiable: true,
                ),
                const Divider(),
              ],
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: identity != null
                    ? IdentityCard(
                        identity: identity,
                        identityCardSize: IdentityCardSize.small,
                        cacheManager: cacheManager,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
