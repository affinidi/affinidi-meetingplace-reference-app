part of 'publish_offer_screen.dart';

class _OfferDetailsSection extends ConsumerWidget {
  const _OfferDetailsSection(String identityId) : _identityId = identityId;

  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormCard(
      title: context.l10n.connectionOfferDetails,
      child: Column(
        children: [
          _GroupOffer(_identityId),
          const Divider(),
          _OfferPhrase(_identityId),
          const Divider(),
          _HeadLine(_identityId),
          const Divider(),
          _Description(_identityId),
        ],
      ),
    );
  }
}

class _HeadLine extends ConsumerWidget {
  _HeadLine(String identityId) : _identityId = identityId;

  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        publishOfferScreenControllerProvider(_identityId, context.l10n);
    final controller = ref.read(provider.notifier);
    final isGroupOffer =
        ref.watch(provider.select((state) => state.formData.isGroupOffer));

    return FormRowTextField(
      color: context.customColors.cyan,
      label: isGroupOffer ? context.l10n.chatGroupName : context.l10n.headline,
      icon: Icons.group,
      controller: controller.headlineController,
      textCapitalization: TextCapitalization.sentences,
      autocorrect: true,
      textFieldKey: ValueKey('headline_field_$_identityId'),
    );
  }
}

class _GroupOffer extends ConsumerWidget {
  _GroupOffer(String identityId) : _identityId = identityId;

  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        publishOfferScreenControllerProvider(_identityId, context.l10n);
    final controller = ref.read(provider.notifier);
    final name = ref.watch(
      provider.select((state) => state.selectedIdentity?.card.firstName),
    );
    final isGroupOffer =
        ref.watch(provider.select((state) => state.formData.isGroupOffer));

    return FormRowToggle(
      switchKey: ValueKey('group_offer_switch_$_identityId'),
      icon: isGroupOffer ? Icons.group : Icons.person,
      iconColor: isGroupOffer
          ? context.colorScheme.primary
          : context.colorScheme.secondary,
      label: context.l10n.createGroupChatOffer,
      helperText: context.l10n.groupOfferHelperText,
      value: isGroupOffer,
      onChanged: (value) => controller.toggleGroupOffer(
        value,
        connectMessage:
            name != null ? context.l10n.connectWithFirstName(name) : '',
        chatGroupName:
            name != null ? context.l10n.firstNameChatGroup(name) : '',
      ),
    );
  }
}

class _OfferPhrase extends ConsumerWidget {
  _OfferPhrase(String identityId) : _identityId = identityId;

  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        publishOfferScreenControllerProvider(_identityId, context.l10n);
    final controller = ref.read(provider.notifier);

    final randomPhraseEnabled = ref.watch(
      provider.select((state) => state.formData.randomPhraseEnabled),
    );

    return Column(
      children: [
        FormRowToggle(
          switchKey: ValueKey('random_phrase_switch_$_identityId'),
          icon: Icons.key,
          iconColor: context.customColors.success,
          label: context.l10n.generateRandomPhraseHelperEnabled,
          helperText: randomPhraseEnabled
              ? context.l10n.generateRandomPhraseHelperEnabled
              : context.l10n.generateRandomPhraseHelperDisabled,
          value: randomPhraseEnabled,
          onChanged: controller.toggleRandomPhrase,
        ),
        if (!randomPhraseEnabled)
          Padding(
            padding: const EdgeInsets.only(left: 35),
            child: FormRowTextField(
              color: context.customColors.warning,
              label: context.l10n.customPhrase,
              placeholder: context.l10n.enterCustomPhrase,
              hint: context.l10n.customPhraseHelperText,
              controller: controller.customPhraseController,
              singleLine: true,
              suffixIcon: _PhraseValidationIcon(_identityId),
              textFieldKey: ValueKey('custom_phrase_field_$_identityId'),
            ),
          ),
      ],
    );
  }
}

class _Description extends ConsumerWidget {
  _Description(String identityId) : _identityId = identityId;

  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        publishOfferScreenControllerProvider(_identityId, context.l10n);
    final controller = ref.read(provider.notifier);

    return FormRowTextField(
      color: context.customColors.purple,
      label: context.l10n.description,
      icon: Icons.description,
      controller: controller.descriptionController,
      textCapitalization: TextCapitalization.sentences,
      autocorrect: true,
      textFieldKey: ValueKey('description_field_$_identityId'),
    );
  }
}
