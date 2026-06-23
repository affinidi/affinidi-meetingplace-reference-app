part of 'connection_details_screen.dart';

class _RemoveMemberDialog extends ConsumerWidget {
  const _RemoveMemberDialog({required this.contactId, required this.member});

  static Future<void> show(
    BuildContext context, {
    required String contactId,
    required GroupMember member,
  }) async {
    final confirmed =
        await showAdaptiveDialog<bool>(
          context: context,
          builder: (_) =>
              _RemoveMemberDialog(contactId: contactId, member: member),
        ) ??
        false;
    if (!confirmed || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.removeMemberSuccess),
        duration: const Duration(seconds: 2),
        backgroundColor: context.customColors.success,
      ),
    );
  }

  final String contactId;
  final GroupMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog.adaptive(
      title: Text(context.l10n.removeMemberDialogTitle),
      content: Text(
        context.l10n.removeMemberDialogBody(member.contactCard.fullName),
      ),
      actions: [
        ActionButton(
          onPressed: () => Navigator.of(context).pop(false),
          label: context.l10n.generalCancel,
          isDefaultAction: true,
        ),
        ActionButton(
          onPressed: () async {
            Navigator.of(context).pop(true);
            await ref
                .read(
                  connectionDetailsScreenControllerProvider(contactId).notifier,
                )
                .removeMember(member.did);
          },
          isDestructiveAction: true,
          label: context.l10n.removeMemberConfirm,
        ),
      ],
    );
  }
}
