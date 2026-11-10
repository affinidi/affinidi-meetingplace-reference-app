import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../themes/tokens/mc_spacing.dart';

/// One party in a [VtcFlowDiagram], such as this phone, the member's VTA or
/// the community, drawn as its [picture] where it has one, else its [icon].
class VtcFlowNode {
  /// Creates a [VtcFlowNode].
  const VtcFlowNode(this.icon, this.label, {this.picture});

  final IconData icon;
  final String label;

  /// A person's picture, drawn in the circle in place of [icon].
  final ImageProvider? picture;
}

/// Who takes part in a step, in the order things pass between them: each
/// of [nodes] as an icon, or a picture, in a circle over its name, an arrow
/// between each two, spread across the full width.
///
/// Only pictures the step's summary, which says the same in words, so
/// screen readers skip it.
class VtcFlowDiagram extends StatelessWidget {
  /// Creates a [VtcFlowDiagram].
  const VtcFlowDiagram({super.key, required this.nodes});

  final List<VtcFlowNode> nodes;

  static const _nodeSize = 28.0;
  static const _iconSize = 16.0;

  /// Room for a name such as "Community" in full, and for three parties on
  /// a narrow phone; the arrows between stretch to spread them across the
  /// full width.
  static const _nodeWidth = 72.0;
  static const _arrowHead = 8.0;

  @override
  Widget build(BuildContext context) {
    // Without the theme's letter spacing, which cut "Community" short.
    final mc = context.mcColors;
    final labelStyle = context.textTheme.labelSmall?.copyWith(
      color: mc.textSecondary,
      letterSpacing: 0,
    );

    return ExcludeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, node) in nodes.indexed) ...[
            if (index > 0)
              Expanded(
                child: SizedBox(
                  height: _nodeSize,
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: mc.hairlineStrong,
                          height: _nodeSize,
                        ),
                      ),
                      Icon(
                        McIcons.chevronRight,
                        size: _arrowHead,
                        color: mc.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(
              width: _nodeWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: McSpacing.s05,
                children: [
                  Container(
                    width: _nodeSize,
                    height: _nodeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colorScheme.surfaceContainerHigh,
                      border: Border.all(color: mc.hairlineStrong),
                      image: switch (node.picture) {
                        final picture? => DecorationImage(
                          image: picture,
                          fit: BoxFit.cover,
                        ),
                        null => null,
                      },
                    ),
                    child: node.picture == null
                        ? Icon(
                            node.icon,
                            size: _iconSize,
                            color: mc.textPrimary,
                          )
                        : null,
                  ),
                  Text(
                    node.label,
                    style: labelStyle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A [flow] in a hairline box, with its [summary] in words under it.
class VtcFlowBox extends StatelessWidget {
  /// Creates a [VtcFlowBox].
  const VtcFlowBox({super.key, required this.flow, required this.summary});

  final Widget flow;
  final Widget summary;

  static const _padding = McSpacing.s2;

  @override
  Widget build(BuildContext context) {
    return Container(
      // The hairline border takes its width from the padding, so the
      // content keeps its size.
      padding: const EdgeInsets.all(_padding - McSpacing.hairline),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(McRadius.md),
        border: Border.all(color: context.mcColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: _padding,
        children: [flow, summary],
      ),
    );
  }
}
