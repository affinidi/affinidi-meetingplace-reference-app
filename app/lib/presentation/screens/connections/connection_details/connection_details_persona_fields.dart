part of 'connection_details_screen.dart';

List<Widget> _buildPersonaFieldRows(BuildContext context, ContactCard? card) {
  if (card == null) {
    return const [];
  }

  return card
      .populatedFields(includeDisplayNameFields: false)
      .map(
        (IdentityField field) => FormRowIconTitle(
          icon: field.icon,
          iconColor: field.iconColor(context.customColors, context.colorScheme),
          label: field.label(context.l10n),
          value: card.valueFor(field),
        ),
      )
      .toList(growable: false);
}
