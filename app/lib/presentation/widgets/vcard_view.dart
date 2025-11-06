import 'package:flutter/material.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/extensions/vcard_extensions.dart';

class VCardView extends StatelessWidget {
  const VCardView({super.key, required this.vCard});

  final VCard vCard;

  @override
  Widget build(BuildContext context) {
    final fields = <_VCardFieldKey, String>{
      _VCardFieldKey.firstName: vCard.firstName,
      _VCardFieldKey.lastName: vCard.lastName,
      _VCardFieldKey.email: vCard.email,
      _VCardFieldKey.mobile: vCard.mobile,
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      context.l10n.vCardFieldName(field.key.name),
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
            itemCount: fields.entries.length),
      ],
    );
  }
}

enum _VCardFieldKey {
  firstName,
  lastName,
  email,
  mobile,
  ;

  Color get iconColor {
    switch (this) {
      case _VCardFieldKey.firstName:
        return Colors.blue;
      case _VCardFieldKey.lastName:
        return Colors.purple;
      case _VCardFieldKey.email:
        return Colors.blue;
      case _VCardFieldKey.mobile:
        return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case _VCardFieldKey.firstName:
        return Icons.person;
      case _VCardFieldKey.lastName:
        return Icons.people;
      case _VCardFieldKey.email:
        return Icons.email;
      case _VCardFieldKey.mobile:
        return Icons.phone_iphone;
    }
  }
}
