part of 'publish_offer_screen.dart';

class _OfferBottomContainer extends ConsumerWidget {
  const _OfferBottomContainer(String identityId) : _identityId = identityId;

  final String _identityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider =
        publishOfferScreenControllerProvider(_identityId, context.l10n);
    final controller = ref.read(provider.notifier);
    final canPublish = ref.watch(provider.canPublish);

    Future<void> publishOffer() async {
      final formData = ref.read(provider).formData;
      await controller.publishOffer(formData: formData);
    }

    return Container(
      padding: const EdgeInsets.all(20.0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModalAsyncLoadingStatus(
              controller.publishOfferLoadingController,
              loadingMessage: context.l10n.publishing,
            ),
            ElevatedLoadingButton(
              onPressed: canPublish ? publishOffer : null,
              child: Text(
                context.l10n.publishToMeetingPlace,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
