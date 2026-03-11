import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../widgets/bottom_sheet_menu.dart';

class MaxUsagePickerMenu extends StatelessWidget {
  const MaxUsagePickerMenu({
    super.key,
    required this.maxValue,
    required this.currentValue,
  });

  static Future<int?> show({
    required BuildContext context,
    required int currentValue,
    required int maxValue,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: context.colorScheme.inverseSurface,
      builder: (context) {
        return MaxUsagePickerMenu(
          maxValue: maxValue,
          currentValue: currentValue,
        );
      },
    );
  }

  final int maxValue;
  final int currentValue;

  @override
  Widget build(BuildContext context) {
    return BottomSheetMenu(
      itemCount: maxValue,
      itemBuilder: (context, index) {
        final value = index + 1;
        final isSelected = value == currentValue;
        return ListTile(
          title: Center(child: Text('$value')),
          selected: isSelected,
          onTap: () => Navigator.pop(context, value),
        );
      },
    );
  }
}
