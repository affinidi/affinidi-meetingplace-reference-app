part of 'identity_form_screen.dart';

class _IdentityFormBottomContainer extends ConsumerWidget {
  const _IdentityFormBottomContainer(this.identityId, {required this.mode});

  final String? identityId;
  final IdentityFormMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = identityFormScreenControllerProvider(identityId);
    final controller = ref.read(provider.notifier);
    final canSave = ref.watch(provider.select((state) => state.canSave));
    final canDelete = ref.watch(provider.select((state) => state.canDelete));
    final emailField = ContactCardFieldDefinitions.byKey(
      ContactCardFieldKey.email,
    );

    Future<void> handleSave() async {
      controller.updateErrorVisibilityOnBlur(
        emailField,
        editIdentityScreenFormKey,
      );

      final isValid =
          editIdentityScreenFormKey.currentState?.validate() ?? false;
      controller.validateForm(editIdentityScreenFormKey);

      if (!isValid) {
        return;
      }

      final success = await controller.saveIdentity(
        anonymousLabel: context.l10n.anonymous,
        mode: mode,
      );

      if (success && context.mounted) {
        controller.markAsCurrentIdentity();
        context.pop();
      }
    }

    Future<void> handleDelete() async {
      final success = await controller.deleteIdentity();
      if (success && context.mounted) {
        context.pop();
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        ElevatedLoadingButton(
          onPressed: canDelete ? handleDelete : null,
          color: context.colorScheme.error,
          child: Text(context.l10n.generalDelete),
        ),
        ElevatedLoadingButton(
          onPressed: canSave ? handleSave : null,
          child: Text(context.l10n.generalDone),
        ),
      ],
    );
  }
}
