import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../scaffolds/dashboard_shell_scaffold_key.dart';
import '../themes/tokens/mc_spacing.dart';

/// Opens a main section: its title, a muted lead and the section's action,
/// closed by a hairline, as a Mission Control section head.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showProgress,
    this.onClose,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final bool? showProgress;

  final VoidCallback? onClose;

  /// Goes back to the screen this one was opened from, shown before the
  /// title; none when null.
  final VoidCallback? onBack;

  static const _actionSize = 40.0;
  static const _progressSize = 20.0;

  void _openSettingsDrawer() {
    dashboardShellScaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final textTheme = context.textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: mc.hairline)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          McSpacing.s4,
          McSpacing.s4,
          McSpacing.s2,
          McSpacing.s4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: McSpacing.s3,
          children: [
            if (onBack != null)
              SizedBox.square(
                dimension: _actionSize,
                child: IconButton(
                  key: const Key('section_header_back'),
                  padding: EdgeInsets.zero,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  icon: const Icon(Icons.arrow_back),
                  color: mc.textSecondary,
                  onPressed: onBack,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: McSpacing.s1,
                children: [
                  Text(title, style: textTheme.headlineSmall),
                  Text(
                    subtitle,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: mc.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Beside the action, which stays usable while work goes on.
            if (showProgress ?? false)
              const SizedBox.square(
                dimension: _actionSize,
                child: Center(
                  child: SizedBox.square(
                    key: Key('section_header_progress'),
                    dimension: _progressSize,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  ),
                ),
              ),
            SizedBox.square(
              dimension: _actionSize,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(onClose != null ? Icons.close : Icons.menu),
                color: mc.textSecondary,
                onPressed: onClose ?? _openSettingsDrawer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
