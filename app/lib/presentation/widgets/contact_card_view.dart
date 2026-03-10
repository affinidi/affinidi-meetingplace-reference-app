import 'package:flutter/material.dart';
import 'package:meeting_place_core/meeting_place_core.dart' as sdk;

import '../../domain/models/contact_card/contact_card.dart';
import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/extensions/contact_card_extensions.dart';

class ContactCardView extends StatelessWidget {
  const ContactCardView({super.key, required this.card});

  final ContactCard card;

  @override
  Widget build(BuildContext context) {
    final fields = <_ContactCardFieldKey, String>{
      _ContactCardFieldKey.firstName: card.firstName,
      _ContactCardFieldKey.lastName: card.lastName ?? '',
      _ContactCardFieldKey.email: card.email ?? '',
      _ContactCardFieldKey.mobile: card.mobile ?? '',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final field = fields.entries.elementAt(index);
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
                  color: field.key.iconColor,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Icon(field.key.icon, size: 18),
              ),
              title: Row(
                spacing: 12,
                children: [
                  Text(
                    context.l10n.contactCardFieldName(field.key.name),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      field.value,
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
          itemCount: fields.entries.length,
        ),
      ],
    );
  }
}

class SdkContactCardView extends StatelessWidget {
  const SdkContactCardView({super.key, required this.card});

  final sdk.ContactCard card;

  @override
  Widget build(BuildContext context) {
    final fields = <_ContactCardFieldKey, String>{
      _ContactCardFieldKey.firstName: card.firstName,
      _ContactCardFieldKey.lastName: card.lastName,
      _ContactCardFieldKey.email: card.email,
      _ContactCardFieldKey.mobile: card.mobile,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final field = fields.entries.elementAt(index);
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
                  color: field.key.iconColor,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Icon(field.key.icon, size: 18),
              ),
              title: Row(
                spacing: 12,
                children: [
                  Text(
                    context.l10n.contactCardFieldName(field.key.name),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      field.value,
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
          itemCount: fields.entries.length,
        ),
      ],
    );
  }
}

enum _ContactCardFieldKey {
  firstName,
  lastName,
  email,
  mobile;

  Color get iconColor {
    switch (this) {
      case _ContactCardFieldKey.firstName:
        return Colors.blue;
      case _ContactCardFieldKey.lastName:
        return Colors.purple;
      case _ContactCardFieldKey.email:
        return Colors.blue;
      case _ContactCardFieldKey.mobile:
        return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case _ContactCardFieldKey.firstName:
        return Icons.person;
      case _ContactCardFieldKey.lastName:
        return Icons.people;
      case _ContactCardFieldKey.email:
        return Icons.email;
      case _ContactCardFieldKey.mobile:
        return Icons.phone_iphone;
    }
  }
}
