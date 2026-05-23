part of 'r_card_attachments_plugin.dart';

class _SelectRCardIdentityScreen extends ConsumerStatefulWidget {
  const _SelectRCardIdentityScreen();

  @override
  ConsumerState<_SelectRCardIdentityScreen> createState() =>
      _SelectRCardIdentityScreenState();
}

class _SelectRCardIdentityScreenState
    extends ConsumerState<_SelectRCardIdentityScreen> {
  Identity? _selected;

  @override
  void initState() {
    super.initState();
    // Pre-select current/primary identity so the picker opens on the last chosen one.
    _selected =
        ref.read(identitiesServiceProvider.currentIdentityOrPrimary) ??
        ref.read(identitiesServiceProvider).identities.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final identities = ref.watch(identitiesServiceProvider).identities;
    final currentOrPrimary = ref.watch(
      identitiesServiceProvider.currentIdentityOrPrimary,
    );
    final cacheManager = ref.read(cacheManagerProvider);
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    // Pre-select the current/primary identity so the Send button is enabled
    // immediately and the picker opens on the identity the user last chose.
    _selected ??= currentOrPrimary ?? identities.firstOrNull;
    final selectedIndex = _selected == null
        ? 0
        : identities.indexOf(_selected!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(l10n.selectIdentityTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      child: Text(
                        l10n.selectIdentityInstruction,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                    IdentityPicker(
                      key: const ValueKey('rcard_identity_picker'),
                      identities: identities,
                      displayMode: true,
                      initialCardIndex: selectedIndex,
                      cacheManager: cacheManager,
                      onSelectedIdentity: (identity) {
                        setState(() => _selected = identity);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Wrap(
                alignment: WrapAlignment.center,
                runSpacing: 12,
                spacing: 12,
                children: [
                  ElevatedLoadingButton(
                    color: colorScheme.primary,
                    isOutlined: true,
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.generalCancel),
                  ),
                  ElevatedLoadingButton(
                    onPressed: _selected == null
                        ? null
                        : () => Navigator.pop(context, _selected),
                    child: Text(l10n.sendRCard),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
