part of 'connection_details_screen.dart';

class _TheirDetailsPanel extends ConsumerWidget {
  const _TheirDetailsPanel(this.contactId);

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(contactId);
    final otherPartyCard = ref.watch(provider.otherPartyCard);

    final contactName = otherPartyCard?.fullName;

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

    final fields = ContactCardFieldDefinitions.values
        .where(
          (field) =>
              field.key != ContactCardFieldKey.firstName &&
              field.key != ContactCardFieldKey.lastName,
        )
        .toList(growable: false);

    final items = <Widget>[];

    if (contactName != null && contactName.isNotEmpty) {
      items.add(
        FormRowIconTitle(
          icon: Icons.person,
          iconColor: context.colorScheme.primary,
          label: context.l10n.generalName,
          value: contactName,
        ),
      );
    }

    for (final field in fields) {
      final value = (otherPartyCard?.valueForField(field.key) ?? '').trim();
      if (value.isEmpty) continue;

      items.add(
        FormRowIconTitle(
          icon: field.icon,
          iconColor: field.iconColor(context.customColors, context.colorScheme),
          label: field.label(context.l10n),
          value: value,
        ),
      );
    }

    if (isDebugMode && theirDid != null && theirDid.isNotEmpty) {
      items.add(
        FormRowIconTitle(
          icon: Icons.fingerprint,
          iconColor: context.customColors.orange,
          label: context.l10n.generalDid,
          value: theirDid.topAndTail(),
          isCopiable: true,
        ),
      );
    }

    if (isDebugMode && theirDidSha256 != null && theirDidSha256.isNotEmpty) {
      items.add(
        FormRowIconTitle(
          icon: Icons.drag_indicator_sharp,
          iconColor: context.customColors.success,
          label: context.l10n.generalDidSha256,
          value: theirDidSha256.topAndTail(),
          isCopiable: true,
        ),
      );
    }

    if (isDebugMode && offerLink.isNotEmpty) {
      items.add(
        FormRowIconTitle(
          icon: Icons.link,
          iconColor: context.colorScheme.secondary,
          label: context.l10n.generalOfferLink,
          value: offerLink,
          isCopiable: true,
        ),
      );
    }

    if (isDebugMode && groupId.isNotEmpty) {
      items.add(
        FormRowIconTitle(
          icon: Icons.group,
          iconColor: context.customColors.purple,
          label: context.l10n.generalGroupId,
          value: groupId.topAndTail(),
          isCopiable: true,
        ),
      );
    }

    return FormCard(
      title: context.l10n.theirDetails,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) => items[index],
      ),
    );
  }
}
