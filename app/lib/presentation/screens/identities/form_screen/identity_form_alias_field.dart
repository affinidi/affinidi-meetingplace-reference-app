part of 'identity_form_screen.dart';

class _IdentityFormAliasField extends ConsumerWidget {
  const _IdentityFormAliasField(this.identityId);

  final String? identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = identityFormScreenControllerProvider(identityId);
    final controller = ref.read(provider.notifier);

    return FormCard(
      title: context.l10n.aliasLabel,
      child: FormRowTextField(
        controller: controller.aliasController,
        color: context.colorScheme.primary,
        label: context.l10n.aliasLabel,
        placeholder: context.l10n.enterAliasLabel,
        onChanged: controller.updateAlias,
        hint: context.l10n.aliasLabelHelperText,
        textCapitalization: TextCapitalization.sentences,
        autocorrect: true,
        textInputAction: TextInputAction.done,
        traversalOrder: identityFields.length + 1.0,
      ),
    );
  }
}
