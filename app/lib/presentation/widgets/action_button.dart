import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isDefaultAction;
  final bool isDestructiveAction;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = context.colorScheme;

    var buttonStyle = TextButton.styleFrom();
    if (isDefaultAction) {
      buttonStyle = buttonStyle.copyWith(
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    if (isDestructiveAction) {
      buttonStyle = buttonStyle.copyWith(
        foregroundColor: WidgetStateProperty.all(colorScheme.error),
      );
    }

    if (onPressed == null) {
      buttonStyle = buttonStyle.copyWith(
        foregroundColor: WidgetStateProperty.all(theme.disabledColor),
      );
    }

    return TextButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Text(label),
    );
  }
}
