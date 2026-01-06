import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../dialogs/qr_code_picker/qr_code_picker.dart';
import '../../../widgets/async_loaders/modal_async_loading_status.dart';
import 'oob_scan_qr_controller.dart';

class OOBScanQrScreen extends ConsumerWidget {
  const OOBScanQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = oobScanQrControllerProvider;
    final controller = ref.read(oobScanQrControllerProvider.notifier);
    final state = ref.watch(provider);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ModalAsyncLoadingStatus(
              controller.processOobQrLoadingController,
              loadingMessage: l10n.processing,
            ),
            Expanded(
              child: !state.isProcessing
                  ? QrCodePicker(
                      popOnDetect: false,
                      onDetectCode: (code) async {
                        if (state.isProcessing) return;
                        await controller.processScannedQRCode(code);
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
