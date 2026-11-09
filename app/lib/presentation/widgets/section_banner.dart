import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../helpers/screensize_helper.dart';
import '../scaffolds/dashboard_shell_scaffold_key.dart';
import '../themes/tokens/mc_radius.dart';
import 'onboarding_style/onboarding_style.dart';

class SectionBanner extends StatelessWidget {
  const SectionBanner({
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

  void _openSettingsDrawer() {
    dashboardShellScaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          height: 85,
          decoration: onboardingGradient(
            context,
            radius: ScreensizeHelper.getRadiusForScreenWidth(context),
            borderRadius: BorderRadius.circular(McRadius.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 12,
              children: [
                if (onBack != null)
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      key: const Key('section_banner_back'),
                      padding: EdgeInsets.zero,
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      icon: Icon(
                        Icons.arrow_back,
                        color: context.mcColors.textTertiary,
                        size: 28,
                      ),
                      onPressed: onBack,
                    ),
                  ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.textTheme.titleLarge),
                      Text(
                        subtitle,
                        maxLines: 3,
                        // Tighter than bodySmall so two lines fit the
                        // banner's fixed height.
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.mcColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Beside the menu, which stays usable while work goes on.
                if (showProgress ?? false)
                  const SizedBox(
                    key: Key('section_banner_progress'),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      onClose != null ? Icons.close : Icons.menu,
                      color: context.mcColors.textTertiary,
                      size: 28,
                    ),
                    onPressed: onClose ?? _openSettingsDrawer,
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
