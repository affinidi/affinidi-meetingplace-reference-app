import 'package:flutter/material.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/color_extensions.dart';
import '../../helpers/screensize_helper.dart';

/// The blue gradient of onboarding, behind the linking and joining steps.
BoxDecoration onboardingGradient(
  BuildContext context, {
  required double radius,
  BorderRadius? borderRadius,
}) {
  final colorScheme = context.colorScheme;
  return BoxDecoration(
    borderRadius: borderRadius,
    gradient: RadialGradient(
      center: Alignment.bottomCenter,
      radius: radius,
      colors: [
        colorScheme.primary.withLightness(0.3),
        colorScheme.primary.withAlpha(249),
      ],
    ),
  );
}

/// The blue gradient, logo header and footer of onboarding, around a
/// scrolling [child]. With [onClose], a close button leads the header, for
/// a screen opened over another.
class OnboardingLayout extends StatelessWidget {
  const OnboardingLayout({super.key, required this.child, this.onClose});

  final Widget child;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isSmallLandscape =
        ScreensizeHelper().isSmallScreen(context) &&
        ScreensizeHelper().isLandscape(context);
    final radius = media.size.width > 1024 ? 6.0 : 2.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: DecoratedBox(
        decoration: onboardingGradient(context, radius: radius),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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
                        SizedBox(
                          height: isSmallLandscape ? 64 : 96,
                          child: Image.asset(
                            'assets/images/meeting-place-splash-white-1024.png',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.appName,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isSmallLandscape ? 24 : 40),
                        child,
                        const Spacer(),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 24,
                            bottom: isSmallLandscape ? 16 : 32,
                          ),
                          child: Center(
                            child: SizedBox(
                              height: 40,
                              child: Image.asset(
                                'assets/images/powered_by_mpx.png',
                              ),
                            ),
                          ),
                        ),
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
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: onClose,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A step's heading, white and bold on the gradient.
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
        color: Colors.white,
        fontWeight: FontWeight.bold,
        height: 1.3,
        letterSpacing: -0.5,
        shadows: [
          Shadow(
            color: Colors.black.withAlpha(120),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
    );
  }
}

/// Text under a heading, muted white on the gradient.
class OnboardingSubtitle extends StatelessWidget {
  const OnboardingSubtitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: context.textTheme.bodyMedium?.copyWith(color: Colors.white70),
    );
  }
}

/// A text input, frosted white on the gradient.
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
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
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
      style: textTheme.bodyMedium?.copyWith(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.white70),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        hintText: hint,
        hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withAlpha(25),
        suffixIcon: suffixIcon,
        suffixIconColor: Colors.white,
        border: border(Colors.white.withAlpha(76)),
        enabledBorder: border(Colors.white.withAlpha(76)),
        disabledBorder: border(Colors.white.withAlpha(40)),
        focusedBorder: border(Colors.white),
      ),
    );
  }
}

/// The primary action: white, with the primary colour as text. Outlined, it
/// is a white frame for a secondary action such as removing a link.
class OnboardingButton extends StatelessWidget {
  const OnboardingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: OnboardingSpinner());
    const padding = EdgeInsets.symmetric(vertical: 16);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    final text = Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          padding: padding,
          shape: shape,
        ),
        child: text,
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: context.colorScheme.primary,
        disabledBackgroundColor: Colors.white.withAlpha(60),
        disabledForegroundColor: Colors.white70,
        padding: padding,
        shape: shape,
      ),
      child: text,
    );
  }
}

/// A less prominent action, such as Cancel: white text on the gradient.
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
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      child: Text(label),
    );
  }
}

/// A frosted card with a title, [child], and a copy action when [onCopy] is
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
    final titleText = Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 15,
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, onCopy == null ? 16 : 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (onCopy case final onCopy?)
              Row(
                children: [
                  Expanded(child: titleText),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18, color: Colors.white),
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
      ),
    );
  }
}

/// Small print on the gradient, such as a note under a card.
TextStyle? onboardingNote(BuildContext context) =>
    context.textTheme.bodySmall?.copyWith(color: Colors.white70);

/// A line in a glass card: a white icon, a title, and an optional
/// explanation.
class OnboardingLine extends StatelessWidget {
  const OnboardingLine({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// An action at the end of the line, such as an icon button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Icon(icon, size: 20, color: Colors.white),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
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
      style: context.textTheme.bodySmall?.copyWith(
        color: Colors.white,
        fontFamily: 'monospace',
        height: 1.4,
      ),
    );
  }
}

/// A message in place on the gradient: frosted, or the error colours.
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isError
            ? colorScheme.errorContainer
            : Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          text,
          key: textKey,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: isError ? colorScheme.onErrorContainer : Colors.white,
          ),
        ),
      ),
    );
  }
}

/// A white progress spinner for the gradient.
class OnboardingSpinner extends StatelessWidget {
  const OnboardingSpinner({super.key, this.strokeWidth = 4});

  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: strokeWidth,
      color: Colors.white,
    );
  }
}
