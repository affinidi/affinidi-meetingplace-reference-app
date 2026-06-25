part of 'chat_screen.dart';

const _kAttachmentPluginIcons = <String, IconData>{
  '📷': Icons.camera_alt,
  '🖼': Icons.image_outlined,
  '📄': Icons.assignment_outlined,
};

bool _isHiddenAttachmentIcon(AttachmentPluginIcon icon) => switch (icon) {
  EmojiIcon(:final emoji) => emoji.startsWith('🎬'),
  _ => false,
};

IconData _resolveAttachmentIcon(AttachmentPluginIcon icon) => switch (icon) {
  MaterialIcon(:final iconData) => iconData,
  EmojiIcon(:final emoji) =>
    _kAttachmentPluginIcons[emoji] ??
        (emoji.startsWith('📷')
            ? Icons.camera_alt
            : emoji.startsWith('🖼')
            ? Icons.image_outlined
            : emoji.startsWith('📄')
            ? Icons.assignment_outlined
            : Icons.attachment),
  AssetIcon() => Icons.attachment,
};

IconData _resolveMediaOptionIcon(AttachmentPlugin plugin) => switch (plugin) {
  VrcAttachmentsPlugin() => Icons.handshake,
  RCardAttachmentsPlugin() => Icons.credit_card,
  _ => _resolveAttachmentIcon(plugin.icon),
};

class _ChatMediaOptionItem {
  const _ChatMediaOptionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.subtitle,
    this.isBalloon = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final String? subtitle;
  final bool isBalloon;
}

class _ChatMediaOption extends StatelessWidget {
  const _ChatMediaOption({required this.item});

  final _ChatMediaOptionItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final foregroundColor = item.enabled
        ? colorScheme.primary
        : context.theme.disabledColor;

    return Semantics(
      button: true,
      enabled: item.enabled,
      label: item.label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: item.isBalloon
                      ? ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            foregroundColor,
                            BlendMode.srcIn,
                          ),
                          child: const Text(
                            '🎈',
                            style: TextStyle(fontSize: 34),
                          ),
                        )
                      : Icon(item.icon, size: 34, color: foregroundColor),
                ),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatMediaOptions extends ConsumerWidget {
  _ChatMediaOptions({required this._contactId});

  static Future<void> show({
    required BuildContext context,
    required String contactId,
  }) async => await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ChatMediaOptions(contactId: contactId),
  );

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isZkpEnabled = ref.read(environmentProvider).zkpEnabled;
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    ref.watch(provider);
    final availableAttachmentPlugins = ref.read(
      availableAttachmentPluginsProvider,
    );
    final isGroupChat = ref.watch(
      provider.select((state) => state.contact?.isGroup ?? false),
    );
    final supportsHumanZkp = ref.watch(
      provider.select(
        (state) =>
            state.capabilities?.supports(chat.ChatFeature.humanZkp) ?? false,
      ),
    );
    final supportsDocumentAttachments = ref.watch(
      provider.select(
        (state) =>
            state.capabilities?.supports(
              chat.ChatFeature.documentAttachments,
            ) ??
            false,
      ),
    );
    final shouldEnableRCardAttachment = !isGroupChat;
    final contact = ref.watch(provider.select((state) => state.contact));
    final isOobChat = contact?.origin == ContactOrigin.directInteractive;
    final shouldEnableVrcAttachment =
        !isGroupChat &&
        !isOobChat &&
        ref.watch(provider.select((state) => state.shouldEnableVrcAttachment));

    void attachFromPlugin(AttachmentPlugin plugin) async {
      if (!context.mounted) return;

      var pickContext = context;
      if (plugin.dismissSheetBeforePicking) {
        final rootNav = Navigator.of(context, rootNavigator: true);
        Navigator.of(context).pop();
        pickContext = rootNav.context;
      }

      final result = await plugin.pickAttachments(pickContext);

      if (result != null) {
        await controller.sendAttachment(result.text, result.attachments);
      }

      if (!plugin.dismissSheetBeforePicking && context.mounted) {
        Navigator.of(context).pop();
      }
    }

    final zkpChannelReady =
        isZkpEnabled &&
        supportsHumanZkp &&
        ProofFlowController.watchIsZkpChannelReady(ref, _contactId);
    final hasVerifiedProof = ref.watch(
      provider.select(
        (state) => ChatZkpMessageListPolicy.hasVerifiedProof(state.messages),
      ),
    );
    final zkpOptionEnabled = zkpChannelReady && !hasVerifiedProof;

    final items = <_ChatMediaOptionItem>[
      ...availableAttachmentPlugins
          .where((plugin) => !_isHiddenAttachmentIcon(plugin.icon))
          .where(
            (plugin) =>
                plugin is! DocumentAttachmentsPlugin ||
                supportsDocumentAttachments,
          )
          .map((plugin) {
            final platformSupported = plugin.isPlatformSupported;
            final enabled = switch (plugin) {
              RCardAttachmentsPlugin() => shouldEnableRCardAttachment,
              VrcAttachmentsPlugin() => shouldEnableVrcAttachment,
              _ => true,
            };
            final supported = platformSupported && enabled;
            final baseLabel = switch (plugin) {
              VrcAttachmentsPlugin() => context.l10n.vrcAbbreviation,
              _ => plugin.localizedName(context),
            };
            final label = !platformSupported
                ? '$baseLabel\n'
                      '(${context.l10n.platformNotSupported})'
                : baseLabel;

            return _ChatMediaOptionItem(
              icon: _resolveMediaOptionIcon(plugin),
              label: label,
              onTap: supported ? () => attachFromPlugin(plugin) : null,
              enabled: supported,
            );
          }),
      if (isZkpEnabled && supportsHumanZkp)
        _ChatMediaOptionItem(
          icon: Icons.how_to_reg,
          label: context.l10n.humanZkpAbbreviated,
          subtitle: hasVerifiedProof
              ? context.l10n.zkpProofAlreadyShared
              : null,
          onTap: zkpOptionEnabled
              ? () async {
                  final sent = await ref
                      .read(proofFlowControllerProvider(_contactId).notifier)
                      .requestLivenessCheck();
                  if (!context.mounted || !sent) return;
                  Navigator.of(context).pop();
                }
              : null,
          enabled: zkpOptionEnabled,
        ),
    ];

    return _ChatOptionsBottomSheet(
      items: items,
      kind: _ChatOptionsSheetKind.media,
    );
  }
}

class _ChatEffectOptions extends ConsumerWidget {
  _ChatEffectOptions({required this._contactId});

  static Future<void> show({
    required BuildContext context,
    required String contactId,
  }) async => await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ChatEffectOptions(contactId: contactId),
  );

  final String _contactId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);

    void sendEffect(ScreenEffect effect) {
      if (!context.mounted) return;

      controller.sendEffect(effect);

      if (!context.mounted) return;

      Navigator.of(context).pop();
    }

    final items = <_ChatMediaOptionItem>[
      _ChatMediaOptionItem(
        icon: Icons.celebration_outlined,
        isBalloon: true,
        label: context.l10n.generalBalloons,
        onTap: () {
          sendEffect(ScreenEffect.balloons());
        },
      ),
      _ChatMediaOptionItem(
        // https://www.amp-what.com/unicode/search/confetti
        icon: Icons.celebration,
        label: context.l10n.generalConfetti,
        onTap: () {
          sendEffect(ScreenEffect.confetti());
        },
      ),
    ];

    return _ChatOptionsBottomSheet(
      items: items,
      kind: _ChatOptionsSheetKind.effects,
    );
  }
}

enum _ChatOptionsSheetKind { media, effects }

class _ChatOptionsBottomSheet extends StatelessWidget {
  const _ChatOptionsBottomSheet({required this.items, required this.kind});

  static const _columnCount = 3;
  static const _itemExtent = 152.0;
  static const _horizontalPadding = 20.0;
  static const _topPadding = 24.0;
  static const _bottomPadding = 24.0;
  static const _rowSpacing = 6.0;
  static const _effectTopPadding = 64.0;
  static const _borderRadius = BorderRadius.vertical(top: Radius.circular(28));

  final List<_ChatMediaOptionItem> items;
  final _ChatOptionsSheetKind kind;

  @override
  Widget build(BuildContext context) {
    final isEffectSheet = kind == _ChatOptionsSheetKind.effects;
    final columnCount = isEffectSheet ? items.length : _columnCount;
    final rowCount = (items.length / columnCount).ceil();
    final topPadding = isEffectSheet ? _effectTopPadding : _topPadding;
    final sheetHeight =
        topPadding +
        _bottomPadding +
        (rowCount * _itemExtent) +
        ((rowCount - 1) * _rowSpacing);

    return ClipRRect(
      borderRadius: _borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: ColoredBox(
          color: context.colorScheme.surfaceContainerHigh.withValues(
            alpha: 0.85,
          ),
          child: BottomSheetMenu(
            showHandle: true,
            itemCount: 1,
            itemBuilder: (context, index) => SizedBox(
              height: sheetHeight,
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(
                  _horizontalPadding,
                  topPadding,
                  _horizontalPadding,
                  0,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnCount,
                  mainAxisExtent: _itemExtent,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: _rowSpacing,
                ),
                itemBuilder: (context, index) =>
                    _ChatMediaOption(item: items[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
