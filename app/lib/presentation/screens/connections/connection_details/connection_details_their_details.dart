part of 'connection_details_screen.dart';

class _TheirDetailsPanel extends ConsumerWidget {
  const _TheirDetailsPanel(this.contactId);

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(contactId);
    final otherPartyCard = ref.watch(provider.otherPartyCard);

    final contactName = otherPartyCard?.fullName;
    final email = otherPartyCard?.email;
    final mobile = otherPartyCard?.mobile;

    final theirDid = ref.watch(
      provider.select((state) => state.channel?.otherPartyPermanentChannelDid),
    );
    final theirDidSha256 = theirDid?.toDidSha256;

    final isDebugMode = ref.watch(
      provider.select((state) => state.isDebugMode),
    );
    final offerLink = ref.watch(
      provider.select((state) => state.connection?.offerLink ?? ''),
    );
    final groupId = ref.watch(
      provider.select((state) => state.group?.id ?? ''),
    );

    return FormCard(
      title: context.l10n.theirDetails,
      child: Column(
        spacing: 5,
        children: [
          if (contactName != null)
            FormRowIconTitle(
              icon: Icons.person,
              iconColor: context.colorScheme.primary,
              label: context.l10n.generalName,
              value: contactName,
            ),
          if (email != null && email.isNotEmpty) ...[
            const Divider(),
            FormRowIconTitle(
              icon: PersonaField.email.icon,
              iconColor: PersonaField.email.iconColor(
                context.customColors,
                context.colorScheme,
              ),
              label: PersonaField.email.label(context.l10n),
              value: email,
            ),
          ],
          if (mobile != null && mobile.isNotEmpty) ...[
            const Divider(),
            FormRowIconTitle(
              icon: PersonaField.mobile.icon,
              iconColor: PersonaField.mobile.iconColor(
                context.customColors,
                context.colorScheme,
              ),
              label: PersonaField.mobile.label(context.l10n),
              value: mobile,
            ),
          ],
          if (isDebugMode && theirDid != null && theirDid.isNotEmpty) ...[
            const Divider(),
            FormRowIconTitle(
              icon: Icons.fingerprint,
              iconColor: context.customColors.orange,
              label: context.l10n.generalDid,
              value: theirDid.topAndTail(),
              isCopiable: true,
            ),
          ],
          if (isDebugMode &&
              theirDidSha256 != null &&
              theirDidSha256.isNotEmpty) ...[
            const Divider(),
            FormRowIconTitle(
              icon: Icons.drag_indicator_sharp,
              iconColor: context.customColors.success,
              label: context.l10n.generalDidSha256,
              value: theirDidSha256.topAndTail(),
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
