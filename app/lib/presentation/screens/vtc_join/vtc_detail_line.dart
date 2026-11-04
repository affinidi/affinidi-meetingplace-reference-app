import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/onboarding_style/onboarding_style.dart';

/// One fact on the gradient, such as the key that signed: an [icon] for
/// what it is, then its [label] above its [value]. An identifier
/// ([isId]: a DID, a DID URL, an id) is shown in monospace.
class VtcDetailLine extends StatelessWidget {
  const VtcDetailLine({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isId = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isId;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(label, style: onboardingNote(context)),
              if (isId)
                MonospaceDid(value)
              else
                SelectableText(
                  value,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
