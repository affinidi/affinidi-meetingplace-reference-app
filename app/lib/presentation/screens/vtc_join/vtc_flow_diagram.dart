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
/// two, all centred.
///
/// Only pictures the step's summary, which says the same in words, so
/// screen readers skip it.
class VtcFlowDiagram extends StatelessWidget {
  /// Creates a [VtcFlowDiagram].
  const VtcFlowDiagram({super.key, required this.nodes});

  final List<VtcFlowNode> nodes;

  static const _nodeSize = 22.0;

  /// Three parties and two arrows fit the trail on a narrow phone.
  static const _nodeWidth = 60.0;
  static const _arrowWidth = 24.0;
  static const _arrowSize = 10.0;

  @override
  Widget build(BuildContext context) {
    final labelStyle = context.textTheme.labelSmall?.copyWith(
      color: Colors.white,
    );

    return ExcludeSemantics(
      // As tall as the diagram, however much height it is offered.
      child: Center(
        heightFactor: 1,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, node) in nodes.indexed) ...[
              if (index > 0)
                const SizedBox(
                  width: _arrowWidth,
                  height: _nodeSize,
                  child: Icon(
                    Icons.arrow_forward,
                    size: _arrowSize,
                    color: Colors.white54,
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
      ),
    );
  }
}
