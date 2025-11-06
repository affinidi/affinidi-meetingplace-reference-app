part of 'connection_details_screen.dart';

class _ConnectionDetailsPanel extends ConsumerWidget {
  _ConnectionDetailsPanel(this.contactId);

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = connectionDetailsScreenControllerProvider(contactId);

    final dateAdded =
        ref.watch(provider.select((state) => state.contact?.dateAdded));
    final mediatorName =
        ref.watch(provider.select((state) => state.mediatorName));
    final contactOrigin =
        ref.watch(provider.select((state) => state.contact?.origin));
    final isDebugMode =
        ref.watch(provider.select((state) => state.isDebugMode));

    final items = [
      if (dateAdded != null)
        FormRowIconTitle(
          icon: Icons.calendar_today,
          label: context.l10n.connectionEstablished,
          iconColor: context.colorScheme.primary,
          value: dateAdded.timeAgo(context.l10n),
        ),
      if (isDebugMode && mediatorName.isNotEmpty)
        FormRowIconTitle(
          icon: Icons.mediation,
          label: context.l10n.generalMediator,
          iconColor: context.customColors.purple,
          value: mediatorName,
        ),
      if (contactOrigin != null)
        FormRowIconTitle(
          icon: Icons.route,
          label: context.l10n.connectionApproach,
          iconColor: context.customColors.success,
          value: context.l10n.contactOrigin(contactOrigin.name),
        ),
    ];

    return FormCard(
      title: context.l10n.connectionDetails,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}
