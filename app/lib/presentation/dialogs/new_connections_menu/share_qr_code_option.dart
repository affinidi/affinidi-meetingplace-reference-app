import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/menu_option_tile.dart';
import 'new_connections_menu_option.dart';

class ShareQRCodeOption extends ConsumerWidget {
  static const _shareQRCodeOption = NewConnectionsMenuOption.shareQRCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return MenuOptionTile(
      assetName: _shareQRCodeOption.assetName,
      title: l10n.newConnectionOptionTitle(_shareQRCodeOption.name),
      subtitle: l10n.newConnectionOptionSubtitle(_shareQRCodeOption.name),
      onTap: () {
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pop(_shareQRCodeOption);
      },
    );
  }
}
