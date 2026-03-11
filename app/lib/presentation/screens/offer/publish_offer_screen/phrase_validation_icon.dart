part of 'publish_offer_screen.dart';

class _PhraseValidationIcon extends ConsumerWidget {
  const _PhraseValidationIcon(String identityId) : _identityId = identityId;

  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = publishOfferScreenControllerProvider(
      _identityId,
      context.l10n,
    );

    final isPhraseAvailable = ref.watch(
      provider.select((state) => state.formData.isPhraseAvailable),
    );
    final isPhraseValidating = ref.watch(
      provider.select((state) => state.formData.isPhraseValidating),
    );
    final randomPhraseEnabled = ref.watch(
      provider.select((state) => state.formData.randomPhraseEnabled),
    );
    final customPhrase = ref.watch(
      provider.select((state) => state.formData.customPhrase),
    );

    if (randomPhraseEnabled ||
        customPhrase == null ||
        customPhrase.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    if (isPhraseValidating) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      );
    }

    if (isPhraseAvailable == true) {
      return Icon(
        Icons.check_circle,
        color: context.customColors.success,
        size: 20,
      );
    }

    if (isPhraseAvailable == false) {
      return Icon(Icons.cancel, color: context.colorScheme.error, size: 20);
    }

    return const SizedBox.shrink();
  }
}
