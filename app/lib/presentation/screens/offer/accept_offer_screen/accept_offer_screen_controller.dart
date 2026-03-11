import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/connections_service/connections_service.dart';
import '../../../../application/services/identities_service/identities_service.dart';
import '../../../../domain/models/identity/identity.dart';
import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../../navigation/navigator.dart';
import '../../../../navigation/routes/dashboard_routes.dart';
import '../../../widgets/async_loaders/async_loading_controller.dart';
import 'accept_offer_screen_state.dart';

part 'accept_offer_screen_controller.g.dart';

@riverpod
class AcceptOfferScreenController extends _$AcceptOfferScreenController {
  late final acceptOfferLoadingController = AsyncLoadingController.provider(
    'acceptOfferLoadingController',
  );

  @override
  AcceptOfferScreenState build(String mnemonic) {
    ref.listen(
      connectionsServiceProvider.select((state) => state.selectedOffer),
      (previous, next) {
        if (next != null && next != previous) {
          Future.microtask(() {
            state = state.copyWith(offer: next);
          });
        }
      },
      fireImmediately: true,
    );

    ref.listen(
      identitiesServiceProvider.select((state) => state.identities),
      (previous, next) {
        Future.microtask(() {
          state = state.copyWith(identities: next);
        });
      },
      fireImmediately: true,
    );

    return AcceptOfferScreenState();
  }

  void initialize(String identityId) {
    ref.read(connectionsServiceProvider.notifier).getOffer(mnemonic);

    final identities = ref.read(identitiesServiceProvider).identities;
    final preselectedIdentity = identities.firstWhere(
      (identity) => identity.id == identityId,
      orElse: () =>
          ref.read(identitiesServiceProvider.currentIdentityOrPrimary)!,
    );

    state = state.copyWith(selectedIdentity: preselectedIdentity);
  }

  Future<void> clearSelectedOffer() async {
    state = state.copyWith(offer: null);
  }

  Future<void> acceptOffer() async {
    await ref.read(acceptOfferLoadingController.notifier).start(() async {
      final offer = state.offer;
      if (offer == null) {
        throw AppException(
          'Offer is missing, make sure to select an offer first',
          code: AppExceptionType.missingConnectionOffer.name,
        );
      }

      final selectedIdentity = state.selectedIdentity;
      if (selectedIdentity == null) {
        throw AppException(
          'You must select an identity',
          code: AppExceptionType.missingIdentity.name,
        );
      }

      await ref
          .read(connectionsServiceProvider.notifier)
          .acceptOffer(offer, identity: selectedIdentity);
      await Future(() {
        ref.read(navigatorProvider).go(const ConnectionsRoute().location);
      });
    });
  }

  void selectIdentity(Identity identity) {
    state = state.copyWith(selectedIdentity: identity);
  }
}
