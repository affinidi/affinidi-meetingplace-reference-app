import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

class IdentityPlaceholderCard extends StatelessWidget {
  const IdentityPlaceholderCard(this.onTap);

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(minHeight: 400, maxWidth: 650),
          width: double.infinity,
          height: 400,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(25.0),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fingerprint,
                color: colorScheme.onSurfaceVariant,
                size: 100,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.addNewIdentityAlias,
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  l10n.identityAliasesDescription,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
