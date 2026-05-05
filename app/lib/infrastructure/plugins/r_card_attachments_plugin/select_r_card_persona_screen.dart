part of 'r_card_attachments_plugin.dart';

class _SelectRCardPersonaScreen extends ConsumerStatefulWidget {
  const _SelectRCardPersonaScreen();

  @override
  ConsumerState<_SelectRCardPersonaScreen> createState() =>
      _SelectRCardPersonaScreenState();
}

class _SelectRCardPersonaScreenState
    extends ConsumerState<_SelectRCardPersonaScreen> {
  Identity? _selected;

  @override
  Widget build(BuildContext context) {
    final identities = ref.watch(identitiesServiceProvider).identities;
    final cacheManager = ref.read(cacheManagerProvider);
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    // Pre-select first identity so the Send button is enabled immediately
    _selected ??= identities.firstOrNull;
    final selectedIndex = _selected == null
        ? 0
        : identities.indexOf(_selected!);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(l10n.selectPersonaTitle),
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
                        l10n.selectPersonaInstruction,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                    IdentityPicker(
                      key: const ValueKey('rcard_persona_picker'),
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
