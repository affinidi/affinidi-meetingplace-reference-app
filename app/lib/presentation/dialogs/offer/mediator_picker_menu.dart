import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/bottom_sheet_menu.dart';

class MediatorPickerMenu extends HookConsumerWidget {
  const MediatorPickerMenu({
    super.key,
    this.currentId,
    required this.mediators,
  });

  final String? currentId;
  final Map<String, String> mediators;

  static Future<String?> show({
    required BuildContext context,
    required String? currentId,
    required Map<String, String> mediators,
  }) {
    return showModalBottomSheet<String>(
      backgroundColor: context.colorScheme.inverseSurface,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      context: context,
      builder: (context) => MediatorPickerMenu(
        currentId: currentId,
        mediators: mediators,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomSheetMenu(
      header: context.l10n.selectMediator,
      itemCount: mediators.length,
      itemBuilder: (context, index) {
        final entry = mediators.entries.elementAt(index);
        final friendlyName = entry.key;
        final did = entry.value;
        final isSelected = did == currentId;
        return ListTile(
          leading: isSelected
              ? Icon(Icons.check_circle,
                  color: context.listTileTheme.selectedColor)
              : Icon(Icons.circle_outlined,
                  color: context.listTileTheme.iconColor),
          title: Text(
            friendlyName,
          ),
          onTap: () {
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop(did);
          },
          selected: isSelected,
        );
      },
    );
  }
}
