part of '../identities_screen.dart';

class _PrimaryIdentityBottomContainer extends ConsumerWidget {
  const _PrimaryIdentityBottomContainer({
    required this.identityId,
    required this.formKey,
  });

  final String? identityId;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = identityFormScreenControllerProvider(identityId);
    final controller = ref.read(provider.notifier);
    final hasEnteredAnyInfo = ref.watch(
      provider.select((s) => s.hasEnteredAnyInfo),
    );
    final canSave = ref.watch(
      provider.select((s) => s.canSave),
    );
    final l10n = context.l10n;

    Future<void> handleSave() async {
      controller.updateErrorVisibilityOnBlur('email', formKey);

      final isValid = formKey.currentState?.validate() ?? false;
      controller.validateForm(formKey);

      if (!isValid) return;

      final success = await controller.saveIdentity(
        anonymousLabel: context.l10n.anonymous,
        mode: IdentityFormMode.add,
      );

      if (success) {
        controller.markAsCurrentIdentity();
      }
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
        child: ElevatedLoadingButton(
          onPressed: canSave ? handleSave : null,
          child: Text(
            hasEnteredAnyInfo
                ? l10n.primaryIdentityComplete
                : l10n.keepMeAnonymous,
          ),
        ),
      ),
    );
  }
}
