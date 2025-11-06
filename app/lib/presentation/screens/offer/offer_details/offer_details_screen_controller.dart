import 'package:meeting_place_core/meeting_place_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/connections_service/connections_service.dart';
import '../../../../application/services/identities_service/identities_service.dart';
import '../../../../application/services/settings_service/settings_service.dart';
import '../../../widgets/async_loaders/async_loading_controller.dart';
import 'offer_details_screen_state.dart';

part 'offer_details_screen_controller.g.dart';

@riverpod
class OfferDetailsScreenController extends _$OfferDetailsScreenController {
  late final offerLoadingController =
      AsyncLoadingController.provider('offerLoadingController');
  late final deleteOfferLoadingController =
      AsyncLoadingController.provider('deleteOfferLoadingController');

  @override
  OfferDetailsScreenState build(String offerLink) {
    return OfferDetailsScreenState();
  }

  void initialize() {
    final offer = ref
        .read(connectionsServiceProvider)
        .getConnectionByOfferLink(offerLink);
    final publisher =
        ref.read(identitiesServiceProvider).getIdentityById(offer?.externalRef);
    final isPrimary = publisher?.isPrimary ?? false;
    final settings = ref.read(settingsServiceProvider);

    state = state.copyWith(
      offer: offer,
      publisherIdentity: publisher,
      isUsingPrimaryIdentity: isPrimary,
      groupDid: (offer is GroupConnectionOffer) ? offer.groupDid : null,
      isDebugMode: settings.isDebugMode,
      showQrIcon: settings.shouldShowMeetingPlaceQR,
    );
  }

  Future<void> refreshConnections() async {
    await ref.read(offerLoadingController.notifier).start(() async {
      await ref.read(connectionsServiceProvider.notifier).fetchConnections();
    });
  }

  Future<void> deleteConnection() async {
    final offer = state.offer;
    if (offer == null) return;

    await ref.read(deleteOfferLoadingController.notifier).start(() async {
      await ref
          .read(connectionsServiceProvider.notifier)
          .markConnectionOfferAsDeleted(offer);
      await ref.read(connectionsServiceProvider.notifier).fetchConnections();
    });
  }

  Future<void> toggleShowQrView() async {
    state = state.copyWith(showQrView: !state.showQrView);
  }
}
