import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/providers/app_logger_provider.dart';
import '../../../infrastructure/services/permission_service/permission_service.dart';
import '../../widgets/camera_permission_instruction.dart';
import 'qr_code_picker_controller.dart';

class QrCodePicker extends ConsumerWidget {
  const QrCodePicker({super.key, this.onDetectCode, this.popOnDetect = true});

  /// Optional callback to receive detected code without popping the route
  final void Function(String code)? onDetectCode;

  /// If true (default), the picker will pop with the detected code
  final bool popOnDetect;
  static const _logKey = 'QrCodePicker';

  /// Show as full screen scanner
  ///
  /// Example:
  ///
  /// ```
  /// final code = await QrCodePicker.show(context: context);
  /// ```
  static Future<String?> show({
    required BuildContext context,
  }) =>
      Navigator.of(context, rootNavigator: true).push<String>(
        MaterialPageRoute<String>(
          builder: (context) => const QrCodePicker(),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logger = ref.read(appLoggerProvider);
    final l10n = context.l10n;

    final provider = qrCodePickerControllerProvider;
    final isCameraAvailable = ref.watch(
      provider.select((state) => state.isCameraAvailable),
    );

    if (isCameraAvailable == null) {
      logger.info('Detecting camera', name: _logKey);
      return const Scaffold(
        body: Center(
          child: CupertinoActivityIndicator(
            color: Colors.white,
            radius: 20,
          ),
        ),
      );
    }

    if (!isCameraAvailable) {
      logger.info('Camera not available', name: _logKey);
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.cameraNotAvailable,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: Text(
                  context.l10n.goBack,
                  style: TextStyle(
                    color: context.colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    logger.info('Found a camera', name: _logKey);

    return _QrPermissionView(
      onDetectCode: onDetectCode,
      popOnDetect: popOnDetect,
    );
  }
}

class _QrPermissionView extends ConsumerStatefulWidget {
  const _QrPermissionView({
    this.onDetectCode,
    required this.popOnDetect,
  });

  final void Function(String code)? onDetectCode;
  final bool popOnDetect;

  @override
  ConsumerState<_QrPermissionView> createState() => _QrPermissionViewState();
}

class _QrPermissionViewState extends ConsumerState<_QrPermissionView> {
  PermissionStatus? _status;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final service = ref.read(permissionServiceProvider);
    var status = await service.getCameraPermissionStatus();
    if (status.isDenied) {
      status = await service.requestCameraPermission();
    }
    setState(() {
      _status = status;
    });
  }

  Future<void> _retry() async {
    final service = ref.read(permissionServiceProvider);
    // Always attempt to (re)request permission on retry.
    var status = await service.requestCameraPermission();
    if (!status.isGranted) {
      status = await service.getCameraPermissionStatus();
    }
    setState(() {
      _status = status;
    });
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (_status == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    if (!_status!.isGranted) {
      return CameraPermissionInstruction(
        onOpenSettings: _openSettings,
        onRetry: _retry,
        onCancel: () {
          if (!context.mounted) return;
          Navigator.of(context).maybePop();
        },
      );
    }

    return _QRScannerScreen(
      onDetectCode: widget.onDetectCode,
      popOnDetect: widget.popOnDetect,
    );
  }
}

class _QRScannerScreen extends HookConsumerWidget {
  _QRScannerScreen({
    this.onDetectCode,
    required this.popOnDetect,
  });

  final void Function(String code)? onDetectCode;
  final bool popOnDetect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = qrCodePickerControllerProvider;
    final controller = ref.read(provider.notifier);
    final scaleFactor =
        ref.watch(provider.select((state) => state.scaleFactor));
    final hasScanned = useRef(false);

    void onCodeDetected(BarcodeCapture capture) async {
      if (hasScanned.value) return;

      final barcode = capture.barcodes
          .where((barcode) => barcode.rawValue != null)
          .firstOrNull;
      if (barcode?.rawValue == null) return;

      hasScanned.value = true;

      await controller.stopScanner();
      if (!context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final code = barcode!.rawValue!;
        if (onDetectCode != null && !popOnDetect) {
          onDetectCode!.call(code);
        } else {
          Navigator.of(context).pop(code);
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onScaleStart: (details) {
              controller.updateBaseScaleFactor(scaleFactor);
            },
            onScaleUpdate: (details) async {
              await controller.updateScaleFactor(details.scale);
            },
            child: MobileScanner(
              controller: controller.scannerController,
              onDetect: onCodeDetected,
            ),
          ),
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Color.fromARGB(100, 255, 255, 255),
              BlendMode.srcIn,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.only(right: 4, bottom: 4),
                height: 350,
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: context.colorScheme.surface,
                    ),
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: context.colorScheme.primary,
                      size: 70,
                    ),
                    onPressed: () {
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
