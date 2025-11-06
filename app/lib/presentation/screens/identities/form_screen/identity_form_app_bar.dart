part of 'identity_form_screen.dart';

class _IdentityFormAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  const _IdentityFormAppBar(this.identityId, {required this.mode});

  final String? identityId;
  final IdentityFormMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = identityFormScreenControllerProvider(identityId);
    final card = ref.watch(provider.select((state) => state.identity.card));
    final title = mode == IdentityFormMode.edit
        ? context.l10n.editIdentityTitle(card.displayName)
        : context.l10n.newIdentityAlias;

    return AppBar(
      title: Text(title),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
