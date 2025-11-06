import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/connections_service/connections_service.dart';
import '../../../../application/services/identities_service/identities_service.dart';
import '../../../widgets/async_loaders/async_loading_controller.dart';
import 'find_offer_screen_state.dart';

part 'find_offer_screen_controller.g.dart';

@riverpod
class FindOfferScreenController extends _$FindOfferScreenController {
  late final findOfferLoadingController =
      AsyncLoadingController.provider('findOfferLoadingController');

  @override
  FindOfferScreenState build() {
    return FindOfferScreenState();
  }

  void initialize() {
    final preselectedIdentity =
        ref.read(identitiesServiceProvider.currentIdentityOrPrimary);

    state = state.copyWith(identity: preselectedIdentity);
  }

  Future<void> findOffer(String mnemonic) async {
    await ref.read(connectionsServiceProvider.notifier).findOffer(mnemonic);
  }
}
