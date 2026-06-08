part of 'chat_screen.dart';

class _ChatMediaOptionItem {
  const _ChatMediaOptionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final AttachmentPluginIcon icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
}

class _ChatMediaOption extends StatelessWidget {
  const _ChatMediaOption({required _ChatMediaOptionItem item}) : _item = item;

  final _ChatMediaOptionItem _item;

  @override
  Widget build(BuildContext context) {
    final tappable = _item.onTap != null;
    final styleEnabled = _item.enabled;
    final icon = _item.icon;

    Widget leading;
    if (icon is MaterialIcon) {
      leading = Icon(
        icon.iconData,
        size: 30,
        color: icon.color ?? (!tappable ? context.theme.disabledColor : null),
      );
    } else if (icon is AssetIcon) {
      leading = Image.asset(
        icon.assetPath,
        width: 30,
        height: 30,
        color: !tappable ? context.theme.disabledColor : null,
        colorBlendMode: !tappable ? BlendMode.srcIn : null,
      );
    } else if (icon is EmojiIcon) {
      leading = Text(
        icon.emoji,
        style: TextStyle(
          fontSize: 30,
          color: !tappable ? context.theme.disabledColor : null,
        ),
      );
    } else {
      leading = const SizedBox.shrink();
    }

    return ListTile(
      enabled: tappable,
      leading: leading,
      title: Text(
        _item.label,
        style: TextStyle(
          color: !styleEnabled ? context.theme.disabledColor : Colors.white,
          fontSize: 18,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      onTap: _item.onTap,
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
    final isGroupChat = ref.watch(
      provider.select((state) => state.contact?.isGroup ?? false),
    );
    final shouldEnableRCardAttachment = !isGroupChat;
    final contact = ref.watch(provider.select((state) => state.contact));
    final isOobChat = contact?.origin == ContactOrigin.directInteractive;
    final shouldEnableVrcAttachment =
        !isGroupChat &&
        !isOobChat &&
        ref.watch(provider.select((state) => state.shouldEnableVrcAttachment));

    void sendEffect(ScreenEffect effect) {
      if (!context.mounted) return;

      controller.sendEffect(effect);

      if (!context.mounted) return;

      Navigator.of(context).pop();
    }

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

    final items = <_ChatMediaOptionItem>[
      ...availableAttachmentPlugins.map((plugin) {
        final platformSupported = plugin.isPlatformSupported;
        final enabled = switch (plugin) {
          RCardAttachmentsPlugin() => shouldEnableRCardAttachment,
          VrcAttachmentsPlugin() => shouldEnableVrcAttachment,
          _ => true,
        };
        final supported = platformSupported && enabled;
        final label = !platformSupported
            ? '${plugin.localizedName(context)}\n'
                  '(${context.l10n.platformNotSupported})'
            : plugin.localizedName(context);

        return _ChatMediaOptionItem(
          icon: plugin.icon,
          label: label,
          onTap: supported ? () => attachFromPlugin(plugin) : null,
          enabled: supported,
        );
      }),
      _ChatMediaOptionItem(
        icon: const EmojiIcon('🎈'),
        label: context.l10n.generalBalloons,
        onTap: () {
          sendEffect(ScreenEffect.balloons());
        },
      ),
      _ChatMediaOptionItem(
        // https://www.amp-what.com/unicode/search/confetti
        icon: const EmojiIcon('🎊'),
        label: context.l10n.generalConfetti,
        onTap: () {
          sendEffect(ScreenEffect.confetti());
        },
      ),
    ];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: BottomSheetMenu(
        showHandle: true,
        itemCount: items.length,
        itemBuilder: (context, index) => _ChatMediaOption(item: items[index]),
      ),
    );
  }
}
