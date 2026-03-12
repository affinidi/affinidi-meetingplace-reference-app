import 'package:flutter/material.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;

import '../../domain/models/contact_card/contact_card.dart';
import '../../domain/models/contact_card/identity_field.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/extensions/contact_card_extensions.dart';
import '../config/persona_field_config.dart';

class ContactCardView extends StatelessWidget {
  const ContactCardView({super.key, required this.card});

  final ContactCard card;

  @override
  Widget build(BuildContext context) {
    return _PersonaFieldListView(
      fields: card.populatedFields().toList(),
      valueResolver: card.valueFor,
    );
  }
}

class SdkContactCardView extends StatelessWidget {
  const SdkContactCardView({super.key, required this.card});

  final sdk.ContactCard card;

  @override
  Widget build(BuildContext context) {
    return _PersonaFieldListView(
      fields: card.populatedFields().toList(),
      valueResolver: card.valueFor,
    );
  }
}

class _PersonaFieldListView extends StatelessWidget {
  const _PersonaFieldListView({
    required this.fields,
    required this.valueResolver,
  });

  final List<IdentityField> fields;
  final String Function(IdentityField) valueResolver;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final field = fields[index];
        return ListTile(
          iconColor: context.colorScheme.onPrimary,
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          leading: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: field.iconColor(context.customColors, context.colorScheme),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Icon(field.icon, size: 18),
          ),
          title: Row(
            spacing: 12,
            children: [
              Text(
                field.label(context.l10n),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Expanded(
                child: Text(
                  valueResolver(field),
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: fields.length,
    );
  }
}
