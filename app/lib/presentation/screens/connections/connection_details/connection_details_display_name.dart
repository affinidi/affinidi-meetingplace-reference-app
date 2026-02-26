part of 'connection_details_screen.dart';

class _DisplayNamePanel extends ConsumerWidget {
  _DisplayNamePanel(this.contactId);

  final String contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.read(connectionDetailsScreenControllerProvider(contactId).notifier);

    return Column(
      spacing: 10,
      children: [
        FormCard(
          title: context.l10n.displayName,
          child: FormRowTextField(
            icon: Icons.edit,
            label: context.l10n.generalName,
            color: context.customColors.success,
            controller: controller.displayNameController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            singleLine: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            context.l10n.displayNameHelperText,
            style: context.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
