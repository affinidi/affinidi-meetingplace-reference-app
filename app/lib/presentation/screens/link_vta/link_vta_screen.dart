import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../application/services/vtc_service/vta_link_service.dart';
import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/color_extensions.dart';
import '../../helpers/screensize_helper.dart';
import 'vta_link_panel.dart';
import 'vta_link_screen_controller.dart';

/// Asks the member to link their VTA before they use the app, in the look
/// of onboarding. The router leaves this screen once the link is active.
class LinkVtaScreen extends HookConsumerWidget {
  const LinkVtaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = context.textTheme;
    final screen = ref.watch(vtaLinkScreenControllerProvider);
    final state = screen.link;
    final controller = ref.read(vtaLinkScreenControllerProvider.notifier);
    final vtaDidField = useTextEditingController();
    final copied = useState<String?>(null);

    Future<void> copy(String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      copied.value = l10n.copiedToClipboard;
    }

    final failure = vtaLinkFailureText(l10n, screen.failure);

    return _OnboardingLayout(
      children: switch (state.status) {
        VtaLinkStatus.loading ||
        VtaLinkStatus.active => const [Center(child: _Spinner())],
        VtaLinkStatus.unlinked => [
          _Title(l10n.linkedVtaScreenTitle),
          const SizedBox(height: 8),
          _Subtitle(l10n.linkedVtaHelperText),
          const SizedBox(height: 24),
          _DidField(
            controller: vtaDidField,
            label: l10n.linkedVtaDidLabel,
            enabled: !screen.isBusy,
            onSubmitted: controller.link,
          ),
          const SizedBox(height: 24),
          _WhiteButton(
            label: l10n.linkedVtaLinkAction,
            isLoading: screen.isBusy,
            onPressed: () => controller.link(vtaDidField.text),
          ),
        ],
        VtaLinkStatus.pending => [
          _Title(l10n.linkedVtaPendingTitle),
          const SizedBox(height: 8),
          _Subtitle(l10n.linkedVtaPendingFor(state.vtaDid ?? '')),
          const SizedBox(height: 24),
          _GlassCard(
            title: l10n.linkedVtaManagerDidLabel,
            copyLabel: l10n.linkedVtaCopyDid,
            onCopy: () => copy(state.managerDid ?? ''),
            child: SelectableText(
              state.managerDid ?? '',
              style: textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          _GlassCard(
            title: l10n.linkedVtaGrantInstruction,
            copyLabel: l10n.linkedVtaCopyCommand,
            onCopy: () => copy(state.grantCommands.join('\n')),
            child: SelectableText(
              state.grantCommands.join('\n'),
              key: const Key('vta_grant_commands'),
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.linkedVtaGrantWarning,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          _WaitingLine(state),
          if (state.hasTimedOut) ...[
            const SizedBox(height: 16),
            _WhiteButton(
              label: l10n.linkedVtaCheckAgain,
              onPressed: controller.checkAgain,
            ),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: screen.isBusy ? null : controller.remove,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(l10n.cancel),
          ),
        ],
      },
      message: failure ?? copied.value,
      isError: failure != null,
    );
  }
}

/// The blue gradient, logo header and footer of onboarding, around
/// scrolling [children].
class _OnboardingLayout extends StatelessWidget {
  const _OnboardingLayout({
    required this.children,
    this.message,
    this.isError = false,
  });

  final List<Widget> children;
  final String? message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final media = MediaQuery.of(context);
    final isSmallLandscape =
        ScreensizeHelper().isSmallScreen(context) &&
        ScreensizeHelper().isLandscape(context);
    final radius = media.size.width > 1024 ? 6.0 : 2.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomCenter,
            radius: radius,
            colors: [
              colorScheme.primary.withLightness(0.3),
              colorScheme.primary.withAlpha(249),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
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
                    ...children,
                    if (message case final text?) ...[
                      const SizedBox(height: 16),
                      _Message(text, isError: isError),
                    ],
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
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
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

class _Subtitle extends StatelessWidget {
  const _Subtitle(this.text);

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

/// The VTA DID input, frosted white on the gradient.
class _DidField extends StatelessWidget {
  const _DidField({
    required this.controller,
    required this.label,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool enabled;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color),
    );
    return TextField(
      key: const Key('vta_did_field'),
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
        hintText: 'did:webvh:…',
        hintStyle: textTheme.bodyMedium?.copyWith(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withAlpha(25),
        border: border(Colors.white.withAlpha(76)),
        enabledBorder: border(Colors.white.withAlpha(76)),
        disabledBorder: border(Colors.white.withAlpha(40)),
        focusedBorder: border(Colors.white),
      ),
    );
  }
}

/// The primary action: white, with the primary colour as text.
class _WhiteButton extends StatelessWidget {
  const _WhiteButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: _Spinner());
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: context.colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

/// A frosted card with a title, a copy action, and [child].
class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.title,
    required this.copyLabel,
    required this.onCopy,
    required this.child,
  });

  final String title;
  final String copyLabel;
  final VoidCallback onCopy;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.white),
                  tooltip: copyLabel,
                  onPressed: onCopy,
                ),
              ],
            ),
            Padding(padding: const EdgeInsets.only(right: 12), child: child),
          ],
        ),
      ),
    );
  }
}

/// What the phone is doing while it waits for the grant.
class _WaitingLine extends StatelessWidget {
  const _WaitingLine(this.state);

  final VtaLinkState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12,
      children: [
        if (!state.hasTimedOut)
          const SizedBox.square(dimension: 16, child: _Spinner(strokeWidth: 2)),
        Flexible(
          child: Text(
            vtaLinkWaitingText(context.l10n, state),
            key: const Key('vta_link_waiting'),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {required this.isError});

  final String text;
  final bool isError;

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
          key: const Key('linked_vta_message'),
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: isError ? colorScheme.onErrorContainer : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner({this.strokeWidth = 4});

  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      strokeWidth: strokeWidth,
      color: Colors.white,
    );
  }
}
