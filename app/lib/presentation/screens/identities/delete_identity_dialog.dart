part of 'identities_screen.dart';

class DeleteIdentityDialog extends ConsumerWidget {
  const DeleteIdentityDialog({super.key, required this.displayName});

  final String displayName;

  static Future<bool> show({
    required BuildContext context,
    required String displayName,
  }) async {
    return await showAdaptiveDialog<bool>(
          context: context,
          builder: (BuildContext context) =>
              DeleteIdentityDialog(displayName: displayName),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog.adaptive(
      title: Text(context.l10n.identityDeleteHeading),
      content: Text(context.l10n.identityDeletePrompt(displayName)),
      actions: [
        ActionButton(
          onPressed: () {
            if (!context.mounted) return;
            Navigator.of(context).pop(false);
          },
          label: context.l10n.generalCancel,
          isDefaultAction: true,
        ),
        ActionButton(
          onPressed: () {
            if (!context.mounted) return;
            Navigator.of(context).pop(true);
          },
          isDestructiveAction: true,
          label: context.l10n.generalDelete,
        ),
      ],
    );
  }
}
