part of 'contacts_screen.dart';

class DeleteContactDialog extends StatelessWidget {
  const DeleteContactDialog({super.key, this.itemsCount = 1});

  static Future<bool> show(BuildContext context, {int itemsCount = 1}) async {
    return await showAdaptiveDialog<bool>(
          context: context,
          builder: (BuildContext context) =>
              DeleteContactDialog(itemsCount: itemsCount),
        ) ??
        false;
  }

  final int itemsCount;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(context.l10n.contactDeleteHeading),
      content: Text(context.l10n.contactDeletePrompt(itemsCount)),
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
