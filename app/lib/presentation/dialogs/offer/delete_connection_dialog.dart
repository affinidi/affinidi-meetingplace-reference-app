import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/action_button.dart';

class DeleteConnectionDialog extends StatelessWidget {
  const DeleteConnectionDialog({super.key, required this.count});

  final int count;

  static Future<bool> show({
    required BuildContext context,
    required int count,
  }) async {
    return await showAdaptiveDialog<bool>(
          context: context,
          builder: (BuildContext context) =>
              DeleteConnectionDialog(count: count),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog.adaptive(
      title: Text(l10n.connectionDeleteHeading(count)),
      content: Text(l10n.connectionDeletePrompt(count)),
      actions: [
        ActionButton(
          onPressed: () {
            if (!context.mounted) return;
            Navigator.of(context).pop(false);
          },
          label: l10n.generalCancel,
          isDefaultAction: true,
        ),
        ActionButton(
          onPressed: () {
            if (!context.mounted) return;
            Navigator.of(context).pop(true);
          },
          isDestructiveAction: true,
          label: l10n.generalDelete,
        ),
      ],
    );
  }
}
