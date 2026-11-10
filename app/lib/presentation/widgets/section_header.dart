import 'package:flutter/material.dart';

import '../../infrastructure/extensions/build_context_extensions.dart';
import '../scaffolds/dashboard_shell_scaffold_key.dart';
import '../themes/tokens/mc_icons.dart';
import '../themes/tokens/mc_spacing.dart';
import 'images/logo_avatar.dart';

/// Opens a main section: its icon and title, a muted lead and the
/// section's action, closed by a hairline, as a Mission Control section
/// head. With a way back, the title goes below it, for room to show a
/// logo.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.logoUrl,
    this.showProgress,
    this.onClose,
    this.onBack,
  });

  /// The section's symbol, as on its navigation item.
  final IconData icon;

  /// The logo of what the section shows, in place of [icon]; the icon when
  /// null or while it cannot load.
  final Uri? logoUrl;

  final String title;
  final String subtitle;
  final bool? showProgress;

  final VoidCallback? onClose;

  /// Goes back to the screen this one was opened from, shown above the
  /// title; none when null.
  final VoidCallback? onBack;

  static const _iconSize = 24.0;
  static const _logoSize = 48.0;
  static const _actionSize = 40.0;
  static const _progressSize = 20.0;

  void _openSettingsDrawer() {
    dashboardShellScaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final textTheme = context.textTheme;
    final titleStyle = textTheme.headlineSmall;
    // The icon centres on the title's first line, whatever its size.
    final titleLineHeight =
        (titleStyle?.fontSize ?? _iconSize) * (titleStyle?.height ?? 1);
    final iconView = SizedBox(
      height: titleLineHeight,
      child: Icon(icon, size: _iconSize, color: mc.textSecondary),
    );

    final headline = Row(
      // A logo centres on the title and lead together.
      crossAxisAlignment: logoUrl == null
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      spacing: McSpacing.s3,
      children: [
        switch (logoUrl) {
          final url? => LogoAvatar(
            key: const Key('section_header_logo'),
            url: url,
            size: _logoSize,
            fallback: iconView,
          ),
          null => iconView,
        },
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: McSpacing.s1,
            children: [
              Text(title, style: titleStyle),
              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(color: mc.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );

    final actions = [
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
          icon: Icon(onClose != null ? McIcons.close : McIcons.menu),
          color: mc.textSecondary,
          tooltip: onClose != null
              ? MaterialLocalizations.of(context).closeButtonTooltip
              : MaterialLocalizations.of(context).openAppDrawerTooltip,
          onPressed: onClose ?? _openSettingsDrawer,
        ),
      ),
    ];

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
        child: switch (onBack) {
          final onBack? => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: McSpacing.s2,
            children: [
              Row(
                children: [
                  SizedBox.square(
                    dimension: _actionSize,
                    child: IconButton(
                      key: const Key('section_header_back'),
                      padding: EdgeInsets.zero,
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      icon: const Icon(McIcons.back),
                      color: mc.textSecondary,
                      onPressed: onBack,
                    ),
                  ),
                  const Spacer(),
                  ...actions,
                ],
              ),
              headline,
            ],
          ),
          null => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: McSpacing.s3,
            children: [
              Expanded(child: headline),
              ...actions,
            ],
          ),
        },
      ),
    );
  }
}
