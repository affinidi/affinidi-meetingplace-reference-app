part of 'connection_details_screen.dart';

class _CommunityTrustPanel extends ConsumerWidget {
  const _CommunityTrustPanel(this.contactId);

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(contactId);
    return VtcContactTrustPanel(
      channelDid: ref.watch(
        provider.select((state) => state.contact?.channelDid),
      ),
      contactName: ref.watch(provider.otherPartyDisplayName),
    );
  }
}
