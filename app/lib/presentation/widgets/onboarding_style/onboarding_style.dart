import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../helpers/screensize_helper.dart';
import '../../themes/tokens/mc_colors.dart';
import '../../themes/tokens/mc_icons.dart';
import '../../themes/tokens/mc_radius.dart';
import '../../themes/tokens/mc_typography.dart';
import '../common/app_card.dart';

/// Shows [child] in a raised sheet.
Future<void> showOnboardingSheet(BuildContext context, Widget child) {
  const radius = BorderRadius.vertical(top: Radius.circular(McRadius.xl));
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DecoratedBox(
      decoration: BoxDecoration(
        color: context.mcColors.raised,
        borderRadius: radius,
        border: Border(top: BorderSide(color: context.mcColors.hairline)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: child,
      ),
    ),
  );
}

/// The logo header of onboarding on the black canvas, over a scrolling
/// [child]. With [onClose], a close button leads the header, for a screen
/// opened over another. Without [showBranding], no logo header, e.g. for a
/// flow with steps of its own.
class OnboardingLayout extends StatelessWidget {
  const OnboardingLayout({
    super.key,
    required this.child,
    this.onClose,
    this.showBranding = true,
  });

  final Widget child;
  final VoidCallback? onClose;
  final bool showBranding;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final mc = context.mcColors;
    final isSmallLandscape =
        ScreensizeHelper().isSmallScreen(context) &&
        ScreensizeHelper().isLandscape(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      media.size.height -
                      media.padding.top -
                      media.padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: isSmallLandscape ? 24 : 48),
                      if (showBranding) ...[
                        SizedBox(
                          height: isSmallLandscape ? 64 : 96,
                          child: Image.asset(
                            'assets/images/meeting-place-splash-white-1024.png',
                            color: mc.textPrimary,
                            colorBlendMode: BlendMode.modulate,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.appName,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: mc.textPrimary,
                          ),
                        ),
                        SizedBox(height: isSmallLandscape ? 24 : 40),
                      ],
                      child,
                      const Spacer(),
                      SizedBox(height: isSmallLandscape ? 16 : 32),
                    ],
                  ),
                ),
              ),
            ),
            if (onClose case final onClose?)
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  icon: Icon(McIcons.close, color: mc.textPrimary),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: onClose,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A step's heading, bold on the gradient.
class OnboardingTitle extends StatelessWidget {
  const OnboardingTitle(this.text, {super.key, this.trailing});

  final String text;

  /// Shown after the last word, such as an icon button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        children: [
          if (trailing case final trailing?)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: trailing,
              ),
            ),
        ],
      ),
      textAlign: TextAlign.center,
      style: context.textTheme.headlineMedium?.copyWith(
        color: context.mcColors.textPrimary,
        height: 1.3,
      ),
    );
  }
}

/// Text under a heading, muted on the gradient.
class OnboardingSubtitle extends StatelessWidget {
  const OnboardingSubtitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.mcColors.textSecondary,
      ),
    );
  }
}

/// A text input, a panel on the gradient.
class OnboardingTextField extends StatelessWidget {
  const OnboardingTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.onSubmitted,
    this.hint,
    this.enabled = true,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool enabled;
  final ValueChanged<String> onSubmitted;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final mc = context.mcColors;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(McRadius.md),
      borderSide: BorderSide(color: color),
    );
    return TextField(
      controller: controller,
      enabled: enabled,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.go,
      onSubmitted: onSubmitted,
      style: textTheme.bodyMedium?.copyWith(color: mc.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: textTheme.bodyMedium?.copyWith(color: mc.textSecondary),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: mc.textPrimary,
        ),
        hintText: hint,
        hintStyle: textTheme.bodyMedium?.copyWith(color: mc.textTertiary),
        filled: true,
        fillColor: context.colorScheme.surfaceContainerLow,
        suffixIcon: suffixIcon,
        suffixIconColor: mc.textSecondary,
        border: border(mc.hairlineStrong),
        enabledBorder: border(mc.hairlineStrong),
        disabledBorder: border(mc.hairline),
        focusedBorder: border(McColors.blue),
      ),
    );
  }
}

/// The primary action, in the theme's primary button style. Outlined, it is
/// a frame for a secondary action such as removing a link. Destructive, it
/// is in the theme's danger colour, for an action that throws away what is
/// under way.
class OnboardingButton extends StatelessWidget {
  const OnboardingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: OnboardingSpinner());
    const padding = EdgeInsets.symmetric(vertical: 16);
    final text = Text(label);
    if (isDestructive) {
      return ElevatedButton(
        onPressed: onPressed,
        style: context.destructiveElevatedButtonStyle.copyWith(
          padding: const WidgetStatePropertyAll(padding),
        ),
        child: text,
      );
    }
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(padding: padding),
        child: text,
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(padding: padding),
      child: text,
    );
  }
}

/// A less prominent action, such as Cancel: plain text on the gradient.
class OnboardingTextButton extends StatelessWidget {
  const OnboardingTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: context.mcColors.textPrimary,
      ),
      child: Text(label),
    );
  }
}

/// A panel card with a title, [child], and a copy action when [onCopy] is
/// given.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.title,
    required this.child,
    this.copyLabel,
    this.onCopy,
  });

  final String title;
  final Widget child;
  final String? copyLabel;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    final titleText = Text(
      title,
      style: context.textTheme.titleSmall?.copyWith(color: mc.textPrimary),
    );
    return AppCard(
      padding: EdgeInsets.fromLTRB(20, onCopy == null ? 16 : 8, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onCopy case final onCopy?)
            Row(
              children: [
                Expanded(child: titleText),
                IconButton(
                  icon: Icon(McIcons.copy, size: 18, color: mc.textSecondary),
                  tooltip: copyLabel,
                  onPressed: onCopy,
                ),
              ],
            )
          else ...[
            titleText,
            const SizedBox(height: 8),
          ],
          Padding(padding: const EdgeInsets.only(right: 12), child: child),
        ],
      ),
    );
  }
}

/// Small print on the gradient, such as a note under a card.
TextStyle? onboardingNote(BuildContext context) => context.textTheme.bodySmall
    ?.copyWith(color: context.mcColors.textSecondary);

/// A line in a glass card: an icon, a title, and an optional
/// explanation.
class OnboardingLine extends StatelessWidget {
  const OnboardingLine({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleTooltip,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// More about the title, shown when it is tapped; the title is
  /// underlined to tell so.
  final String? titleTooltip;

  /// An action at the end of the line, such as an icon button, which the
  /// line centers itself on vertically.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final mc = context.mcColors;
    return Row(
      crossAxisAlignment: trailing == null
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      spacing: 12,
      children: [
        Icon(icon, size: 20, color: mc.textPrimary),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              switch (titleTooltip) {
                final tooltip? => Tooltip(
                  message: tooltip,
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: const Duration(seconds: 10),
                  child: Text(
                    title,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: mc.textPrimary,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.dotted,
                      decorationColor: mc.textSecondary,
                    ),
                  ),
                ),
                null => Text(
                  title,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: mc.textPrimary,
                  ),
                ),
              },
              if (subtitle case final subtitle?)
                Text(subtitle, style: onboardingNote(context)),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// A DID in monospace, so its long identifier reads as one value.
class MonospaceDid extends StatelessWidget {
  const MonospaceDid(this.did, {super.key, this.textKey});

  final String did;
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      did,
      key: textKey,
      style: McTypography.code.copyWith(
        color: context.mcColors.textPrimary,
        height: 1.4,
      ),
    );
  }
}

/// A message in place on the gradient: a panel, or the error colours.
class OnboardingMessage extends StatelessWidget {
  const OnboardingMessage(
    this.text, {
    super.key,
    required this.isError,
    this.textKey,
  });

  final String text;
  final bool isError;
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final mc = context.mcColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isError
            ? colorScheme.errorContainer
            : colorScheme.surfaceContainerLow,
        border: Border.all(
          color: isError ? mc.dangerText.withValues(alpha: 0.55) : mc.hairline,
        ),
        borderRadius: BorderRadius.circular(McRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          text,
          key: textKey,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: isError ? colorScheme.onErrorContainer : mc.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// A progress spinner for the gradient, in the theme's progress colour.
class OnboardingSpinner extends StatelessWidget {
  const OnboardingSpinner({super.key, this.strokeWidth = 4});

  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(strokeWidth: strokeWidth);
  }
}

/// Where a flow of [total] steps stands: a thin bar filled up to
/// [step], counted from 1, under the step's [title].
class OnboardingStepProgress extends StatelessWidget {
  const OnboardingStepProgress({
    super.key,
    required this.step,
    required this.total,
    required this.title,
  });

  final int step;
  final int total;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(
          context.l10n.onboardingStepOf(step, total, title),
          style: onboardingNote(context),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(McRadius.xs),
          child: LinearProgressIndicator(value: step / total, minHeight: 4),
        ),
      ],
    );
  }
}
