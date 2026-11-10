import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../themes/tokens/mc_spacing.dart';

/// Mission Control's hairline grid: equal-weight items in rows of
/// [columns], ruled by one shared 1px line, the gap between cells, instead
/// of a border per cell that would double where cells meet.
///
/// Each row is as tall as its tallest cell. A short last row is filled with
/// empty cells, so the line never shows through as a block. Cells punch back
/// to the canvas on a [Material], so a child's ink paints on its cell.
class HairlineGrid extends StatelessWidget {
  const HairlineGrid({super.key, required this.columns, required this.children})
    : assert(columns > 0);

  final int columns;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;

    Widget cell(Widget child) => Expanded(
      child: Material(color: mc.canvas, child: child),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: mc.gridLine),
        borderRadius: BorderRadius.circular(McRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(McSpacing.hairline),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(McRadius.lg - McSpacing.hairline),
          child: ColoredBox(
            color: mc.gridLine,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: McSpacing.hairline,
              children: [
                for (var start = 0; start < children.length; start += columns)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: McSpacing.hairline,
                      children: [
                        for (var i = start; i < start + columns; i++)
                          cell(
                            i < children.length
                                ? children[i]
                                : const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
