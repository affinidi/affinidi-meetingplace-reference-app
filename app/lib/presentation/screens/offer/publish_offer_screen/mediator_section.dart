part of 'publish_offer_screen.dart';

class _MediatorSection extends ConsumerWidget {
  const _MediatorSection(String identityId) : _identityId = identityId;

  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = publishOfferScreenControllerProvider(
      _identityId,
      context.l10n,
    );
    final availableMediators = ref.watch(
      provider.select((state) => state.availableMediators),
    );

    final controller = ref.read(provider.notifier);

    final selectedMediatorName = ref.watch(
      provider.select((state) => state.formData.selectedMediatorName),
    );

    Future<void> selectMediator() async {
      if (!context.mounted) return;
      final selectedMediator = await MediatorPickerMenu.show(
        context: context,
        currentId: ref.read(provider).formData.selectedMediatorDid,
        mediators: availableMediators,
      );

      if (selectedMediator != null) {
        await controller.updateMediatorConfig(selectedMediator);
      }
    }

    return FormCard(
      title: context.l10n.mediator,
      child: Column(
        children: [
          FormRowPicker(
            icon: Icons.mediation_rounded,
            iconColor: context.customColors.violet,
            label: selectedMediatorName ?? '',
            helperText: context.l10n.mediatorHelperText,
            buttonText: context.l10n.changeButton,
            onPressed: selectMediator,
          ),
        ],
      ),
    );
  }
}
