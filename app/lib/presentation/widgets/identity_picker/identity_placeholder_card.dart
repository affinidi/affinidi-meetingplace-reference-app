import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';
import '../common/app_card.dart';

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
          child: AppCard(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(McRadius.xl),
              side: BorderSide(color: context.mcColors.hairline),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  McIcons.identities,
                  color: colorScheme.onSurfaceVariant,
                  size: 100,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.addNewIdentityAlias,
                  style: textTheme.titleLarge?.copyWith(
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
      ),
    );
  }
}
