import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';

/// One party in a [VtcFlowDiagram], such as this phone, the member's VTA or
/// the community.
class VtcFlowNode {
  /// Creates a [VtcFlowNode].
  const VtcFlowNode(this.icon, this.label);

  final IconData icon;
  final String label;
}

/// Who takes part in a step, in the order things pass between them: each
/// of [nodes] as an icon in a circle over its name, an arrow between each
/// two, spread across the full width.
///
/// Only pictures the step's summary, which says the same in words, so
/// screen readers skip it.
class VtcFlowDiagram extends StatelessWidget {
  /// Creates a [VtcFlowDiagram].
  const VtcFlowDiagram({super.key, required this.nodes});

  final List<VtcFlowNode> nodes;

  static const _nodeSize = 22.0;

  /// Room for a name such as "Community" in full, and for three parties on
  /// a narrow phone; the arrows between stretch to spread them across the
  /// full width.
  static const _nodeWidth = 64.0;
  static const _arrowHead = 8.0;

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.textTheme.labelSmall?.copyWith(
      color: Colors.white,
    );

    return ExcludeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, node) in nodes.indexed) ...[
            if (index > 0)
              const Expanded(
                child: SizedBox(
                  height: _nodeSize,
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.white54,
                          height: _nodeSize,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: _arrowHead,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(
              width: _nodeWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  Container(
                    width: _nodeSize,
                    height: _nodeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(25),
                      border: Border.all(color: Colors.white54),
                    ),
                    child: Icon(node.icon, size: 12, color: Colors.white),
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

/// A [flow] in a tinted box, with its [summary] in words under it.
class VtcFlowBox extends StatelessWidget {
  /// Creates a [VtcFlowBox].
  const VtcFlowBox({super.key, required this.flow, required this.summary});

  final Widget flow;
  final Widget summary;

  static const _padding = 10.0;
  static const _radius = 12.0;
  static const _tint = 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(_tint),
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: _padding,
        children: [flow, summary],
      ),
    );
  }
}
