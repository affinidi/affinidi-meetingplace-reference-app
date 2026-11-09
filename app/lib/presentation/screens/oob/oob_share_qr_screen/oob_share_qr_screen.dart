import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/providers/qr_code_view_factory_provider.dart';
import '../../../themes/tokens/mc_icons.dart';
import '../../../widgets/async_loaders/inline_async_loading_status.dart';
import 'oob_share_qr_controller.dart';

class OOBShareQrScreen extends HookConsumerWidget {
  const OOBShareQrScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = oobShareQrControllerProvider;
    final controller = ref.read(provider.notifier);
    final qrData = ref.watch(provider.select((state) => state.qrData));
    final qrCodeViewFactory = ref.read(qrCodeViewFactoryProvider);

    final qrScannerTheme = context.qrScannerTheme;
    final mc = context.mcColors;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    Future<void> retry() async {
      if (!context.mounted) return;
      await controller.initialize();
    }

    void cancelOobFlow() async {
      if (!context.mounted) return;

      Navigator.of(context).pop();
    }

    void sendInvitation() async {
      if (!context.mounted || qrData == null) return;

      await controller.sendInvitation(
        context: context,
        title: l10n.meetingPlaceInvitationTitle,
      );
    }

    useEffect(() {
      if (!context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.initialize();
      });

      return null;
    }, []);

    return Scaffold(
      body: SafeArea(
        child: Column(
          spacing: 20,
          children: [
            Expanded(
              child: Center(
                child: InlineAsyncLoadingStatus(
                  controller.createOobLoadingController,
                  loadingMessage: l10n.generatingQrCode,
                  retry: retry,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          qrScannerTheme.defaultPadding * 2.5,
                          0,
                          qrScannerTheme.defaultPadding * 2.5,
                          qrScannerTheme.defaultPadding * 1.25,
                        ),
                        child: Center(
                          child: Text(
                            context.l10n.oobQrPresentInvitationMessage,
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge?.copyWith(
                              color: mc.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      if (qrData != null) qrCodeViewFactory.createView(qrData),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: sendInvitation,
                              child: Text(
                                l10n.shareSheetCTA_QRCode,
                                style: textTheme.titleLarge?.copyWith(
                                  color: mc.highlightSecondary,
                                  decoration: TextDecoration.underline,
                                  decorationColor: mc.highlightSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: mc.canvas),
                  icon: Icon(
                    McIcons.cancel,
                    color: mc.textSecondary,
                    size: qrScannerTheme.iconSize * 0.7,
                  ),
                  onPressed: cancelOobFlow,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
