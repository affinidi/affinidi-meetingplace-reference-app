import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../../infrastructure/extensions/color_extensions.dart';
import '../helpers/screensize_helper.dart';
import '../scaffolds/dashboard_shell_scaffold_key.dart';

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
    final colorScheme = context.colorScheme;

    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          height: 85,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            gradient: RadialGradient(
              center: Alignment.bottomCenter,
              radius: ScreensizeHelper.getRadiusForScreenWidth(context),
              colors: [
                colorScheme.primary.withAlpha(249),
                colorScheme.primary.withLightness(0.3),
              ],
            ),
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
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
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
                      Text(title, style: context.textTheme.headlineMedium),
                      Text(
                        subtitle,
                        maxLines: 3,
                        style: context.textTheme.headlineSmall,
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
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
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
