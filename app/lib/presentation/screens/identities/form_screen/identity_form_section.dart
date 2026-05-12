part of 'identity_form_screen.dart';

final editIdentityScreenFormKey = GlobalKey<FormState>();

class _IdentityFormSection extends ConsumerWidget {
  const _IdentityFormSection(this.identityId);

  final String? identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = identityFormScreenControllerProvider(identityId);
    final controller = ref.read(provider.notifier);
    controller.initializeFocusListeners(editIdentityScreenFormKey);

    return IdentityFormFields(
      identityId,
      formKey: editIdentityScreenFormKey,
      title: context.l10n.identityAliasPersonalDetails,
    );
  }
}
