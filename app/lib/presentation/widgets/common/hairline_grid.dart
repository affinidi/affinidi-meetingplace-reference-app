import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_spacing.dart';

/// Mission Control's hairline grid: equal-weight items in rows of
/// [columns], ruled by one shared 1px line between them instead of a border
/// per cell that would double where cells meet.
///
/// The grid is open: no outer edge, and a line only where it separates two
/// items, so a short last row leaves its empty slots blank and a single item
/// draws no line at all. Each row is as tall as its tallest cell. Cells sit
/// on a transparent [Material], so a child's ink paints on its cell.
class HairlineGrid extends StatelessWidget {
  const HairlineGrid({super.key, required this.columns, required this.children})
    : assert(columns > 0);

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final line = ColoredBox(
      color: context.mcColors.gridLine,
      child: const SizedBox.square(dimension: McSpacing.hairline),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var start = 0; start < children.length; start += columns) ...[
          if (start > 0) line,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = start; i < start + columns; i++) ...[
                  if (i > start && i < children.length) line,
                  Expanded(
                    child: i < children.length
                        ? Material(
                            type: MaterialType.transparency,
                            child: children[i],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
