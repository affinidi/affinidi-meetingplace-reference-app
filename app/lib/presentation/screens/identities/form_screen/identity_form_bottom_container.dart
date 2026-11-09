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
    final isSaving = ref.watch(provider.select((state) => state.isSaving));
    final isDeleting = ref.watch(provider.select((state) => state.isDeleting));
    final isBusy = isSaving || isDeleting;
    final emailField = ContactCardFieldDefinitions.byKey(
      ContactCardFieldKey.email,
    );

    Future<void> handleSave() async {
      final mobileField = ContactCardFieldDefinitions.byKey(
        ContactCardFieldKey.mobile,
      );
      controller.updateErrorVisibilityOnBlur(
        mobileField,
        editIdentityScreenFormKey,
      );
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

      if (!context.mounted) return;
      if (success) {
        controller.markAsCurrentIdentity();
        context.pop();
      } else {
        _showError(context, context.l10n.identityVtaSaveFailed);
      }
    }

    Future<void> handleDelete() async {
      final isPersona = ref.read(provider).identity.isVtaPersona;
      if (isPersona && !await _confirmDelete(context)) return;

      final success = await controller.deleteIdentity();
      if (!context.mounted) return;
      if (success) {
        context.pop();
      } else {
        _showError(context, context.l10n.identityVtaDeleteFailed);
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        ElevatedLoadingButton(
          key: const Key('identity_form_delete'),
          isLoading: isDeleting,
          onPressed: isBusy
              ? null
              : canDelete
              ? handleDelete
              : context.pop,
          // Destructive: a danger outline, never a red fill.
          isOutlined: true,
          color: context.mcColors.dangerText,
          child: Text(
            canDelete ? context.l10n.generalDelete : context.l10n.generalCancel,
          ),
        ),
        ElevatedLoadingButton(
          key: const Key('identity_form_save'),
          isLoading: isSaving,
          onPressed: canSave && !isBusy ? handleSave : null,
          child: Text(context.l10n.generalDone),
        ),
      ],
    );
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: context.mcColors.dangerText),
        ),
      ),
    );
  }

  /// Asks before deleting a persona, whose DID can never be used again.
  static Future<bool> _confirmDelete(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.identityDeleteConfirmTitle),
        content: Text(l10n.identityDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.generalCancel),
          ),
          TextButton(
            key: const Key('identity_delete_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.error,
            ),
            child: Text(l10n.generalDelete),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
