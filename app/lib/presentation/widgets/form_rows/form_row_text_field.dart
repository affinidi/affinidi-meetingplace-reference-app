import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import 'label_icon.dart';

class FormRowTextField extends StatelessWidget {
  const FormRowTextField({
    super.key,
    required this.color,
    required this.label,
    required this.controller,
    this.icon,
    this.placeholder,
    this.hint,
    this.onChanged,
    this.suffixIcon,
    this.singleLine = false,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.keyboardType,
    this.validator,
    this.autocorrect = false,
    this.textFieldKey,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.traversalOrder,
    this.autofocus = false,
  });

  final Color color;
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String? placeholder;
  final String? hint;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final bool singleLine;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool autocorrect;
  final Key? textFieldKey;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final double? traversalOrder;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        ListTile(
          leading: (icon != null)
              ? LabelIcon(icon: icon, iconColor: color, label: label)
              : null,
          title: Row(
            children: [
              Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: textFieldKey,
                  autofocus: autofocus,
                  readOnly: !enabled,
                  keyboardType: keyboardType ?? TextInputType.multiline,
                  controller: controller,
                  maxLines: singleLine ? 1 : 3,
                  minLines: 1,
                  expands: false,
                  textCapitalization: textCapitalization,
                  autocorrect: autocorrect,
                  validator: validator,
                  onChanged: onChanged,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  decoration: InputDecoration(hintText: placeholder),
                  focusNode: focusNode,
                  textInputAction: textInputAction,
                  onFieldSubmitted: onFieldSubmitted,
                ),
              ),
              if (suffixIcon != null) ...[
                const SizedBox(width: 8),
                suffixIcon!,
              ],
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        if (hint != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 4.0),
            child: Text(
              hint!,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );

    if (traversalOrder != null) {
      return FocusTraversalOrder(
        order: NumericFocusOrder(traversalOrder!),
        child: content,
      );
    }

    return content;
  }
}
