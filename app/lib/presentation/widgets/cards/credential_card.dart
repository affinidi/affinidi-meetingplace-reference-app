import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_radius.dart';

class CredentialCard extends StatelessWidget {
  const CredentialCard({
    super.key,
    required this.topLeftText,
    required this.bottomLeftText,
    this.onTap,
  });

  final String topLeftText;
  final String bottomLeftText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final textTheme = context.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 208,
        child: Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerLow,
            border: Border.all(color: mc.hairline),
            borderRadius: BorderRadius.circular(McRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  topLeftText,
                  style: textTheme.titleLarge?.copyWith(
                    color: mc.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  bottomLeftText,
                  style: textTheme.headlineSmall?.copyWith(
                    color: mc.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
