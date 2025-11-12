import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

class RenameMediatorDialog extends ConsumerStatefulWidget {
  const RenameMediatorDialog({
    super.key,
    required this.currentName,
  });

  final String currentName;

  static Future<String?> show(
    BuildContext context, {
    required String currentName,
  }) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => RenameMediatorDialog(currentName: currentName),
    );
  }

  @override
  ConsumerState<RenameMediatorDialog> createState() =>
      _RenameMediatorDialogState();
}

class _RenameMediatorDialogState extends ConsumerState<RenameMediatorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDone() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(name); // return the new name
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.setMediatorName),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        autocorrect: true,
        decoration: InputDecoration(
          labelText: context.l10n.mediatorName,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(
            context.l10n.generalCancel,
            style: TextStyle(color: context.colorScheme.onSurface),
          ),
        ),
        ElevatedButton(
          onPressed: _onDone,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(context.l10n.generalDone),
        ),
      ],
    );
  }
}
