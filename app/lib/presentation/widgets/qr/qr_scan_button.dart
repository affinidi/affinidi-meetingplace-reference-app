import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/services/camera_service/camera_service.dart';
import '../../dialogs/qr_code_picker/qr_code_picker.dart';

/// Opens the QR scanner and hands back what it read, or null when the
/// member closed it. Disabled while the device has no camera.
class QrScanButton extends ConsumerWidget {
  const QrScanButton({super.key, required this.onScanned});

  final void Function(String? data) onScanned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCameraAvailable = ref.watch(
      cameraServiceProvider.select((state) => state.isAvailable ?? false),
    );

    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.qr_code_scanner,
          size: 24,
          color: context.colorScheme.primary,
        ),
        onPressed: !isCameraAvailable
            ? null
            : () async {
                if (!context.mounted) return;

                final data = await QrCodePicker.show(context: context);
                onScanned(data);
              },
      ),
    );
  }
}
