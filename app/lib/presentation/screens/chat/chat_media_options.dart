part of 'chat_screen.dart';

// ---------------------------------------------------------------------------
// AI Agent picker
// ---------------------------------------------------------------------------

class _AiAgentItem {
  const _AiAgentItem({
    required this.icon,
    required this.name,
    required this.description,
    this.mnemonic,
  });

  final String icon;
  final String name;
  final String description;
  final String? mnemonic;
}

List<_AiAgentItem> _hardcodedAgents(Environment environment) => [
  _AiAgentItem(
    icon: '🧑‍💼',
    name: 'Concierge',
    description: 'Your personal meeting assistant',
    mnemonic: environment.conciergeAgentMnemonic,
  ),
  const _AiAgentItem(
    icon: '📊',
    name: 'Analyst',
    description: 'Insights, summaries and data help',
  ),
  const _AiAgentItem(
    icon: '🗓️',
    name: 'Scheduler',
    description: 'Booking, reminders and calendar tasks',
  ),
];

class _AiAgentPicker extends ConsumerWidget {
  const _AiAgentPicker({required String contactId}) : _contactId = contactId;

  final String _contactId;

  static Future<void> show(
    BuildContext context, {
    required String contactId,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AiAgentPicker(contactId: contactId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      chatScreenControllerProvider(_contactId).notifier,
    );
    final agents = _hardcodedAgents(ref.read(environmentProvider));

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: BottomSheetMenu(
        showHandle: true,
        header: 'Invite AI Agent',
        itemCount: agents.length,
        itemBuilder: (context, index) {
          final agent = agents[index];
          final hasMnemonic = agent.mnemonic != null;
          return ListTile(
            enabled: hasMnemonic,
            leading: Text(agent.icon, style: const TextStyle(fontSize: 30)),
            title: Text(
              agent.name,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            subtitle: Text(
              agent.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            onTap: !hasMnemonic
                ? null
                : () {
                    Navigator.of(context).pop();
                    controller.sendAgentOutreachInvitation(agent.mnemonic!);
                  },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Media / actions options
// ---------------------------------------------------------------------------

class _ChatMediaOptionItem {
  const _ChatMediaOptionItem({
    required this.textCharacterIcon,
    required this.label,
    required this.onTap,
  });

  final String textCharacterIcon;
  final String label;
  final VoidCallback? onTap;
}

class _ChatMediaOption extends StatelessWidget {
  const _ChatMediaOption({required _ChatMediaOptionItem item}) : _item = item;

  final _ChatMediaOptionItem _item;

  @override
  Widget build(BuildContext context) {
    final enabled = _item.onTap != null;
    return ListTile(
      enabled: enabled,
      leading: Text(
        _item.textCharacterIcon,
        style: TextStyle(
          fontSize: 30,
          color: !enabled ? context.theme.disabledColor : null,
        ),
      ),
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
    final provider = chatScreenControllerProvider(_contactId);
    final controller = ref.read(provider.notifier);
    final availableAttachmentPlugins = ref
        .read(availableAttachmentPluginsProvider)
        .where((plugin) => plugin is! AudioAttachmentsPlugin)
        .toList();

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

      Navigator.of(context).pop();

      if (result != null) {
        unawaited(controller.sendAttachment(result.text, result.attachments));
      }
    }

    final items = <_ChatMediaOptionItem>[
      ...availableAttachmentPlugins.map((plugin) {
        final supported = plugin.isPlatformSupported;
        final label = supported
            ? plugin.localizedName(context)
            : '${plugin.localizedName(context)}\n'
                  '(${context.l10n.platformNotSupported})';

        return _ChatMediaOptionItem(
          textCharacterIcon: plugin.icon,
          label: label,
          onTap: supported ? () => attachFromPlugin(plugin) : null,
        );
      }),
      _ChatMediaOptionItem(
        textCharacterIcon: '🎈',
        label: context.l10n.generalBalloons,
        onTap: () {
          sendEffect(ScreenEffect.balloons());
        },
      ),
      _ChatMediaOptionItem(
        // https://www.amp-what.com/unicode/search/confetti
        textCharacterIcon: '🎊',
        label: context.l10n.generalConfetti,
        onTap: () {
          sendEffect(ScreenEffect.confetti());
        },
      ),
      _ChatMediaOptionItem(
        textCharacterIcon: '🤖',
        label: 'Invite AI Agent',
        onTap: () {
          Navigator.of(context).pop();
          _AiAgentPicker.show(context, contactId: _contactId);
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
