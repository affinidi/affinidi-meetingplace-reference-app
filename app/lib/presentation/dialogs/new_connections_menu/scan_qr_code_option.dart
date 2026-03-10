import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/services/camera_service/camera_service.dart';
import '../../widgets/menu_option_tile.dart';
import 'new_connections_menu_option.dart';

class ScanQRCodeOption extends ConsumerWidget {
  static const _scanQRCodeOption = NewConnectionsMenuOption.scanQRCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    final isCameraAvailable = ref.watch(
      cameraServiceProvider.select((state) => state.isAvailable),
    );
    log('CameraAvailable: $isCameraAvailable', name: 'ScanQRCodeOption');

    return MenuOptionTile(
      enabled: isCameraAvailable ?? false,
      assetName: _scanQRCodeOption.assetName,
      title: l10n.newConnectionOptionTitle(_scanQRCodeOption.name),
      subtitle: l10n.newConnectionOptionSubtitle(_scanQRCodeOption.name),
      warning: isCameraAvailable == false ? l10n.unableToDetectCamera : null,
      onTap: () {
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pop(_scanQRCodeOption);
      },
    );
  }
}
