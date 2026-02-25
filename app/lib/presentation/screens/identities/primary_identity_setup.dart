part of 'identities_screen.dart';

class _PrimaryIdentitySetup extends ConsumerWidget {
  const _PrimaryIdentitySetup({
    required this.formKey,
  });

  final String? identityId = null;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = identityFormScreenControllerProvider(identityId);
    final controller = ref.read(provider.notifier);
    controller.initializeFocusListeners(formKey);
    final hasEnteredAnyInfo =
        ref.watch(provider.select((s) => s.hasEnteredAnyInfo));
    final canSave = ref.watch(provider.select((s) => s.canSave));
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: [
          Text(
            l10n.setupPrimaryIdentityTitle,
            style: context.textTheme.titleLarge,
          ),
          Container(
            width: ScreensizeHelper.getConstrainedWidth(context),
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IdentityFormFields(
              identityId,
              controller: controller,
              formKey: formKey,
              title: l10n.primaryIdentityInformation,
            ),
          ),
          ElevatedLoadingButton(
            onPressed: canSave ? handleSave : null,
            child: Text(
              hasEnteredAnyInfo
                  ? l10n.primaryIdentityComplete
                  : l10n.keepMeAnonymous,
            ),
          ),
        ],
      ),
    );
  }
}
