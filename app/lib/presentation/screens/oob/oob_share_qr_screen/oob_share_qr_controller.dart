import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/oob_service/oob_service.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../../navigation/navigator.dart';
import '../../../widgets/async_loaders/async_loading_controller.dart';
import 'oob_share_qr_state.dart';

part 'oob_share_qr_controller.g.dart';

@riverpod
class OobShareQrController extends _$OobShareQrController {
  OobShareQrController() : super();

  late final createOobLoadingController =
      AsyncLoadingController.provider('createOobLoadingController');
  final logKey = 'OOBSHAREQR';

  @override
  OobShareQrState build() {
    final logger = ref.read(appLoggerProvider);
    ref.listen(
      oOBServiceProvider.select((state) => state.lastConnectionChannel),
      (prev, next) {
        if (next != null) {
          logger.info(
            '''Channel received for contact ${next.otherPartyContactCard?.firstName}''',
            name: logKey,
          );
          Future(() {
            ref.read(navigatorProvider).pop(next);
          });
        } else {
          logger.info(
            'User canceled OOB flow',
            name: logKey,
          );
        }
      },
      fireImmediately: true,
    );

    return OobShareQrState();
  }

  Future<void> initialize() async {
    await ref.read(createOobLoadingController.notifier).start(() async {
      state = state.copyWith(qrData: null);
      final oobService = ref.read(oOBServiceProvider.notifier);
      final offerLink = await oobService.createOobFlow();
      state = state.copyWith(qrData: offerLink);
    });
  }
}
