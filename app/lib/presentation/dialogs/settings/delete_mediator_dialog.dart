import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

class DeleteMediatorDialog extends ConsumerWidget {
  const DeleteMediatorDialog({super.key, required this.name});

  final String name;

  static Future<bool?> show(BuildContext context, {required String name}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => DeleteMediatorDialog(name: name),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.deleteCustomMediator),
      content: Text(l10n.deleteCustomMediatorConfirm(name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.generalCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.error,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.generalDelete),
        ),
      ],
    );
  }
}
