import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/connections_service/connections_service.dart';
import '../../../../application/services/identities_service/identities_service.dart';
import '../../../../domain/models/identity/identity.dart';
import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/exceptions/app_exception_type.dart';
import '../../../../navigation/navigator.dart';
import '../../../../navigation/routes/dashboard_routes.dart';
import '../../../widgets/snack_bars/error_snack_bar_controller.dart';
import 'accept_offer_screen_state.dart';

part 'accept_offer_screen_controller.g.dart';

@riverpod
class AcceptOfferScreenController extends _$AcceptOfferScreenController {
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
    final errorSnackBarController = ref.read(errorSnackBarControllerProvider);
    final offer = state.offer;
    if (offer == null) {
      errorSnackBarController.show(
        AppException(
          'Offer is missing, make sure to select an offer first',
          code: AppExceptionType.missingConnectionOffer.name,
        ),
        StackTrace.current,
      );
      return;
    }

    final selectedIdentity = state.selectedIdentity;
    if (selectedIdentity == null) {
      errorSnackBarController.show(
        AppException(
          'You must select an identity',
          code: AppExceptionType.missingIdentity.name,
        ),
        StackTrace.current,
      );
      return;
    }

    final connectionsService = ref.read(connectionsServiceProvider.notifier);
    final navigator = ref.read(navigatorProvider);
    final acceptance = connectionsService.acceptOffer(
      offer,
      identity: selectedIdentity,
    );

    navigator.go(const ConnectionsRoute().location);

    unawaited(
      _completeAcceptance(
        acceptance: acceptance,
        errorSnackBarController: errorSnackBarController,
      ),
    );
  }

  Future<void> _completeAcceptance({
    required Future<void> acceptance,
    required ErrorSnackBarController errorSnackBarController,
  }) async {
    try {
      await acceptance;
    } catch (error, stackTrace) {
      errorSnackBarController.show(error, stackTrace);
    }
  }

  void selectIdentity(Identity identity) {
    state = state.copyWith(selectedIdentity: identity);
  }
}
