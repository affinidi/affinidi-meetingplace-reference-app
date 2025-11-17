part of 'connection_details_screen.dart';

class _GroupDetailsPanel extends ConsumerWidget {
  const _GroupDetailsPanel(this.contactId);

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(contactId);
    final groupAdminVCard = ref.read(provider.groupAdminVCard);
    final groupName = ref.watch(provider.groupName);

    final contactName = groupAdminVCard?.fullName;
    final email = groupAdminVCard?.email;
    final mobile = groupAdminVCard?.mobile;

    final adminDid = ref.watch(provider
        .select((state) => state.channel?.otherPartyPermanentChannelDid));
    final adminDidSha256 = adminDid?.toDidSha256;

    final isDebugMode =
        ref.watch(provider.select((state) => state.isDebugMode));
    final offerLink = ref
        .watch(provider.select((state) => state.connection?.offerLink ?? ''));
    final groupId =
        ref.watch(provider.select((state) => state.group?.id ?? ''));

    return FormCard(
      title: context.l10n.groupDetails,
      child: Column(
        spacing: 5,
        children: [
          if (groupName != null)
            FormRowIconTitle(
              icon: Icons.person,
              iconColor: context.colorScheme.primary,
              label: context.l10n.generalName,
              value: groupName,
            ),
          if (email != null && email.isNotEmpty) ...[
            const Divider(),
            FormRowIconTitle(
              icon: Icons.email,
              iconColor: context.customColors.purple,
              label: context.l10n.generalEmail,
              value: email,
            ),
          ],
          if (mobile != null && mobile.isNotEmpty) ...[
            const Divider(),
            FormRowIconTitle(
              icon: Icons.cell_tower,
              iconColor: context.customColors.brown,
              label: context.l10n.generalMobile,
              value: mobile,
            ),
          ],
          if (isDebugMode && adminDid != null && adminDid.isNotEmpty) ...[
            const Divider(),
            FormRowIconTitle(
              icon: Icons.fingerprint,
              iconColor: context.customColors.orange,
              label: context.l10n.generalDid,
              value: adminDid.topAndTail(),
              isCopiable: true,
            ),
          ],
          if (isDebugMode &&
              adminDidSha256 != null &&
              adminDidSha256.isNotEmpty) ...[
            const Divider(),
            FormRowIconTitle(
              icon: Icons.drag_indicator_sharp,
              iconColor: context.customColors.success,
              label: context.l10n.generalDidSha256,
              value: adminDidSha256.topAndTail(),
              isCopiable: true,
            ),
          ],
          if (isDebugMode && offerLink.isNotEmpty) ...[
            const Divider(),
            FormRowIconTitle(
              icon: Icons.link,
              iconColor: context.colorScheme.secondary,
              label: context.l10n.generalOfferLink,
              value: offerLink,
              isCopiable: true,
            ),
          ],
          if (isDebugMode && groupId.isNotEmpty) ...[
            const Divider(),
            FormRowIconTitle(
              icon: Icons.group,
              iconColor: context.customColors.purple,
              label: context.l10n.generalGroupId,
              value: groupId.topAndTail(),
              isCopiable: true,
            ),
          ],
        ],
      ),
    );
  }
}
