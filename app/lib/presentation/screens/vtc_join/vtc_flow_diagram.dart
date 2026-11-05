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

/// Who passes what to whom in a step, drawn left to right: each of [nodes]
/// as an icon over its name, and between two of them an arrow under what
/// passes, [links]`[i]` between `nodes[i]` and `nodes[i + 1]`.
///
/// Only pictures the step's summary, which says the same in words, so
/// screen readers skip it.
class VtcFlowDiagram extends StatelessWidget {
  /// Creates a [VtcFlowDiagram]; [links] has one label fewer than [nodes].
  VtcFlowDiagram({super.key, required this.nodes, required this.links})
    : assert(links.length == nodes.length - 1);

  final List<VtcFlowNode> nodes;
  final List<String> links;

  static const _nodeSize = 32.0;

  /// How the width is shared: each party a little more than each arrow,
  /// so both fit a narrow phone and grow on a wide one.
  static const _nodeFlex = 4;
  static const _linkFlex = 3;
  static const _arrowHeight = 10.0;

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.textTheme.labelSmall?.copyWith(
      color: Colors.white,
    );
    final linkStyle = context.textTheme.labelSmall?.copyWith(
      color: Colors.white70,
    );

    return ExcludeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, node) in nodes.indexed) ...[
            if (index > 0)
              Expanded(
                flex: _linkFlex,
                // The arrow level with the icons' middles, what passes
                // under it.
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: (_nodeSize - _arrowHeight) / 2,
                  ),
                  child: Column(
                    spacing: 2,
                    children: [
                      const SizedBox(
                        height: _arrowHeight,
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white54,
                                height: _arrowHeight,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: _arrowHeight,
                              color: Colors.white54,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        links[index - 1],
                        style: linkStyle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              flex: _nodeFlex,
              child: Column(
                spacing: 4,
                children: [
                  Container(
                    width: _nodeSize,
                    height: _nodeSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(25),
                      border: Border.all(color: Colors.white54),
                    ),
                    child: Icon(node.icon, size: 16, color: Colors.white),
                  ),
                  Text(
                    node.label,
                    style: labelStyle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
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
