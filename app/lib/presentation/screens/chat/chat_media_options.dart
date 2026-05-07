part of 'chat_screen.dart';

class _ChatMediaOptionItem {
  const _ChatMediaOptionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final dynamic icon; // Can be String (emoji) or IconData
  final String label;
  final VoidCallback? onTap;
}

class _ChatMediaOption extends StatelessWidget {
  const _ChatMediaOption({required _ChatMediaOptionItem item}) : _item = item;

  final _ChatMediaOptionItem _item;

  @override
  Widget build(BuildContext context) {
    final enabled = _item.onTap != null;
    Widget leading;
    if (_item.icon is IconData) {
      leading = Icon(
        _item.icon as IconData,
        size: 30,
        color: !enabled ? context.theme.disabledColor : Colors.white,
      );
    } else {
      leading = Text(
        _item.icon as String,
        style: TextStyle(
          fontSize: 30,
          color: !enabled ? context.theme.disabledColor : null,
        ),
      );
    }
    return ListTile(
      enabled: enabled,
      leading: leading,
      title: Text(
        _item.label,
        style: TextStyle(
          color: !enabled ? context.theme.disabledColor : Colors.white,
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
    final isZkpEnabled = ref.read(environmentProvider).zkpEnabled;
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final chatState = ref.watch(provider);
    final hasIncomingMessageFromOtherParty = chatState.messages.any(
      (item) => item is chat.Message && !item.isFromMe,
    );
    final canRequestZkp =
        chatState.isInitialized &&
        hasIncomingMessageFromOtherParty &&
        (chatState.contact?.status == ContactStatus.approved ||
            chatState.contact?.status == ContactStatus.active);
    final availableAttachmentPlugins = ref.read(
      availableAttachmentPluginsProvider,
    );

    void sendEffect(ScreenEffect effect) {
      if (!context.mounted) return;

      controller.sendEffect(effect);

      if (!context.mounted) return;

      Navigator.of(context).pop();
    }

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
          icon: plugin.icon,
          label: label,
          onTap: supported ? () => attachFromPlugin(plugin) : null,
        );
      }),
      _ChatMediaOptionItem(
        icon: '🎈',
        label: context.l10n.generalBalloons,
        onTap: () {
          sendEffect(ScreenEffect.balloons());
        },
      ),
      _ChatMediaOptionItem(
        // https://www.amp-what.com/unicode/search/confetti
        icon: '🎊',
        label: context.l10n.generalConfetti,
        onTap: () {
          sendEffect(ScreenEffect.confetti());
        },
      ),
      if (isZkpEnabled)
        _ChatMediaOptionItem(
          icon: Icons.verified_user,
          label: 'Human Zero-Knowledge Proof',
          onTap: canRequestZkp
              ? () {
                  // Trigger liveness check request once channel is ready.
                  ref
                      .read(proofFlowControllerProvider(_contactId).notifier)
                      .requestLivenessCheck();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              : null,
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
