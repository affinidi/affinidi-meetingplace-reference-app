import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

/// Shows [json] as indented JSON under [title], selectable to copy. Plain
/// text only: it is a document someone else may have written.
Future<void> showVtcJoinJson(
  BuildContext context, {
  required String title,
  required Map<String, dynamic> json,
  Key? textKey,
}) {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: SelectableText(
          const JsonEncoder.withIndent('  ').convert(json),
          key: textKey,
          style: context.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            height: 1.4,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.generalClose),
        ),
      ],
    ),
  );
}
