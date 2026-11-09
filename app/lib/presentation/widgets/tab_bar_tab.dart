import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../themes/tokens/mc_radius.dart';

class TabBarTab extends StatelessWidget {
  const TabBarTab({super.key, required this.label});
  final String label;

  static const double _tabBarMinimumWidth = 70;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Tab(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(minWidth: _tabBarMinimumWidth),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(McRadius.md),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
