import 'package:flutter/material.dart';

import '../../../domain/models/contact_card/contact_card.dart';
import '../../../domain/models/contact_card/contact_card_field_definition.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/contact_card_extensions.dart';

/// What an identity card shows of [card]: the full name, then each field an
/// identity card carries by its icon, muted as not shared when empty. Set
/// smaller on a [small] card.
class IdentityContactRows extends StatelessWidget {
  const IdentityContactRows({
    super.key,
    required this.card,
    this.small = false,
  });

  final ContactCard card;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    final fields = ContactCardFieldDefinitions.values
        .where((field) => field.hasTag(ContactCardFieldTags.identityCard))
        .toList(growable: false);

    final name = card.fullName.isNotEmpty ? card.fullName : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.isNotEmpty)
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: small ? textTheme.bodyMedium : textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
              if (small) const Spacer(),
            ],
          ),
        SizedBox(height: small ? 12 : 16),
        for (final field in fields) ...[
          _ContactInfoRow(
            icon: field.icon,
            value: field.valueFrom(card).trim(),
            notShared: l10n.notShared,
            small: small,
          ),
          SizedBox(height: small ? 6 : 8),
        ],
      ],
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  const _ContactInfoRow({
    required this.icon,
    required this.value,
    required this.notShared,
    required this.small,
  });

  final IconData icon;

  /// The field's value; empty when the identity does not share it.
  final String value;
  final String notShared;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final textTheme = context.textTheme;
    final isShared = value.isNotEmpty;

    return Row(
      spacing: 8,
      children: [
        Icon(icon, color: mc.textSecondary, size: 16),
        Expanded(
          child: Text(
            isShared ? value : notShared,
            style: (small ? textTheme.bodySmall : textTheme.bodyLarge)
                ?.copyWith(color: isShared ? mc.textPrimary : mc.textTertiary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
