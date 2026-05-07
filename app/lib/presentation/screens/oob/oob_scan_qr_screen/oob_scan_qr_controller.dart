import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../application/services/oob_service/oob_service.dart';
import '../../../../infrastructure/configuration/environment.dart';
import '../../../../infrastructure/exceptions/app_exception.dart';
import '../../../../infrastructure/extensions/contact_card_extensions.dart';
import '../../../../infrastructure/providers/app_logger_provider.dart';
import '../../../../navigation/navigator.dart';
import '../../../widgets/async_loaders/async_loading_controller.dart';
import 'oob_scan_qr_state.dart';

part 'oob_scan_qr_controller.g.dart';

@riverpod
class OobScanQrController extends _$OobScanQrController {
  OobScanQrController() : super();

  late final processOobQrLoadingController = AsyncLoadingController.provider(
    'processOobQrLoadingController',
  );
  final logKey = 'OOBSCANQR';

  @override
  OobScanQrState build() {
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
          logger.info('User canceled OOB flow', name: logKey);
        }
      },
      fireImmediately: true,
    );
    return OobScanQrState();
  }

  Future<void> processScannedQRCode(String qrData) async {
    try {
      state = state.copyWith(isProcessing: true, scannedCode: qrData);
      await ref.read(processOobQrLoadingController.notifier).start(() async {
        try {
          await ref
              .read(oOBServiceProvider.notifier)
              .acceptOobFlow(
                qrData,
                type: ref.read(environmentProvider).directInteractiveOobType,
              );
        } on AppException catch (e) {
          state = state.copyWith(errorMessage: e.code);
        } catch (e) {
          final logger = ref.read(appLoggerProvider);
          logger.error(
            '''Error processing OOB QR code: ${e.toString()}''',
            name: logKey,
          );
          state = state.copyWith(errorMessage: e.toString());
        }
      });
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  void reset() {
    state = state.copyWith(
      isProcessing: false,
      errorMessage: null,
      scannedCode: null,
    );
  }
}
