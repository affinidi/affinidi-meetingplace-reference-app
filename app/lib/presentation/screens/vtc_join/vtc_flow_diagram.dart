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

/// Who passes what to whom in a step, inline and left to right: each of
/// [nodes] as a small icon beside its name, and between two of them what
/// passes, [links]`[i]` between `nodes[i]` and `nodes[i + 1]`, with an
/// arrow. Wraps onto a further line when it does not fit.
///
/// Only pictures the step's summary, which says the same in words, so
/// screen readers skip it.
class VtcFlowDiagram extends StatelessWidget {
  /// Creates a [VtcFlowDiagram]; [links] has one label fewer than [nodes].
  VtcFlowDiagram({super.key, required this.nodes, required this.links})
    : assert(links.length == nodes.length - 1);

  final List<VtcFlowNode> nodes;
  final List<String> links;

  static const _iconSize = 14.0;

  @override
  Widget build(BuildContext context) {
    final nodeStyle = context.textTheme.labelSmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
    final linkStyle = context.textTheme.labelSmall?.copyWith(
      color: Colors.white70,
    );

    return ExcludeSemantics(
      child: Wrap(
        spacing: 6,
        runSpacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final (index, node) in nodes.indexed) ...[
            if (index > 0) Text('${links[index - 1]} →', style: linkStyle),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 3,
              children: [
                Icon(node.icon, size: _iconSize, color: Colors.white),
                Flexible(
                  child: Text(
                    node.label,
                    style: nodeStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
