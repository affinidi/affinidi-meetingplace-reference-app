import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../dialogs/qr_code_picker/qr_code_picker.dart';
import '../../../widgets/async_loaders/modal_async_loading_status.dart';
import '../../../widgets/qr/qr_scan_error_view.dart';
import 'oob_scan_qr_controller.dart';

class OOBScanQrScreen extends ConsumerWidget {
  const OOBScanQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = oobScanQrControllerProvider;
    final controller = ref.read(provider.notifier);
    final state = ref.watch(
      provider,
    );
    final isProcessing = state.isProcessing;
    final scannedCode = state.scannedCode;
    final errorMessage = state.errorMessage;

    final l10n = context.l10n;

    void onRetry() {
      controller.reset();
    }

    void onCancel() {
      if (!context.mounted) return;
      Navigator.of(context).pop();
    }

    return Scaffold(
      key: const Key('oob_scan_qr_screen_scaffold'),
      body: SafeArea(
        child: Column(
          children: [
            ModalAsyncLoadingStatus(
              controller.processOobQrLoadingController,
              loadingMessage: l10n.processing,
            ),
            Expanded(
              child: errorMessage != null
                  ? QrScanErrorView(
                      message: l10n.error(errorMessage),
                      onRetry: onRetry,
                      onCancel: onCancel,
                    )
                  : errorMessage == null && !isProcessing && scannedCode == null
                      ? QrCodePicker(
                          popOnDetect: false,
                          onDetectCode: (code) async {
                            if (isProcessing) return;
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
