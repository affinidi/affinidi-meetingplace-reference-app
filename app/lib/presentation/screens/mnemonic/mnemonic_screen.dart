import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../infrastructure/extensions/color_extensions.dart';
import '../../../infrastructure/services/camera_service/camera_service.dart';
import '../../dialogs/qr_code_picker/qr_code_picker.dart';
import '../../helpers/screensize_helper.dart';
import 'mnemonic_screen_controller.dart';

enum _Mode { selection, manual, success }

class MnemonicScreen extends HookConsumerWidget {
  const MnemonicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final provider = mnemonicScreenControllerProvider;
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    final mode = useState(_Mode.selection);
    final mnemonicController = useTextEditingController();
    final isSmallScreenLandscape =
        ScreensizeHelper().isSmallScreen(context) &&
        ScreensizeHelper().isLandscape(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final radius = screenWidth > 1024 ? 6.0 : 2.0;

    final isCameraAvailable = ref.watch(
      cameraServiceProvider.select((s) => s.isAvailable ?? false),
    );

    Future<void> submitMnemonic(String mnemonic) async {
      final saved = await controller.saveMnemonic(mnemonic);
      if (!context.mounted) return;
      if (saved) {
        mode.value = _Mode.success;
      } else {
        final errorMessage =
            ref.read(provider).errorMessage ?? l10n.mnemonicErrorOccurred;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.errorContainer,
            showCloseIcon: true,
            closeIconColor: colorScheme.onErrorContainer,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    Future<void> onScanQr() async {
      final data = await QrCodePicker.show(context: context);
      if (data == null || !context.mounted) return;
      await submitMnemonic(data);
    }

    Future<void> onManualContinue() async {
      await submitMnemonic(mnemonicController.text);
    }

    final background = Container(
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
    );

    Widget header({bool showBack = false}) => Column(
      children: [
        SizedBox(height: isSmallScreenLandscape ? 24 : 48),
        if (showBack)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => mode.value = _Mode.selection,
            ),
          )
        else
          SizedBox(height: isSmallScreenLandscape ? 0 : 0),
        SizedBox(
          height: isSmallScreenLandscape ? 64 : 96,
          child: Image.asset(
            'assets/images/meeting-place-splash-white-1024.png',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.appName,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge,
        ),
        SizedBox(height: isSmallScreenLandscape ? 24 : 40),
      ],
    );

    Widget footer() => Padding(
      padding: EdgeInsets.only(
        bottom: isSmallScreenLandscape ? 16 : 32,
        top: 24,
      ),
      child: Center(
        child: SizedBox(
          height: 40,
          child: Image.asset('assets/images/powered_by_mpx.png'),
        ),
      ),
    );

    if (mode.value == _Mode.success) {
      return _SuccessScreen(
        background: background,
        onComplete: () {
          if (context.mounted) context.go('/');
        },
      );
    }

    if (mode.value == _Mode.selection) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Positioned.fill(child: background),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header(),
                        Text(
                          l10n.mnemonicEntrySelectionTitle,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
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
                              Shadow(
                                color: Colors.white.withAlpha(60),
                                offset: const Offset(0, -1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _OptionCard(
                          icon: Icons.qr_code_scanner,
                          title: l10n.mnemonicScanQrTitle,
                          subtitle: l10n.mnemonicScanQrSubtitle,
                          enabled: isCameraAvailable,
                          onTap: onScanQr,
                        ),
                        const SizedBox(height: 12),
                        _OptionCard(
                          icon: Icons.keyboard_alt_outlined,
                          title: l10n.mnemonicEnterManuallyTitle,
                          subtitle: l10n.mnemonicEnterManuallySubtitle,
                          onTap: () => mode.value = _Mode.manual,
                        ),
                        if (state.isLoading) ...[
                          const SizedBox(height: 24),
                          const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        footer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Manual entry view
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(child: background),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      header(showBack: true),
                      Text(
                        l10n.mnemonicManualEntryTitle,
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.mnemonicManualEntrySubtitle,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: mnemonicController,
                        maxLines: 4,
                        minLines: 3,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        autocorrect: false,
                        enableSuggestions: false,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: l10n.mnemonicManualHint,
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: Colors.white38,
                          ),
                          filled: true,
                          fillColor: Colors.white.withAlpha(25),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withAlpha(76),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withAlpha(76),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (state.isLoading)
                        const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator.adaptive(
                              backgroundColor: Colors.white,
                            ),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: onManualContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                            child: Text(
                              l10n.mnemonicContinue,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      const Spacer(),
                      footer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Success screen
// ---------------------------------------------------------------------------

class _SuccessScreen extends HookWidget {
  const _SuccessScreen({required this.background, required this.onComplete});

  final Widget background;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    // Circle scale-in with overshoot, then checkmark draw, then fade label in.
    final circleAnim = useAnimationController(
      duration: const Duration(milliseconds: 600),
    );
    final checkAnim = useAnimationController(
      duration: const Duration(milliseconds: 500),
    );
    final labelAnim = useAnimationController(
      duration: const Duration(milliseconds: 400),
    );

    useEffect(() {
      Future<void> run() async {
        await circleAnim.forward();
        await checkAnim.forward();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await labelAnim.forward();
        await Future<void>.delayed(const Duration(milliseconds: 2800));
        onComplete();
      }

      run();
      return null;
    }, const []);

    final circleScale = CurvedAnimation(
      parent: circleAnim,
      curve: Curves.elasticOut,
    );
    final checkProgress = CurvedAnimation(
      parent: checkAnim,
      curve: Curves.easeOut,
    );
    final labelOpacity = CurvedAnimation(
      parent: labelAnim,
      curve: Curves.easeIn,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: background),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: circleScale,
                  child: AnimatedBuilder(
                    animation: checkProgress,
                    builder: (context, _) => CustomPaint(
                      size: const Size(120, 120),
                      painter: _CheckmarkPainter(progress: checkProgress.value),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: labelOpacity,
                  child: Column(
                    children: [
                      Text(
                        context.l10n.mnemonicSuccessTitle,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.mnemonicSuccessSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  const _CheckmarkPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withAlpha(40)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    if (progress <= 0) return;

    // Checkmark path
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.70)
      ..lineTo(size.width * 0.75, size.height * 0.34);

    final metrics = path.computeMetrics().first;
    final drawn = metrics.extractPath(0, metrics.length * progress);

    canvas.drawPath(
      drawn,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckmarkPainter old) => old.progress != progress;
}

// ---------------------------------------------------------------------------
// Option card
// ---------------------------------------------------------------------------

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
