import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../infrastructure/services/camera_service/camera_service.dart';
import '../../../infrastructure/services/permission_service/permission_service.dart';
import '../../widgets/camera_permission_instruction.dart';
import 'qr_code_picker_controller.dart';

class QrCodePicker extends ConsumerWidget {
  const QrCodePicker({super.key, this.onDetectCode, this.popOnDetect = true});

  /// Optional callback to receive detected code without popping the route
  final void Function(String code)? onDetectCode;

  /// If true (default), the picker will pop with the detected code
  final bool popOnDetect;

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
    final provider = qrCodePickerControllerProvider;
    final isCameraAvailable =
        ref.watch(cameraServiceProvider.select((state) => state.isAvailable));
    final controller = ref.watch(provider.notifier);

    if (isCameraAvailable == null) {
      log('Detecting camera', name: 'QrCodePicker');
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CupertinoActivityIndicator(
            color: Colors.white,
            radius: 20,
          ),
        ),
      );
    }

    if (!isCameraAvailable) {
      log('Camera not available', name: 'QrCodePicker');
      return Scaffold(
        backgroundColor: Colors.black,
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
              const Text(
                'Camera not available',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Go Back',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    log('Found a camera', name: 'QrCodePicker');

    return _QrPermissionView(
      controller: controller,
      onDetectCode: onDetectCode,
      popOnDetect: popOnDetect,
    );
  }
}

class _QrPermissionView extends ConsumerStatefulWidget {
  const _QrPermissionView({
    required this.controller,
    this.onDetectCode,
    required this.popOnDetect,
  });

  final QrCodePickerController controller;
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
      // If still not granted (e.g. permanently denied), reflect latest status.
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
          child: CupertinoActivityIndicator(
            color: Colors.white,
            radius: 20,
          ),
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
      controller: widget.controller,
      onDetectCode: widget.onDetectCode,
      popOnDetect: widget.popOnDetect,
    );
  }
}

class _QRScannerScreen extends StatefulWidget {
  const _QRScannerScreen({
    required this.controller,
    this.onDetectCode,
    required this.popOnDetect,
  });

  final QrCodePickerController controller;
  final void Function(String code)? onDetectCode;
  final bool popOnDetect;

  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  bool _hasScanned = false;
  bool _isProcessing = false;
  Timer? _timer;
  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onCodeDetected(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes
        .where((barcode) => barcode.rawValue != null)
        .firstOrNull;
    if (barcode?.rawValue == null) return;

    _hasScanned = true;
    setState(() {
      _isProcessing = true;
    });

    _timer = Timer(const Duration(milliseconds: 500), () async {
      await widget.controller.scannerController.stop();
      if (!mounted) return;

      final code = barcode!.rawValue!;
      if (widget.onDetectCode != null && !widget.popOnDetect) {
        widget.onDetectCode!.call(code);
      } else {
        Navigator.of(context).pop(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onScaleStart: (details) {
              _baseScaleFactor = _scaleFactor;
            },
            onScaleUpdate: (details) {
              setState(() {
                _scaleFactor = _baseScaleFactor * details.scale;
                widget.controller.scannerController.setZoomScale(_scaleFactor);
              });
            },
            child: !_isProcessing
                ? MobileScanner(
                    controller: widget.controller.scannerController,
                    onDetect: _onCodeDetected,
                  )
                : Container(color: Colors.black),
          ),
          if (!_isProcessing)
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(100, 255, 255, 255),
                BlendMode.srcIn,
              ),
              child: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
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
            ),
          if (_isProcessing)
            const Opacity(
              opacity: 1,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isProcessing)
            const Align(
              alignment: Alignment.center,
              child: CupertinoActivityIndicator(
                color: Colors.white,
                radius: 20,
              ),
            ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      color: Color.fromARGB(249, 3, 104, 192),
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
