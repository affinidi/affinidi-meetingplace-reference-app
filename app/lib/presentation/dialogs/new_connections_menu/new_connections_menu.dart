import 'package:flutter/material.dart';
import 'package:meeting_place_core/meeting_place_core.dart';

import '../../../domain/models/identity/identity.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../navigation/routes/dashboard_routes.dart';
import '../../widgets/bottom_sheet_menu.dart';
import '../../widgets/connection_success_bottom_sheet.dart';
import '../../widgets/menu_option_tile.dart';
import 'new_connections_menu_option.dart';
import 'scan_qr_code_option.dart';
import 'share_qr_code_option.dart';

class NewConnectionsMenu extends StatelessWidget {
  const NewConnectionsMenu({super.key, this.currentIdentity});

  final Identity? currentIdentity;

  /// Example:
  ///
  /// ```
  /// final selection = await NewConnectionsMenu.show(context: context);
  /// ```
  static Future<NewConnectionsMenuOption?> show({
    required BuildContext context,
    Identity? currentIdentity,
  }) =>
      showModalBottomSheet<NewConnectionsMenuOption>(
        backgroundColor: context.colorScheme.inverseSurface,
        useRootNavigator: true,
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        context: context,
        builder: (context) =>
            NewConnectionsMenu(currentIdentity: currentIdentity),
      );

  static void _showConnectionSuccessBottomSheet(
      BuildContext context, Channel channel) {
    if (!context.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ConnectionSuccessBottomSheet.show(
        context: context,
        channel: channel,
      );
    });
  }

  static Future<void> _oobScanQrCode({
    required BuildContext context,
  }) async {
    final channel = await const OOBScanQrRoute().push<Channel>(context);
    if (channel == null) return;

    _showConnectionSuccessBottomSheet(context, channel);
  }

  static Future<void> _oobShareQrCode({
    required BuildContext context,
  }) async {
    final channel = await const OOBShareQrRoute().push<Channel>(context);
    if (channel == null) return;

    _showConnectionSuccessBottomSheet(context, channel);
  }

  static Future<void> onSelectOption({
    required BuildContext context,
    Identity? currentIdentity,
  }) async {
    if (!context.mounted) return;

    final selection = await NewConnectionsMenu.show(
      context: context,
      currentIdentity: currentIdentity,
    );
    if (selection == null) return;

    switch (selection) {
      case NewConnectionsMenuOption.shareQRCode:
        await _oobShareQrCode(context: context);
        break;
      case NewConnectionsMenuOption.scanQRCode:
        await _oobScanQrCode(context: context);
        break;
      case NewConnectionsMenuOption.claimAnOffer:
        await const FindOfferRoute().push<void>(context);
        break;
      case NewConnectionsMenuOption.publishAnOffer:
        await PublishOfferRoute(identityId: currentIdentity?.id ?? '')
            .push<void>(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetMenu(
      header: context.l10n.newConnectionsOptionsHeader,
      itemCount: 4,
      itemBuilder: (context, index) {
        switch (index) {
          case 0:
            return ShareQRCodeOption();
          case 1:
            return ScanQRCodeOption();
          case 2:
            return MenuOptionTile(
              assetName: NewConnectionsMenuOption.claimAnOffer.assetName,
              title: context.l10n.newConnectionOptionTitle(
                NewConnectionsMenuOption.claimAnOffer.name,
              ),
              subtitle: context.l10n.newConnectionOptionSubtitle(
                NewConnectionsMenuOption.claimAnOffer.name,
              ),
              onTap: () {
                if (!context.mounted) return;
                Navigator.of(context, rootNavigator: true)
                    .pop(NewConnectionsMenuOption.claimAnOffer);
              },
            );
          case 3:
            return MenuOptionTile(
              assetName: NewConnectionsMenuOption.publishAnOffer.assetName,
              title: context.l10n.newConnectionOptionTitle(
                NewConnectionsMenuOption.publishAnOffer.name,
              ),
              subtitle: context.l10n.newConnectionOptionSubtitle(
                NewConnectionsMenuOption.publishAnOffer.name,
              ),
              onTap: () {
                if (!context.mounted) return;
                Navigator.of(context, rootNavigator: true)
                    .pop(NewConnectionsMenuOption.publishAnOffer);
              },
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}
