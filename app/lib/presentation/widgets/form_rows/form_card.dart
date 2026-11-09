import 'package:flutter/widgets.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../themes/tokens/mc_spacing.dart';
import '../common/app_card.dart';

/// A titled panel of form rows, as the community page's cards: the title
/// sits inside the panel, in line with the rows below it, and the last row
/// keeps its distance from the bottom edge.
class FormCard extends StatelessWidget {
  const FormCard({
    super.key,
    required this._title,
    required this._child,
    this._trailing,
  });

  final Widget _child;
  final String _title;
  final Widget? _trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      // Rows end flush (a ListTile's own inset, or a hint's 4px), so the
      // panel adds the rest of its bottom inset.
      padding: const EdgeInsets.only(bottom: McSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              McSpacing.s4,
              McSpacing.s4,
              McSpacing.s4,
              McSpacing.s1,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    _title,
                    style: context.textTheme.titleSmall?.copyWith(
                      color: context.mcColors.textPrimary,
                    ),
                  ),
                ),
                ?_trailing,
              ],
            ),
          ),
          _child,
        ],
      ),
    );
  }
}
