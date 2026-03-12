import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../infrastructure/extensions/build_context_extensions.dart';
import '../../../../infrastructure/extensions/color_extensions.dart';
import '../../../helpers/screensize_helper.dart';
import 'authentication_screen_controller.dart';

class AuthenticationScreen extends HookConsumerWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    final provider = authenticationScreenControllerProvider;
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    String platformInstruction(BuildContext context) {
      final platform = Theme.of(context).platform;
      switch (platform) {
        case TargetPlatform.android:
          return l10n.authInstructionAndroid;
        case TargetPlatform.iOS:
          return l10n.authInstructionIos;
        case TargetPlatform.macOS:
          return l10n.authInstructionMacos;
        default:
          return ''; // no hint for web, desktop, etc.
      }
    }

    useEffect(() {
      if (!context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await controller.initialize(l10n.authUnlockReason);
      });

      return null;
    }, []);

    // AL: Calculate width to constrain for large screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final radius = screenWidth > 1024 ? 6.0 : 2.0;
    final isSmallScreenLandscape =
        ScreensizeHelper().isSmallScreen(context) &&
        ScreensizeHelper().isLandscape(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
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
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: isSmallScreenLandscape ? 80 : 120,
                          child: Image.asset(
                            'assets/images/meeting-place-splash-white-1024.png',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(l10n.appName, style: textTheme.bodyLarge),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (state.isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        if (!state.isLoading && state.isError) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                Text(
                                  state.error ?? l10n.toProtectData,
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodyMedium,
                                ),
                                SizedBox(
                                  height: isSmallScreenLandscape ? 8 : 12,
                                ),
                                Text(
                                  platformInstruction(context),
                                  textAlign: TextAlign.center,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isSmallScreenLandscape
                              ? const SizedBox.shrink()
                              : const SizedBox(height: 20),
                          TextButton(
                            onPressed: () =>
                                controller.retry(l10n.authUnlockReason),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.generalRetry,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreenLandscape ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: isSmallScreenLandscape ? 20.0 : 40.0,
                ),
                child: Center(
                  child: SizedBox(
                    height: 40,
                    child: Image.asset('assets/images/powered_by_mpx.png'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
