part of 'vrc_attachments_plugin.dart';

class SelectVrcIdentityScreen extends ConsumerStatefulWidget {
  const SelectVrcIdentityScreen({
    this.name,
    this.otherPartyCard,
    this.role = VrcExchangeRole.initiator,
  });

  final String? name;

  /// When the local user is the responder, this holds the initiator's card so
  /// it can be displayed at the top of the screen.
  final ContactCard? otherPartyCard;

  /// Whether the local user is the initiator or responder.
  final VrcExchangeRole role;

  @override
  ConsumerState<SelectVrcIdentityScreen> createState() =>
      SelectVrcIdentityScreenState();
}

class SelectVrcIdentityScreenState
    extends ConsumerState<SelectVrcIdentityScreen> {
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

    final name = widget.name;
    final otherPartyCard = widget.otherPartyCard;
    final isResponder = widget.role == VrcExchangeRole.responder;

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
                    if (isResponder && otherPartyCard != null && name != null)
                      _ResponderContent(
                        name: name,
                        otherPartyCard: otherPartyCard,
                      )
                    else
                      _InitiatorContent(name: name),
                    const SizedBox(height: 8),
                    IdentityPicker(
                      key: const ValueKey('vrc_identity_picker'),
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
                    child: Text(
                      isResponder ? l10n.generalVerify : l10n.generateVrc,
                    ),
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

class _InitiatorContent extends StatelessWidget {
  const _InitiatorContent({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Text(
            name != null
                ? l10n.selectIdentityToVerifyRelationshipWithName(name!)
                : l10n.selectIdentityInstruction,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResponderContent extends StatelessWidget {
  const _ResponderContent({required this.name, required this.otherPartyCard});

  final String name;
  final ContactCard otherPartyCard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        spacing: 20,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.nameSelectedIdentity(name),
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
          _OtherPartyIdentityCard(card: otherPartyCard),
          const SizedBox(height: 1),
          Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.8)),
          const SizedBox(height: 1),
          Text(
            l10n.selectIdentityToVerifyRelationshipPrompt(name),
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

/// A read-only card showing the initiator's contact information.
class _OtherPartyIdentityCard extends ConsumerWidget {
  const _OtherPartyIdentityCard({required this.card});

  final ContactCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final l10n = context.l10n;
    final cacheManager = ref.read(cacheManagerProvider);

    final fullName = card.displayName.isNotEmpty
        ? card.displayName
        : l10n.notShared;
    final email = card.email?.isNotEmpty == true ? card.email! : l10n.notShared;
    final phone = card.mobile?.isNotEmpty == true
        ? card.mobile!
        : l10n.notShared;
    final image = card.image(cacheManager: cacheManager);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 16,
              right: 100,
              bottom: 16,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Icon(
                            Icons.email,
                            color: colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            email,
                            style: textTheme.titleMedium,
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Icon(
                            Icons.phone,
                            color: colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            phone,
                            style: textTheme.titleMedium,
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: ProfilePicture(image: image, size: 80),
            ),
          ],
        ),
      ),
    );
  }
}
