import 'package:flutter/material.dart';

import '../themes/tokens/mc_spacing.dart';

/// A row of filters, as a Mission Control row of siblings: plain labels,
/// muted at rest and bright when selected, the selected one marked by the
/// theme's 2px signal line along a faint line across the row.
class FilterTabBar extends StatelessWidget {
  const FilterTabBar({
    super.key,
    required this.controller,
    required this.labels,
    this.onSelected,
  });

  final TabController controller;
  final List<String> labels;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      // The first label lines up with the page's 16px gutter.
      padding: const EdgeInsets.symmetric(horizontal: McSpacing.s1),
      labelPadding: const EdgeInsets.symmetric(horizontal: McSpacing.s3),
      onTap: onSelected,
      tabs: [for (final label in labels) Tab(text: label)],
    );
  }
}
