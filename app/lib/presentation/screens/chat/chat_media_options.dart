part of 'chat_screen.dart';

class _ChatMediaOptionItem {
  const _ChatMediaOptionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isBalloon = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isBalloon;
}

class _ChatMediaOption extends StatelessWidget {
  const _ChatMediaOption({required _ChatMediaOptionItem item}) : _item = item;

  final _ChatMediaOptionItem _item;

  @override
  Widget build(BuildContext context) {
    final enabled = _item.onTap != null;
    final colorScheme = context.colorScheme;
    final foregroundColor = enabled
        ? colorScheme.primary
        : context.theme.disabledColor;

    return Semantics(
      button: true,
      enabled: enabled,
      label: _item.label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _item.onTap,
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
                  child: _item.isBalloon
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
                      : Icon(_item.icon, size: 34, color: foregroundColor),
                ),
                Text(
                  _item.label,
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
  _ChatMediaOptions({required String contactId}) : _contactId = contactId;

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
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final availableAttachmentPlugins = ref.read(
      availableAttachmentPluginsProvider,
    );

    void attachFromPlugin(AttachmentPlugin plugin) async {
      if (!context.mounted) return;

      final result = await plugin.pickAttachments(context);

      if (!context.mounted) return;

      if (result != null) {
        await controller.sendAttachment(result.text, result.attachments);
      }

      if (!context.mounted) return;

      Navigator.of(context).pop();
    }

    final items = <_ChatMediaOptionItem>[
      ...availableAttachmentPlugins.map((plugin) {
        final supported = plugin.isPlatformSupported;
        final label = supported
            ? plugin.localizedName(context)
            : '${plugin.localizedName(context)}\n'
                  '(${context.l10n.platformNotSupported})';

        return _ChatMediaOptionItem(
          icon: switch (plugin.icon) {
            '📷' => Icons.camera_alt,
            '🖼' => Icons.image_outlined,
            '🎬' => Icons.image_outlined,
            '📄' => Icons.assignment_outlined,
            _ => Icons.attachment,
          },
          label: label,
          onTap: supported ? () => attachFromPlugin(plugin) : null,
        );
      }),
    ];

    return _ChatOptionsBottomSheet(items: items);
  }
}

class _ChatEffectOptions extends ConsumerWidget {
  _ChatEffectOptions({required String contactId}) : _contactId = contactId;

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

    return _ChatOptionsBottomSheet(items: items);
  }
}

class _ChatOptionsBottomSheet extends StatelessWidget {
  const _ChatOptionsBottomSheet({required this.items});

  static const _columnCount = 3;
  static const _itemExtent = 136.0;
  static const _horizontalPadding = 20.0;
  static const _topPadding = 24.0;
  static const _bottomPadding = 24.0;
  static const _rowSpacing = 6.0;
  static const _effectTopPadding = 64.0;
  static const _borderRadius = BorderRadius.vertical(top: Radius.circular(28));

  final List<_ChatMediaOptionItem> items;

  @override
  Widget build(BuildContext context) {
    final isEffectSheet = items.length == 2;
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
          color: context.colorScheme.surfaceContainerHigh,
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
